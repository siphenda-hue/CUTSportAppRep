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
- Four Supabase Edge Functions are deployed: yoco-checkout, yoco-webhook, my-tickets and redeem-ticket. Yoco credentials and webhook secrets are not configured yet.
- Latest security advisor returned no findings. Performance advisor reports existing notices: 19 unindexed foreign keys, 11 RLS auth initplan notices, 18 unused-index notices, and one multiple-permissive-policy notice on sponsors. These were not changed because they require a separate reviewed database-performance pass.
- Admin operations, athlete approval and editorial RLS policies have now been applied through three tracked Supabase migrations. No production records were seeded or altered.

## Not yet implemented / gated
- Product and sport-code CRUD remains outstanding. Team, competition, fixture, article and event policy foundations plus initial management screens are implemented.
- Athlete profile, statistics, achievement and media approval controls are implemented. Database triggers enforce approver-only changes to verification fields.
- Yoco Checkout, server-priced order creation, stock reservation, signed webhook verification, signed ticket pass retrieval and one-time staff redemption are implemented. Real/sandbox transactions are gated on merchant credentials and webhook configuration.
- Camera-based QR scanning and automated expiry/release of abandoned checkout reservations remain outstanding.
- Student/staff discounts, refunds and delivery fulfilment: require approved institutional/business rules.
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
- Dashboard UI was initially delivered without schema changes; the subsequent permission rollout applied reviewed RLS, grants, triggers and migrations.


## Admin permission rollout — 2026-11-06

- Supabase migrations applied: `20261106004403_scoped_operations_athlete_approval_and_publishing`, `20261106004631_protect_athlete_visibility_and_index_result_submissions`, `20261106004647_allow_private_athlete_edits_without_approval`, `20261106004922_publish_reviewed_fixture_results_atomically`.
- Added scoped RLS for team, competition, fixture, article and event administration. Added fixture sport-link validation and coach/team-manager result submissions with sport-admin review and atomic publication of accepted official scores.
- Added database trigger guards to keep athlete/statistics/achievement/media approval fields under sport-admin/super-admin authority. Anonymous write grants were revoked from affected tables; RLS remains enabled.
- Added `/admin/operations`, `/admin/approvals` and `/admin/editorial` screens. Current frontend provides create flows and selected approval/publish actions; full edit/archive coverage remains in progress.
- Supabase security advisor: no findings. Performance advisor still reports unindexed foreign keys, 11 RLS auth initplan notices, unused-index notices and multiple permissive SELECT policy notices; new result-submission and event sport foreign keys have indexes.
- GitHub Actions production build passed after the JSX formatting correction. No authenticated CRUD/browser test has been run because no admin role or sport-assignment records are provisioned in the project.
- Data inventory remains empty for teams, competitions, fixtures, articles, events and result submissions. No invented CUT Sport data has been added.


## Yoco checkout and ticketing rollout — 2026-11-06

- Selected Yoco Checkout API as the payment provider.
- Applied Supabase migrations: `20261106005938_yoco_checkout_orders_and_ticket_inventory`, `20261106010014_yoco_checkout_request_idempotency`, and `20261106010233_add_service_role_policy_for_yoco_webhook_events`.
- Added server-authoritative order creation with product/ticket price lookup, stock reservation, checkout request idempotency, payment status reconciliation and ticket issuance after verified payment.
- Revoked direct anon/authenticated INSERT/UPDATE/DELETE privileges on orders, order_items and tickets. Public ticket-type reads are limited to active ticket types on published ticketed events; management is RLS-scoped.
- Deployed Edge Functions: `yoco-checkout` (JWT required), `yoco-webhook` (Yoco HMAC signature and 3-minute replay window; JWT disabled), `my-tickets` (JWT required), and `redeem-ticket` (JWT required; staff scope checked server-side).
- Added checkout, event ticket purchase, personal signed ticket display and staff ticket gate routes. Event administrators can create a General Admission ticket type when creating a ticketed event.
- Security regression SQL checks passed. Supabase security advisor returned no findings after adding a service-role-only policy for webhook receipts.
- Yoco API key, webhook signing secret, ticket signing secret and public app URL have not been configured. No sandbox or live payment was attempted. The app is not deployed to a public domain yet.
- Outstanding before production: configure Edge Function secrets, register Yoco webhook, run end-to-end sandbox tests, schedule abandoned reservation cleanup, and add camera-based QR scanning.
