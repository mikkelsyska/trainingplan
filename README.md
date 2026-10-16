# trainingplan

Zwift-focused FTP training plan published with GitHub Pages.

## Profiles and Sync

The page supports browser-only guest profiles. Cross-device profiles, FTP test history, schedule preferences, and workout progress use Supabase Auth and the Supabase database; GitHub Pages does not provide user accounts or shared storage by itself.

1. Create a Supabase project and enable email/password sign-in.
2. In Supabase Authentication URL Configuration, set the Site URL and allowed redirect URL to `https://mikkelsyska.github.io/trainingplan/`.
3. In the Supabase SQL editor, run [`supabase-schema.sql`](supabase-schema.sql). Re-run it for existing projects to migrate saved schedules to include Wednesday and permit the new workout completion index. Row-level security limits profile and workout data to its owner.
4. Copy the project URL and publishable (anon) key into `supabase-config.js` as `url` and `anonKey`.
5. Commit and push `supabase-config.js` so GitHub Pages can load the public client configuration. Never put a Supabase `service_role` key in this file.
6. Visit the site, create an account, confirm the email if required, sign in, fill in the rider profile and schedule, and log FTP tests. Those records will then load for that account on other devices after sign-in.

The Supabase URL and publishable key are visible in the browser by design. The database must have the supplied row-level security policies enabled; they prevent one signed-in user from reading or changing another user's data. Until Supabase is configured, profiles and progress remain in that browser only.

Rider profiles also store weekly hours and 4–5 available cycling days. Monday and Friday are fixed cycling-focused strength sessions, using bodyweight exercises and at most one kettlebell; Wednesday is reserved for an easy Zone 2 ride. Three selected non-Wednesday days carry the key cycling sessions, with a required rest day between key rides. A fifth selected cycling day can add optional recovery if it fits the hour budget. An FTP retest updates the current profile FTP and future watt guidance; it does not change workouts already completed, and Zwift's own FTP must still be updated separately. Test history is stored by date, with one result per day.

Monday and Friday strength cards open exercise guides with pictures, sets/reps, technique cues, and common form cautions. Friday's session is intentionally short and low-fatigue before Saturday's ride. Exercise photos come from the public-domain [Free Exercise DB](https://github.com/yuhonas/free-exercise-db).

## Tests

Run the dependency-free browser regression suite at `https://mikkelsyska.github.io/trainingplan/tests/`, or serve the repository root locally and open `/tests/`. Select **Run Tests** to exercise profile calculations and validation, schedule spacing and hour budgets, strength exercise guides, FTP history and watt recalculation, reload persistence, per-week progress, route coverage, and the RLS schema guards. The suite uses isolated test storage and does not clear guest data. It checks the schema text but does not replace testing against a configured Supabase project.
