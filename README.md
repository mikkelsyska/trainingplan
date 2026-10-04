# trainingplan

Zwift-focused FTP training plan published with GitHub Pages.

## Profiles and Sync

The page supports browser-only guest profiles. Cross-device profiles and workout progress use Supabase Auth and the Supabase database; GitHub Pages does not provide user accounts or shared storage by itself.

1. Create a Supabase project and enable email/password sign-in.
2. In Supabase Authentication URL Configuration, set the Site URL and allowed redirect URL to `https://mikkelsyska.github.io/trainingplan/`.
3. In the Supabase SQL editor, run [`supabase-schema.sql`](supabase-schema.sql). Row-level security limits profile and workout data to its owner.
4. Copy the project URL and publishable (anon) key into `supabase-config.js` as `url` and `anonKey`.
5. Commit and push `supabase-config.js` so GitHub Pages can load the public client configuration. Never put a Supabase `service_role` key in this file.
6. Visit the site, create an account, confirm the email if required, sign in, and fill in the rider profile. The profile and ride checkoffs will then load for that account on other devices after sign-in.

The Supabase URL and publishable key are visible in the browser by design. The database must have the supplied row-level security policies enabled; they prevent one signed-in user from reading or changing another user's data. Until Supabase is configured, profiles and progress remain in that browser only.
