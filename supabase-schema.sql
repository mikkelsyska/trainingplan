create table if not exists public.training_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  current_ftp smallint not null check (current_ftp between 80 and 500),
  target_ftp smallint not null check (target_ftp between 80 and 600),
  weight_kg numeric(5, 1) not null check (weight_kg between 30 and 250),
  age smallint not null check (age between 16 and 100),
  max_hr smallint not null check (max_hr between 100 and 240),
  weekly_hours numeric(3, 1) not null default 5 check (weekly_hours between 2 and 16),
  training_days text[] not null default array['Tue', 'Thu', 'Sat', 'Sun']::text[]
    check (cardinality(training_days) between 3 and 4 and training_days <@ array['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']::text[]),
  updated_at timestamptz not null default now()
);

alter table public.training_profiles
  add column if not exists weekly_hours numeric(3, 1) not null default 5 check (weekly_hours between 2 and 16);
alter table public.training_profiles
  add column if not exists training_days text[] not null default array['Tue', 'Thu', 'Sat', 'Sun']::text[]
    check (cardinality(training_days) between 3 and 4 and training_days <@ array['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']::text[]);

create table if not exists public.workout_completions (
  user_id uuid not null references auth.users(id) on delete cascade,
  week_index smallint not null check (week_index between 0 and 11),
  workout_index smallint not null check (workout_index between 0 and 3),
  completed_at timestamptz not null default now(),
  primary key (user_id, week_index, workout_index)
);

create table if not exists public.ftp_tests (
  user_id uuid not null references auth.users(id) on delete cascade,
  tested_on date not null,
  ftp smallint not null check (ftp between 80 and 500),
  created_at timestamptz not null default now(),
  primary key (user_id, tested_on)
);

alter table public.training_profiles enable row level security;
alter table public.workout_completions enable row level security;
alter table public.ftp_tests enable row level security;

drop policy if exists "Users read own training profile" on public.training_profiles;
create policy "Users read own training profile"
  on public.training_profiles for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users create own training profile" on public.training_profiles;
create policy "Users create own training profile"
  on public.training_profiles for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Users update own training profile" on public.training_profiles;
create policy "Users update own training profile"
  on public.training_profiles for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "Users read own workout completions" on public.workout_completions;
create policy "Users read own workout completions"
  on public.workout_completions for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users create own workout completions" on public.workout_completions;
create policy "Users create own workout completions"
  on public.workout_completions for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Users update own workout completions" on public.workout_completions;
create policy "Users update own workout completions"
  on public.workout_completions for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "Users delete own workout completions" on public.workout_completions;
create policy "Users delete own workout completions"
  on public.workout_completions for delete to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users read own FTP tests" on public.ftp_tests;
create policy "Users read own FTP tests"
  on public.ftp_tests for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users create own FTP tests" on public.ftp_tests;
create policy "Users create own FTP tests"
  on public.ftp_tests for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Users update own FTP tests" on public.ftp_tests;
create policy "Users update own FTP tests"
  on public.ftp_tests for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "Users delete own FTP tests" on public.ftp_tests;
create policy "Users delete own FTP tests"
  on public.ftp_tests for delete to authenticated
  using (user_id = (select auth.uid()));

grant select, insert, update on public.training_profiles to authenticated;
grant select, insert, update, delete on public.workout_completions to authenticated;
grant select, insert, update, delete on public.ftp_tests to authenticated;