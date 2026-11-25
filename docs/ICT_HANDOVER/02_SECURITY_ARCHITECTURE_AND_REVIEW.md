# CUT Sport — Security Architecture and Review

**Version:** 0.1  
**Snapshot:** 25 November 2026  
**Review status:** Initial technical review; formal ICT validation required.

## 1. Executive security summary

The application uses Supabase Auth, PostgreSQL Row Level Security (RLS), role/scope checks in selected Edge Functions, private Storage for team media and server-side payment workflows. The inspected public schema has RLS enabled on all 67 base tables and contains 203 RLS policies. Two public views use `security_invoker=true`.

The security review also identified outstanding items:
- Supabase Auth leaked-password protection is disabled.
- Three public-schema `SECURITY DEFINER` functions are executable by signed-in users and require formal review of their privileged behaviour and intended callers.
- Public bucket `player-profile-photos` needs documented moderation, consent and takedown controls.
- RLS is enabled but not forced on table owners; owner/service-role access must remain tightly controlled.
- Migration history does not currently reconcile cleanly with the repository (see migration report).
- Role-based end-to-end testing, backup restore testing, privacy review and production hosting verification remain outstanding.

No database policies, Auth settings, provider credentials or production configuration were changed during this review.

## 2. Trust boundaries

| Boundary | Trust assumption | Required control |
|---|---|---|
| Public browser | Untrusted; users can alter requests and route URLs | Publishable key only; RLS/grants; server-side validation |
| Signed-in browser | Authenticated identity, but not automatically authorised | Verify JWT and role/scope; never trust user metadata for privileges |
| Supabase Data API | Exposed database interface | Least-privilege grants, RLS on exposed tables, policy tests |
| Edge Functions | Server-side execution with privileged secrets | Validate JWT, authorise every request, input validation, rate limiting, safe errors |
| Service-role database client | Highly privileged; bypasses RLS | Keep server-side only; narrowly scoped code; rotate on suspected exposure |
| Storage | Files can contain personal/institutional content | Private buckets, object policies, signed URLs, file type/size checks, malware/content review |
| Yoco | External payment processor | Signed webhooks, amount/currency reconciliation, idempotency, no card data in CUT Sport |
| Netlify/GitHub | Build and deployment supply chain | Protected branch, dependency lock, secret scanning, deployment approval and audit |

## 3. Authentication and identity

