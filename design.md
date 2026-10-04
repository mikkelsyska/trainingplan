# Zwift FTP Training Plan Design

## Product Goal

Provide a profile-driven, Zwift-first cycling plan for riders who want to improve FTP. The page should use each rider's own FTP, goal, weight, age, and maximum heart rate rather than assuming the original example rider's values.

The plan is a general training template, not medical advice or a promised FTP result. A reported maximum heart rate alone is not enough to derive reliable heart-rate zones, so training guidance is primarily power-based.

## User Experience

### First Visit

- Show a clear prompt to create a rider profile. Do not display fixed FTP, weight, age, or heart-rate values as defaults.
- Allow guest use with profile and completion data saved in the current browser.
- Offer account creation and sign-in for cross-device sync when Supabase is configured.
- Keep the page usable on desktop and mobile, with a persistent light/dark preference.

### Rider Profile

The profile editor collects:

- Current FTP in watts
- Target FTP in watts
- Weight in kilograms
- Age
- Maximum heart rate in bpm
- Weekly training availability in hours
- Three or four available training days

The page derives current and goal W/kg, goal change, power zones, workout watt guidance, and the hero description from these values. Updating profile settings refreshes the visible plan values.

### Weekly Plan

- Present a 12-week plan in three phases: base, build, and sharpen/test.
- Provide three key sessions per week and an optional fourth recovery ride.
- Retain deload and FTP test checkpoints in weeks 4, 8, and 12.
- Use a rider's selected days for the key sessions, in calendar order. The first three selected days must leave at least one rest day between key sessions.
- Use a fourth selected day for recovery only when that session fits the weekly-hour budget.
- Calculate scheduled weekly volume from the rides shown. If the three key sessions exceed the rider's availability, show a warning; do not silently remove or compress key workouts.
- Keep workout prescriptions expressed relative to FTP. Where an interval range is stated as a percentage of FTP, also show its approximate watt range using the current FTP. The rider must still update FTP in Zwift separately.
- Link Zwift workouts and suggested routes to the external What's on Zwift catalog. Rest days must not recommend a route.
- Let riders select a week, mark workouts complete, and review weekly progress.

### FTP Test History

- Allow a rider to log a test date and FTP result.
- Keep one result per date; logging another result on that date replaces the previous value.
- Display dated results as a history chart.
- A newly logged result becomes the current FTP and recalculates power zones and future workout watt guidance. It does not alter completed sessions or claim to automatically update Zwift.

## Data Model

### Rider Profile

Guest profile data is stored in browser local storage. Authenticated profile data is stored in `public.training_profiles` and keyed by the Supabase Auth user ID.

| Field | Meaning |
| --- | --- |
| `current_ftp` | Current tested or estimated FTP in watts |
| `target_ftp` | Rider's goal FTP in watts |
| `weight_kg` | Rider weight used for W/kg calculations |
| `age` | Rider age |
| `max_hr` | Reported maximum heart rate, shown as context only |
| `weekly_hours` | Available training time per week |
| `training_days` | Three or four available weekdays |

### FTP Tests

Guest FTP history is stored locally. Authenticated results are stored in `public.ftp_tests`, keyed by `(user_id, tested_on)` so each user has at most one result per date.

### Workout Completions

Guest completion state is stored locally. Authenticated completion rows are stored in `public.workout_completions`, keyed by user, plan week, and workout index.

The selected display theme is a local device preference and is not synced as rider training data.

## Architecture

- The frontend is a static HTML/CSS/JavaScript page hosted by GitHub Pages; no build step is required.
- Supabase JS is loaded as a browser client. `supabase-config.js` contains only the project URL and publishable/anon key.
- Supabase Auth provides email/password accounts. The client reads and writes each user's profile, FTP history, and workout completions.
- `supabase-schema.sql` defines the tables, constraints, grants, and row-level security policies.
- Test mode uses separate local-storage keys and disables Supabase connections so regression tests cannot read or overwrite guest data.

## Privacy And Security

- Rider metrics and performance history are personal data. Do not commit an individual's profile or test history into the public static source.
- Supabase row-level security must remain enabled, with each operation constrained by `auth.uid()`.
- The publishable/anon key is expected to be visible in the browser and is safe only with restrictive RLS policies. Never include the `service_role` key in client code.
- Guest data is browser-local and does not sync between devices.
- Account deletion/data export are not implemented yet and remain follow-up work.

## Deployment And Activation

The public site is served from GitHub Pages at `https://mikkelsyska.github.io/trainingplan/`. Supabase cross-device sync is scaffolded but remains inactive until a project is created, the schema is applied, Auth redirect URLs are configured, and the project URL and publishable key are added to `supabase-config.js`.

After deploying a schema update to an existing Supabase project, apply the updated SQL before using new fields or tables.

## Verification

Run the browser regression suite at `https://mikkelsyska.github.io/trainingplan/tests/`. It covers profile-driven descriptions and calculations, profile validation/persistence, schedule spacing and hour budgets, FTP test replacement/history persistence and watt recalculation, workout completion persistence, route suggestions, and static RLS schema guards.

The browser suite does not test live Supabase Auth or database policies against a configured project. Those require a configured Supabase environment and an integration test account.