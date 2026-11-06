# CUT Sport implementation status

Last updated: 2026-11-06

## Delivered
- React 18 + Vite frontend with responsive CUT Sport interface.
- Existing Supabase project client integration using browser-safe publishable key variables.
- Public routes for home, sports, athlete cards, fixtures, news, shop, sponsors and account pages.
- Profile sign-in/sign-up and profile update.
- Browser-local shopping cart.
- Sponsor management screen guarded in the UI and protected by the existing database sponsor RLS policy.
- Athlete profile registration/edit screen that relies on the existing assigned-staff RLS policies. Newly inserted athlete profiles are explicitly set to `pending`.
- Public athlete directory cards only query records where `approval_status='approved'` and `profile_visibility='public'`.
- Public competition directory on each sport hub, using public-read competition records and showing season, status, dates, venue and description.
- Public team directory on each sport hub, using active teams only and showing team category, season, coach name and approved public athlete-profile counts where supplied.
- GitHub Actions workflow runs npm install and Vite production build on branch `App`.

## Backend facts verified
- Supabase project: `tnkykdfxzwaqzbichxcl`.
- Existing public tables have RLS enabled.
- 11 sport codes exist. At last count, teams, athletes, fixtures, articles, products, events and sponsors had zero records.
- Athlete insert/update/delete policies call `private.can_manage_athlete(sport_id, team_id)`, which checks active sport/team assignments and super-admin role.
- Sponsor management policy allows `sport_admin` and `super_admin`.
- No Edge Functions currently exist in the project.
- Latest security advisor returned no findings. Performance advisor reports existing notices: 19 unindexed foreign keys, 11 RLS auth initplan notices, 18 unused-index notices, and one multiple-permissive-policy notice on sponsors. These were not changed because they require a separate reviewed database-performance pass.
- No schema, RLS or production data changes were made in this development pass.

## Not yet implemented / gated
- Team, competition, fixture, article, event, product and sport-code CRUD: no suitable write policies were verified for these tables.
- Athlete approval/verification, statistics, achievements and media moderation: require a reviewed workflow and corresponding scoped policies.
- Payment and atomic order creation: no payment gateway configured.
- Secure ticket issuance, QR generation and redemption: requires server-side signed tokens and validation.
- Student/staff discounts: requires approved institutional eligibility rules.
- Live browser walkthrough and real administrator-account CRUD test remain outstanding.

## Security constraints
- Never expose service-role or secret keys in Vite.
- Never bypass or disable RLS.
- Never insert invented athlete, team, fixture, competition, article, event, sponsor or product records.
- Keep server-authoritative actions on trusted backend functions.


## Admin publishing dashboard — 2026-11-06

- Added a role-aware admin landing page at `/admin`.
- Existing sponsor management is now at `/admin/sponsors`; athlete management remains at `/admin/athletes`.
- Dashboard modules are shown by the signed-in user's database role. Coach access is limited to athlete profiles; sport admins and super admins see sponsor and planned sport-operations modules; shop admins see a planned shop module.
- Dashboard counts are sourced from records already loaded through the app's public/read-scoped API. They are not an authorization mechanism.
- Planned team, competition, fixture, editorial, event, shop, payment and ticket administration remains unavailable until the corresponding database write permissions and server-side rules have been designed, reviewed and tested.
- No Supabase schema, grants, RLS policies, Edge Functions, roles or data were changed for this dashboard.
