# CUT Sport — ICT Review and Approval Checklist

**Prepared for:** Central University of Technology ICT Department  
**Snapshot date:** 25 November 2026  
**Purpose:** Technical assessment before production approval.

## A. Application and architecture

- [ ] Review [System and Data Architecture](01_SYSTEM_AND_DATA_ARCHITECTURE.md).
- [ ] Confirm repository ownership, branch strategy, code review and protected-branch rules.
- [ ] Confirm Netlify project ownership, current billing/deploy status, domain/DNS and production environment.
- [ ] Confirm Supabase project ownership, region, plan, PostgreSQL version and administrative access.
- [ ] Confirm development, staging and production environments are appropriately separated.

## B. Identity and access

- [ ] Approve the application role model: public, player, coach, team manager, sport admin, shop admin and super admin.
- [ ] Confirm how roles are granted, reviewed, time-limited and revoked.
- [ ] Require MFA for privileged accounts.
- [ ] Enable leaked-password protection.
- [ ] Review password reset, email verification, session lifetime and account recovery.
- [ ] Verify that role checks do not rely on user-editable metadata.

## C. Database and application security

- [ ] Review all RLS policies and client grants.
- [ ] Test anonymous access to public and private data.
- [ ] Test user ownership and cross-user access denial.
- [ ] Test coach/team-manager scope across multiple teams and sports.
- [ ] Test sport-admin assignment boundaries.
- [ ] Test shop-admin isolation from sport/athlete records.
- [ ] Review all three public SECURITY DEFINER functions.
- [ ] Review both security-invoker views.
- [ ] Confirm privileged service-role credentials are not present in browser bundles or Git history.
- [ ] Review SQL injection, IDOR/BOLA, mass assignment and input validation risks.

## D. Files and privacy

- [ ] Review policies for `cut-sport-media` and `player-profile-photos`.
- [ ] Confirm private media cannot be accessed by unauthorised users.
- [ ] Approve image consent, moderation, retention and takedown processes.
- [ ] Complete POPIA/privacy impact assessment with the Information Officer.
- [ ] Approve retention periods for student records, trial applications, attendance, messages, availability and development notes.
- [ ] Confirm data-subject access/correction/deletion workflows.
- [ ] Review third-party operator/sub-processor and cross-border processing terms.

## E. Payments and integrations

- [ ] Confirm Yoco account ownership and production readiness.
- [ ] Test signed webhook validation, replay prevention and idempotent payment reconciliation.
- [ ] Test amount/currency mismatches, cancelled/expired checkouts and duplicate events.
- [ ] Confirm no cardholder data is collected or stored by CUT Sport.
- [ ] Test ticket issuance, token validation and one-time redemption.
- [ ] Review Edge Function CORS, rate limiting, logs and error responses.
- [ ] Confirm secrets are stored only in provider secret managers.

## F. Data, migrations and resilience

- [ ] Resolve the migration mismatch and duplicate timestamp groups.
- [ ] Confirm a reproducible clean database build.
- [ ] Test staging migration and rollback.
- [ ] Confirm backup schedule, retention and point-in-time recovery.
- [ ] Perform a restore drill and document recovery time and recovery point objectives.
- [ ] Confirm database and application monitoring, alerting and incident response.
- [ ] Confirm audit-log retention and restricted access.

## G. Release approval

- [ ] CI and frontend build passed for the exact release commit.
- [ ] Role-based and RLS negative tests passed.
- [ ] Security review findings have owners and due dates.
- [ ] Penetration/security test completed or formally risk-accepted.
- [ ] Privacy review completed.
- [ ] Migration and backup/restore evidence accepted.
- [ ] Payment and ticketing acceptance tests passed.
- [ ] Netlify production deployment and rollback verified.
- [ ] Change request, maintenance window and responsible approvers recorded.

## Approval record

| Role | Name | Decision | Date |
|---|---|---|---|
| CUT ICT application owner |  | Pending |  |
| Database administrator |  | Pending |  |
| Information Security |  | Pending |  |
| Information Officer / Privacy |  | Pending |  |
| CUT Sport business owner |  | Pending |  |

**Important:** Completing this checklist is an institutional review activity. The existence of this document does not mean the application has passed or received approval.
