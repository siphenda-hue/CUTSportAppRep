# CUT Sport — Role and Access Control Matrix

**Snapshot date:** 25 November 2026  
**Purpose:** ICT review and test planning. This matrix describes intended application permissions from the current frontend modules and schema design; final authority is live RLS, database grants and server-side checks.

| Role | Intended access | Dashboard / workspace evidence | ICT validation |
|---|---|---|---|
| Public / anonymous | Read public sports, teams, current and previous-year season information, approved heritage records, public articles/events/sponsors/products and public athlete/player content. No private profile, messages, trials or team notes. | Public app routes and public read policies. | Test all public endpoints and direct REST calls, including column exposure. |
| Student | Own profile and authenticated student features; no staff administration. | Role enum `student`; profile/authentication records. | Confirm own-row isolation and no staff scope. |
| Athlete | Own athlete record, claims, messages and permitted resubmission workflows; public-facing approved records only for general visitors. | Athlete role and athlete self-service / resubmission workflows. | Test ownership, rejected-record correction and cross-user denial. |
| Coach | Assigned team/sport operations, roster, team season, athlete profiles within assignment, match statistics, performance, recruitment and reports where permitted. | Dashboard and component role gates. | Test active dates, sport/team scope and read/write separation. |
| Team manager | Assigned team season workspace, roster, athlete profile registration within managed team and scoped reports. | Dashboard exposes team season, roster, athlete profiles and reports; component checks assignments. | Test no cross-team reads/writes and assignment expiry. |
| Sport administrator | Assigned sport/team management, content, fixtures/competitions, athlete approvals, verification, recruitment, communications, honours and event operations according to explicit permissions. | Sport-admin dashboard modules. | Test sport scope, approval separation, audit trail and sensitive-note access. |
| Shop administrator | Product catalogue and shop-order fulfilment; no unrelated athlete/admin data. | Shop catalogue and orders modules. | Test order privacy, paid-state enforcement and separation from event ticket workflows. |
| Super administrator | Global platform administration, role/assignment oversight, player profile imports and privileged approvals. | Super-admin-only modules and global admin components. | Require MFA, dual control for role grants, audit logging and break-glass review. |

## Scope rules

- A role is not a blanket permission to all records. Coach/team-manager access must be scoped to active assignments and team/sport identifiers.
- Frontend module visibility improves usability but cannot replace RLS or server-side authorization.
- A user with multiple roles should receive the union of only those permissions that the database independently authorizes.
- Public season and heritage reads must not expose private student information, unpublished notes, contact details or pending/unapproved statistics.
- Team hub availability data must be limited to availability/status fields required for operations. Do not place diagnoses, medication or treatment details in these tables.

## Required test cases

1. Anonymous visitor calls SELECT/INSERT/UPDATE/DELETE directly against every sensitive table.
2. Coach A attempts access to Team B, including nested joins and storage object paths.
3. Team manager with expired assignment attempts access after `ends_on`.
4. Shop admin attempts access to athlete, profile, recruitment and team hub tables.
5. Athlete A attempts to read or modify Athlete B's data, message threads or rejected records.
6. Sport admin attempts global role escalation or access to unassigned sport.
7. Super-admin actions are audited and require MFA; disabled/offboarded staff lose access.
8. Public season archive reads current and previous year only, while public heritage data remains accessible as intended.
9. Direct Edge Function invocation without a valid user JWT or service authorization is rejected.
10. Private media object access without an authorized session or valid short-lived signed URL is rejected.
