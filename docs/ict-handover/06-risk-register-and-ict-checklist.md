# CUT Sport — Risk Register and ICT Acceptance Checklist

**Snapshot date:** 25 November 2026  
**Status:** Open items require ICT owner, due date and closure evidence.

## 1. Risk register

| ID | Priority | Risk / observation | Impact | Recommended treatment | Status |
|---|---|---|---|---|---|
| R-01 | Critical | Database migration history does not reconcile: live Supabase reports 143 applied migrations (first recorded `20261101215551_initial_cut_sport_schema`), while repository contains 198 SQL migration files; the repository does not contain the initial schema migration and many versions/names differ. | New environment rebuild, disaster recovery or schema replay may fail or produce drift. | Freeze schema changes until ICT and project owner reconcile the canonical baseline. Produce a clean baseline or documented migration reconciliation in a separate reviewed branch; test a fresh database replay before deployment. | Open — blocker |
| R-02 | High | 21 duplicate migration timestamps exist in repository filenames. | Ordering ambiguity and migration tooling compatibility risk. | Rename/resequence files with a reviewed migration strategy; do not alter already-applied version history casually. | Open |
| R-03 | High | Supabase Auth leaked-password protection is disabled. | Users may choose compromised passwords. | Enable after testing user impact and support process. | Open |
| R-04 | High | Three authenticated-callable SECURITY DEFINER functions trigger Security Advisor warnings. | Elevated database execution may bypass ordinary caller privileges if function logic is flawed. | Function-specific security review, adversarial tests, least-privilege grants and documented approval. | Open — review required |
| R-05 | High | Supabase project region is `sa-east-1` (São Paulo, Brazil). | Cross-border processing of South African personal information may require additional POPIA assessment and safeguards. | CUT Information Officer/legal review of POPIA section 72 basis, contracts, safeguards and notices. | Open |
| R-06 | High | RLS is enabled on all 67 inspected public tables but FORCE RLS is enabled on 0. | Table owners / privileged service credentials remain outside normal RLS enforcement. | Review privileged roles, service-role use, ownership, Edge Function paths and direct SQL access. Do not assume RLS alone covers privileged operations. | Open — validate |
| R-07 | High | `player-profile-photos` storage bucket is public. | Any object placed there may be publicly retrievable by URL. | Limit contents to approved public portraits; verify upload/write policies and approval workflow; use private bucket for sensitive media. | Open — validate |
| R-08 | High | Payment provider configuration and end-to-end Yoco flows are not confirmed in this audit. | Incorrect payment status, replay, duplicate fulfilment or ticket issuance risk. | Test signed webhook, amount/currency/order binding, idempotency, refunds, reconciliation and failure paths in sandbox and live approval process. | Open |
| R-09 | Medium | Build workflow declares `contents: write` and may push a generated lockfile. | Excessive CI token permissions and supply-chain blast radius. | Commit lockfile manually through review; set CI workflow permissions to least privilege. | Open |
| R-10 | Medium | Backup/restore, monitoring, incident response and retention settings were not verified. | Recovery delay, undetected abuse and unclear privacy response. | Confirm plan entitlements, backup retention, restore test, logging, alerts and owners. | Open |
| R-11 | Medium | Historical records and athlete data have quality/identity reconciliation needs, including unresolved canonical links and unapproved player statistics. | Incorrect public career or competition records. | Keep uncertain records unpublished; use evidence-backed review, audit trail and controlled approvals. | Ongoing |
| R-12 | Medium | Sensitive student/athlete information may include contact details, student numbers, education details, messages, recruitment scores, notes and attendance. | Privacy exposure or excessive retention. | Data classification, minimization, purpose limitation, retention schedule, access review and data-subject process. | Open |

## 2. Migration reconciliation detail

The current repository contains **198** `.sql` files under `supabase/migrations`; the live Supabase migration history reports **143** applied entries. The repository begins at `20261106004403` and has no checked-in `initial_cut_sport_schema` baseline, while the live database records its initial schema migration as `20261101215551`. At least **21 version timestamps are duplicated** among repository filenames. A comparison of version identifiers found 100 live applied versions not represented in the repository and 155 repository file versions not represented in the live migration history. This must be resolved before a fresh-project deployment or automated migration replay is approved.

## 3. ICT acceptance checklist

- [ ] Confirm business owner, technical owner, data owner and emergency contacts.
- [ ] Approve the system architecture and data classification.
- [ ] Reconcile all migrations; prove a clean database can be created from source and compared with production schema.
- [ ] Review all RLS policies and table grants, including anon/authenticated access and direct REST calls.
- [ ] Review all SECURITY DEFINER functions and every Edge Function.
- [ ] Test role isolation for public, student, athlete, coach, team manager, sport admin, shop admin and super admin.
- [ ] Require MFA for privileged accounts and enable leaked-password protection.
- [ ] Approve storage bucket exposure, upload validation, file scanning and signed URL policies.
- [ ] Complete Yoco sandbox and production readiness review, including webhook signatures and idempotency.
- [ ] Assess POPIA cross-border processing, lawful basis, privacy notices, operator agreements and retention.
- [ ] Confirm backups, recovery objectives and a successful restore test.
- [ ] Confirm CI token permissions, dependency scanning, branch protection and release approval.
- [ ] Verify Netlify production environment variables, deployment controls, rollback and billing owner.
- [ ] Complete vulnerability scan / penetration test and close findings.
- [ ] Sign off production readiness and record residual risks accepted by CUT.

## 4. Go-live recommendation

**Do not treat this handover as production security sign-off.** The migration-history discrepancy, leaked-password protection and privileged-function review are material open items. ICT should review and assign owners before production expansion or a fresh deployment.
