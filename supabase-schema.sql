create table if not exists public.training_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  current_ftp smallint not null check (current_ftp between 80 and 500),
  target_ftp smallint not null check (target_ftp between 80 and 600),
  weight_kg numeric(5, 1) not null check (weight_kg between 30 and 250),
  age smallint not null check (age between 16 and 100),
  max_hr smallint not null check (max_hr between 100 and 240),
  updated_at timestamptz not null default now()
);

create table if not exists public.workout_completions (
  user_id uuid not null references auth.users(id) on delete cascade,
  week_index smallint not null check (week_index between 0 and 11),
  workout_index smallint not null check (workout_index between 0 and 3),
  completed_at timestamptz not null default now(),
  primary key (user_id, week_index, workout_index)
);

alter table public.training_profiles enable row level security;
alter table public.workout_completions enable row level security;

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

grant select, insert, update on public.training_profiles to authenticated;
grant select, insert, update, delete on public.workout_completions to authenticated;