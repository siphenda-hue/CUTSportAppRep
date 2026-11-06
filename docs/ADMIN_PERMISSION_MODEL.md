# CUT Sport administration permission model

**Status:** Design baseline only — no database changes have been applied  
**Reviewed against:** Supabase project `tnkykdfxzwaqzbichxcl`, current schema and RLS policies, 6 November 2026

## Security principles

1. The React role check controls navigation and presentation only. Supabase Row Level Security (RLS), grants and trusted server-side code must enforce every read and write.
2. Keep the publishable key in the browser. Never place a service-role or secret key in Vite environment variables or client bundles.
3. Preserve the current public read rules. Draft/private records must not become public through broad SELECT policies.
4. Use least privilege and scope staff access to the assigned sport and, where applicable, team.
5. Treat approval/publishing as a separate capability from drafting or editing.
6. Validate foreign-key relationships and state transitions on the server/database, not only in form controls.
7. Audit sensitive administrative actions without logging passwords, payment secrets or full payment credentials.
8. Use authenticated server-side payment-provider webhooks for payment confirmation; never accept a browser redirect as proof of payment.

## Existing database facts

- The project already has `user_roles` values including `student`, `athlete`, `coach`, `sport_admin`, `shop_admin` and `super_admin`.
- Sport assignments are represented by `sport_admin_profiles` and `sport_admin_assignments`; assignments can be sport-wide or team-scoped and include start/end dates and an active flag.
- `private.can_manage_athlete(sport_id, team_id)` currently allows a super admin or an active assigned sport administrator/team manager/coach to manage the matching athlete record.
- Public SELECT policies exist for active teams, competitions, fixtures, published articles, published events, active products and active sponsors.
- The inspected public write policies currently cover sponsor administration and assigned athlete-related records, plus user-owned actions such as comments and event RSVPs. There are no verified write policies for teams, competitions, fixtures, articles, events or products.
- Orders and tickets currently have user-owned read policies; no verified public-client order creation, payment confirmation or ticket issuance workflow exists.
- No Supabase Edge Functions are currently deployed.
- No user-role or sport-assignment records were present in the latest project inventory. A dashboard UI role alone will therefore not make an account an administrator.

## Target capability matrix

| Area | Roles proposed | Scope | Required enforcement |
|---|---|---|---|
| Teams | super_admin, sport_admin | Super admin global; sport admin assigned sport | RLS for insert/update/archive; validate sport ownership |
| Competitions | super_admin, sport_admin | Assigned sport | RLS for CRUD; validate competition sport and lifecycle |
| Fixtures/results | super_admin, sport_admin; coach/team manager may submit results | Assigned sport/team | RLS for CRUD; separate result submission/verification if required |
| Athlete profile editing | super_admin, assigned sport_admin, assigned team_manager/coach | Current assignment scope | Existing `can_manage_athlete` is the starting point |
| Athlete approval | super_admin, sport_admin (not ordinary coach/team manager by default) | Global or assigned sport | Dedicated approval capability; prevent editors changing approval fields |
| Athlete statistics/achievements/media | assigned sport_admin/coach for submission; sport_admin/super_admin for approval | Athlete's assigned sport/team | Separate submission and approval state transitions |
| Articles | super_admin, sport_admin, approved editor role if later introduced | Sport/global editorial scope | Draft/edit/publish/archive policies; public SELECT only for published |
| Events | super_admin, sport_admin | Global or assigned sport | Draft/publish policies; keep RSVP ownership separate |
| Products | super_admin, shop_admin | Shop catalogue | RLS CRUD; validate stock/price and archive rules |
| Orders | customer reads own; trusted server creates/updates | Own customer order; server-only payment transitions | Server-side order pricing, inventory and payment verification |
| Tickets | customer reads own ticket metadata; trusted server issues/redeems | Own ticket; event staff redemption scope | Server-only issuance and one-time redemption, no raw ticket secrets in public reads |

## Priority 1 — Admin publishing dashboard

- Completed in the frontend at `/admin`.
- Existing sponsor manager moved to `/admin/sponsors`.
- Existing athlete manager remains at `/admin/athletes`.
- Dashboard cards are role-aware, but do not grant access.
- New management areas remain marked as requiring permission setup until backend controls exist.

## Priority 2 — Fixture and sport operations management

**Backend gap:** teams, competitions and fixtures have public-read policies only.

Proposed implementation sequence:
1. Agree whether sport administrators can create teams/competitions/fixtures only inside assigned sports.
2. Decide whether coaches/team managers may submit scores and results, and whether a sport administrator must verify/publish them.
3. Add reviewed RLS policies for each operation, with both `USING` and `WITH CHECK` for updates and validation that a fixture's team, sport and competition belong together.
4. Add status transition rules (scheduled → live → completed/postponed/cancelled) and prevent inappropriate edits after final verification.
5. Add audit events for creation, rescheduling, score changes and result verification.
6. Implement the CRUD screens only after policy tests pass.

## Priority 3 — Athlete verification and performance records

**Backend gap:** assigned staff can currently update athlete records through `can_manage_athlete`; that policy does not by itself distinguish an editor from an approver.

Before building approval controls:
1. Define who may approve/reject an athlete profile and whether approval is limited to the sport assignment.
2. Enforce that permission at the database layer; ordinary coaches/team managers must not be able to self-approve by changing `approval_status`, `verified_by` or `verified_at`.
3. Keep profile editing and approval as separate operations.
4. Use the existing athlete competition, statistics, achievements and media tables, but preserve their separate approval/publication states.
5. Test cross-sport, cross-team, self-approval and anonymous-public-read cases.

## Priority 4 — News and event publishing

**Backend gap:** articles are public-readable only when published; events are public-readable only when published. No editor CRUD policies were verified.

Proposed workflow:
- Draft → review → published → archived for articles.
- Draft → published → cancelled/completed for events.
- Only approved publisher roles can change publication state.
- Validate dates, sport association, media URLs and event/ticketing configuration.
- Keep comments and user RSVPs separate from editorial permissions.

## Priority 5 — Payments and ticketing

**Backend gap:** no Edge Functions are deployed and no trusted payment workflow was verified.

Required architecture:
1. Select and approve a payment provider for South African transactions (provider decision and merchant onboarding are still outstanding).
2. Create orders server-side from product IDs and quantities; calculate prices from trusted database values and reserve/decrement stock transactionally.
3. Create the provider payment session server-side. The browser must never submit a trusted total or mark an order paid.
4. Verify signed provider webhooks server-side, handle retries idempotently and record payment references/status transitions.
5. Issue ticket records only after confirmed payment or an explicitly authorised complimentary-ticket action.
6. Generate high-entropy ticket tokens; store only hashes; expose only the minimum ticket metadata to the purchaser.
7. Redeem tickets through a trusted, authenticated, one-time server operation with event-staff authorization and replay protection.
8. Add refund, cancellation, reconciliation and audit paths before production launch.

## Required verification before enabling writes

- Test as anonymous, ordinary authenticated user, coach, team manager, sport administrator, shop administrator and super administrator.
- Test both allowed and denied operations, including cross-sport/team access and attempts to change ownership/scope fields.
- Test public visibility of drafts, pending athletes, private media and unpublished events.
- Run Supabase security and performance advisors after database changes.
- Confirm CI build and perform authenticated browser tests with provisioned test accounts.
- Do not seed fictional CUT Sport records to make screens look populated.

## Change log

- 2026-11-06: Initial permission model documented from live schema/policy inspection. No SQL changes applied.