Observed frontend configuration:
- Supabase client uses `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
- Auth session persistence, automatic token refresh and session detection are enabled.
- `.env.example` contains placeholder values only.
- The inspected browser client does not include a service-role key.

Required ICT checks:
- Confirm MFA is enabled/required for privileged staff accounts.
- Enable leaked-password protection in Supabase Auth.
- Review password policy, email verification, recovery flow, session lifetime and refresh-token behaviour.
- Confirm deprovisioning removes roles and staff assignments promptly and revokes sessions where required.
- Ensure authorisation never relies on user-editable `user_metadata`; privileged roles must come from trusted database records or server-controlled app metadata.
- Test stale JWT behaviour after role revocation.

## 4. Role and scope model

The current frontend uses these application roles:
- `super_admin`
- `sport_admin`
- `coach`
- `team_manager`
- `shop_admin`

The `user_roles` table has a unique constraint on `(user_id, role)`. Sport administrators have scoped assignments in `sport_admin_assignments`; team/staff relationships are also represented in staff assignment/profile tables.

### Intended access matrix (must be validated against RLS)

| Capability | Public visitor | Player / signed-in user | Coach | Team manager | Sport admin | Shop admin | Super admin |
|---|---:|---:|---:|---:|---:|---:|---:|
| Published sports, teams, competitions and heritage | Read | Read | Read | Read | Read | Read | Read |
| Own profile, orders, tickets, notifications | — | Own only | Own only | Own only | Own only | Own only | Own only |
| Assigned team season hub and roster | — | Own team/member scope | Assigned scope | Assigned scope | Assigned scope/all per policy | — | All |
| Athlete registration/profile work | — | Self-service where allowed | Assigned scope | Assignment-checked workspace | Assigned scope | — | All |
| Match stats and performance administration | — | Submit own records where allowed | Assigned scope | Not shown in current dashboard | Assigned scope | — | All |
| Athlete verification/approvals | — | Own status only | Component allows coach review; verify scope | Not shown | Assigned scope | — | All |
| Recruitment and trial evaluation | Read published opportunities | Own application | Assigned scope | Not shown | Assigned scope | — | All |
| International records, player awards, competition honours | Approved records only | Read approved profile data | Not shown | Not shown | Admin scope | — | All |
| Shop catalogue and shop orders | Published catalogue | Own checkout/order | — | — | — | Shop scope | All |
| Event sales and ticket gate | Public event details | Own ticket | — | — | Admin scope | — | All |

This is an intended matrix inferred from the current frontend module and component gates, not a certification of database policy behaviour. RLS remains authoritative. Team manager athlete-profile access is additionally assignment-checked in the component. Shop operations are handled by dedicated server-side role checks.

## 5. RLS and database privileges

Observed on 25 November 2026:
- 67/67 public-schema base tables have RLS enabled.
- No public-schema base table was found with RLS disabled.
- 0 tables have `FORCE ROW LEVEL SECURITY` enabled.
- 203 RLS policies exist across 67 tables.
- A recent migration is named `restrict_anonymous_and_client_table_privileges`.
- Two public views have `security_invoker=true`.

RLS enabled is a positive baseline, but does not prove the policies are correct. ICT should test:
- Anonymous read access is limited to approved/public records.
- Users cannot read or mutate another user's profile, orders, tickets, notifications, messages or applications.
- Coaches/team managers cannot cross assigned team/sport boundaries.
- Sport administrators cannot operate outside their assignment.
- Shop administrators cannot access unrelated sport/athlete data.
- UPDATE policies have both appropriate `USING` and `WITH CHECK` conditions.
- Client grants do not permit direct writes to protected payment, audit or review records.
- Table owners and service-role credentials are protected because they can bypass ordinary RLS enforcement.

## 6. SECURITY DEFINER functions

Three public-schema functions are flagged by Supabase's security advisor because authenticated users can execute them. Their ACLs observed in the database grant EXECUTE to `authenticated` and `service_role`; no `anon` grant was shown. Each function pins an empty search path and the inspected bodies contain no dynamic SQL execution.

| Function | Observed guard | Review conclusion |
|---|---|---|
| `match_statistics_submitters()` | Requires `auth.uid()` and calls `private.can_manage_athlete(sport_id, team_id)` | Staff-scoped submitter lookup; confirm returned names/rows are appropriate for each caller |
| `register_player_to_team_from_qr(uuid, uuid)` | Requires authenticated user and checks `private.can_manage_athlete` for the selected team; validates active team and claimed public profile | Privileged registration operation; test IDOR, race conditions, profile ownership and duplicate membership |
| `resubmit_athlete_record(text, uuid, jsonb)` | Requires `auth.uid()`; checks rejected record ownership against the caller's profile | Self-service correction workflow; test allowed fields, immutable columns, null handling and ownership across every record type |

Do not blindly revoke EXECUTE: the application may rely on these RPCs. ICT/database owner should review full definitions and callers, write negative tests, and either retain with documented justification or move/restrict the functions. Any modification must be migration-backed and regression-tested.

## 7. Auth configuration finding

<badge color="warning">Needs remediation</badge> **Leaked-password protection is disabled.**

Enable Supabase Auth leaked-password protection after confirming any plan/configuration dependencies. Verify sign-up, password change and reset flows after enabling it.

## 8. Edge Function security

Observed controls:
- Checkout, ticket, event-report and order-management functions validate the bearer session with `auth.getUser()`.
- Event report checks sport-admin/super-admin role and assignment scope before returning event attendee/report data.
- Shop-order management checks shop-admin/super-admin role, verifies successful payment and uses a controlled status-transition RPC.
- Ticket redemption verifies a signed ticket token and checks sport-admin assignment or super-admin status.
- Yoco webhook verifies HMAC signature and timestamp before processing payment events.
- Checkout validates HTTPS return URL, Yoco response amount/currency and the expected checkout hostname.
- Ticket tokens use HMAC; stored ticket codes are represented by hashes.
- Server-side service-role key is loaded from Edge Function environment variables.

Required validation:
- Restrict wildcard CORS origins to the actual application and approved operational origins where feasible.
- Add/confirm rate limits and abuse monitoring on public-facing function endpoints.
- Ensure every service-role query is preceded by explicit user/role/scope validation.
- Test webhook replay, duplicate delivery, stale timestamps, mismatched amount/currency, unknown checkout IDs and concurrent payment callbacks.
- Confirm provider secrets are configured only in server-side secrets and never committed.
- Verify Yoco test and live credentials separately; do not enable live payments until end-to-end reconciliation passes.

## 9. Storage and media security

Observed buckets:
- `cut-sport-media`: private, 50 MiB maximum, media/PDF MIME allowlist.
- `player-profile-photos`: public, 50 MiB maximum, image MIME allowlist.

Required controls:
- Validate Storage object policies for upload, read, update and delete separately.
- Restrict private team media by assigned team/season and reviewer scope.
- Use signed URLs for private previews and downloads; avoid persisting long-lived signed URLs.
- Validate file size, MIME type and content signatures; consider malware scanning.
- Define consent, image ownership, retention, takedown and subject-request procedures for student/athlete images.
- Review whether 50 MiB is appropriate for mobile uploads and hosting costs.
- Confirm no private athlete media is accidentally uploaded to the public photo bucket.

## 10. Privacy and POPIA considerations

The database contains or may contain personal information including names, contact details, student numbers, faculty/qualification/year-of-study, athlete biographies, photographs, team memberships, attendance, availability, trial applications/scores, messages and order/ticket history.

Before institutional approval, CUT's Information Officer and legal/privacy team should determine:
- Responsible party and operator roles, lawful purpose and processing basis.
- Appropriate privacy notices and consent/authorisation for student/athlete images and public profiles.
- Data minimisation and purpose limitation for student numbers and contact information.
- Retention/deletion periods for applications, messages, attendance, availability, development notes and reports.
- Data-subject access, correction, objection and deletion workflows.
- Breach response, incident notification and operator agreements.
- Cross-border hosting/processing and sub-processor arrangements.
- Whether any records require special handling or a formal privacy impact assessment.

Do not place medical diagnoses, treatment records or clinical information in the team availability feature.

## 11. Operational security and resilience

Not confirmed by this code/database inspection:
- Backup frequency, point-in-time recovery entitlement and retention.
- Restore-test evidence and recovery time/recovery point objectives.
- Database monitoring, alerting, log retention and incident escalation.
- Production environment separation and least-privilege staff access.
- Netlify deployment approvals, domain/DNS ownership and current operational-credit status.
- Vulnerability scanning, dependency review, secret scanning and penetration-test results.

ICT should request evidence from the relevant provider consoles and perform a restore drill before launch.

## 12. Security verification checklist

- [ ] Enable leaked-password protection.
- [ ] Review and sign off the three SECURITY DEFINER functions.
- [ ] Test RLS with anonymous and each role type, including cross-team and cross-sport negative tests.
- [ ] Review all Storage object policies and public photo exposure.
- [ ] Confirm service-role secrets exist only in Edge Function environment variables.
- [ ] Restrict/approve CORS origins and implement rate limiting.
- [ ] Test Yoco signature verification, replay handling and order reconciliation.
- [ ] Confirm MFA and privileged-account lifecycle.
- [ ] Complete privacy impact and POPIA review.
- [ ] Confirm backups and successfully restore to a non-production environment.
- [ ] Complete independent penetration/security testing.
- [ ] Obtain ICT approval before production deployment.
