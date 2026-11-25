# CUT Sport — Security Architecture and Review Findings

**Snapshot date:** 25 November 2026  
**Environment:** Supabase project `tnkykdfxzwaqzbichxcl`  
**Classification:** Internal — ICT and authorized project reviewers.

## 1. Current controls observed

| Control | Observed state | Evidence / qualification |
|---|---|---|
| PostgreSQL Row Level Security | 67/67 public tables enabled; 0 disabled | Live catalog inspection. RLS is not forced for table owners. |
| Database TLS setting | Enabled | PostgreSQL setting `ssl=on`; external TLS configuration should also be verified. |
| Password hashing | SCRAM-SHA-256 | PostgreSQL `password_encryption=scram-sha-256`; this is not the same as Supabase Auth leaked-password protection. |
| Client grants | Restricted by migration | Migration `20261116091552_restrict_anonymous_and_client_table_privileges` is present in repository; verify live grants and test exposed endpoints. |
| Private media bucket | `cut-sport-media` is private | 50 MiB limit and allow-listed image/video/PDF MIME types. Validate object policies and signed URL expiry. |
| Public profile-photo bucket | `player-profile-photos` is public | 50 MiB limit; JPEG/PNG/WebP. Public access means object URLs may be accessible to anyone; only approved/public portraits should be placed here. |
| Payment webhook records | `yoco_webhook_events` has RLS; service-role-only policy observed | Confirm webhook signature verification, replay handling and idempotency in deployed Edge Function. |
| CI build | Passing on latest dashboard commit | GitHub Actions CI and frontend build succeeded for `c6d1ad138806a31632fd61fd69753be46a76a673`. Build success is not a security test. |

## 2. Authentication and authorization model

The application role enum currently contains: `student`, `athlete`, `coach`, `sport_admin`, `shop_admin`, `super_admin`. The frontend dashboard conditionally exposes modules according to these roles. Sport/team staff scope is represented through assignment tables. The authoritative access boundary must remain database grants, RLS policies and carefully reviewed server-side functions—not client-side conditional rendering.

Recommended ICT acceptance tests:

- Anonymous user cannot read profiles, contact details, messages, private trial evaluations, team notes, attendance or private media.
- A coach/team manager cannot read or modify another team outside active assignments.
- A sport administrator cannot manage a sport outside assigned scope.
- A shop administrator can manage the shop domain but cannot read athlete or staff private data.
- A student/athlete can access only their own private profile, messages, claims and permitted submissions.
- A super administrator has explicit, audited privileged access; role assignment itself is protected from ordinary administrators.
- Public season and heritage reads do not expose private student information, unpublished notes, contact details or pending/unapproved statistics.

## 3. SECURITY DEFINER functions requiring review

Supabase Security Advisor reported **three authenticated-callable SECURITY DEFINER functions**. Their definitions were inspected; all three pin `search_path` to an empty value and use schema-qualified object names. The following authorization checks are visible in source, but this is not a substitute for adversarial tests:

| Function | Intended purpose | Observed checks | Required action |
|---|---|---|---|
| `match_statistics_submitters()` | Return submitter identity/time for match-statistics review | Requires non-null `auth.uid()`; filters records through `private.can_manage_athlete(sport_id, team_id)`. | Confirm callers are only assigned reviewers and returned names are not overexposed. Consider moving to a private schema or using invoker rights if possible. |
| `register_player_to_team_from_qr(uuid, uuid)` | Register a claimed public player profile to an active team | Requires authenticated user, active team, `private.can_manage_athlete`, public/claimed profile, duplicate handling and membership upsert. | Test forged profile/team IDs, concurrent requests, duplicate membership and assignment expiry. Keep function execute grant narrowly scoped. |
| `resubmit_athlete_record(text, uuid, jsonb)` | Let an athlete correct a rejected record | Requires authenticated user; matches record to `profile_id=auth.uid()`; allow-lists editable fields; resets approval state; rejects unsupported types. | Test every record type, JSON type edge cases, cross-user IDs, field injection and review/audit side effects. Keep execute grant narrow. |

The Security Advisor warning is about authenticated users being able to execute SECURITY DEFINER functions. This may be intentional for these workflows, but ICT must approve the elevated execution model and verify least privilege. Do not revoke grants or change function security mode without regression testing.

## 4. Outstanding Security Advisor findings

1. **Leaked-password protection disabled.** Enable Supabase Auth leaked-password protection after confirming user-impact and support procedures.
2. **Three SECURITY DEFINER functions callable by authenticated users.** Complete the function-by-function review and record approval or remediation.

## 5. Data protection and privacy

Potential personal information includes name, email, phone, student number, avatar/photo, athlete status, faculty/qualification/year of study, messages, recruitment applications, trial scores, staff notes and attendance. Treat these as restricted institutional data. Define lawful purpose, minimum fields, notices, access roles, retention, correction/deletion workflow, audit access and incident escalation with CUT's Information Officer / privacy office.

The Supabase project region is `sa-east-1` (São Paulo, Brazil). CUT ICT and the Information Officer must assess cross-border processing and POPIA section 72 requirements, including the applicable transfer basis, contracts and safeguards. This document does not assert POPIA compliance.

## 6. Security configuration recommendations

- Require MFA for super administrators and privileged staff; verify recovery and account offboarding procedures.
- Enable leaked-password protection and define a strong password / session policy.
- Review RLS policies and grants together; verify no broad `anon` or `authenticated` table grants bypass intended policies.
- Review SECURITY DEFINER functions, Edge Functions and storage policies. Verify JWT validation, service-role isolation, input validation and rate limiting.
- Verify payment webhook signature checks, idempotency, replay rejection, amount/currency matching and audit trail.
- Configure monitoring for authentication failures, role changes, privileged writes, webhook failures and suspicious access; define retention and alert owners.
- Verify backups, point-in-time recovery availability, restore tests and RPO/RTO with the Supabase plan.
- Establish vulnerability/dependency scanning and periodic penetration testing before institutional launch.

## 7. Evidence and scope

Live catalog inspection found 67 RLS-enabled public tables and 0 tables with FORCE ROW LEVEL SECURITY. This is structural evidence only: a table having RLS enabled does not prove every policy is correct. No penetration test or negative-permission matrix has been run as part of this review.
