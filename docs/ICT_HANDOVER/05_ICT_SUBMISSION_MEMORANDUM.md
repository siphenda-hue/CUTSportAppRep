# CUT Sport Application — ICT Technical Review Submission

**To:** Central University of Technology ICT Department  
**From:** CUT Sport Application Project  
**Date:** 25 November 2026  
**Subject:** Request for technical architecture, cybersecurity, privacy and deployment review

## 1. Purpose

The CUT Sport application is being developed as a central digital platform for CUT Sport information, athlete and team profiles, fixtures, competitions, historical sport records, news, events, recruitment, team communication, media, ticketing and online shop workflows.

The project team is submitting the current technical documentation to CUT ICT for an independent review of the application's architecture, data model, security controls, privacy risks, infrastructure and readiness for institutional deployment.

## 2. Documents submitted

1. System and Data Architecture
2. Security Architecture and Review
3. Migration and Release Reconciliation
4. ICT Review and Approval Checklist

The documents describe the inspected GitHub `App` branch and connected Supabase project as at 25 November 2026.

## 3. Areas requiring ICT attention

The project specifically requests review of:
- Authentication, privileged roles and staff account lifecycle.
- Supabase RLS policies, client grants and team/sport-level authorisation.
- Three callable `SECURITY DEFINER` functions.
- Storage access for private team media and public player photographs.
- Yoco checkout, payment webhook verification and ticket redemption.
- Personal information handling, retention, consent and POPIA requirements.
- Database backup, restore, monitoring and incident response.
- Migration history consistency and safe release process.
- Netlify hosting, domain, deployment controls and production environment configuration.

## 4. Known issues disclosed for review

The current security advisor reports leaked-password protection is disabled and identifies three public-schema `SECURITY DEFINER` functions executable by signed-in users. The inspected functions have authentication checks and scoped/ownership checks, but require formal review and negative tests.

All 67 public-schema base tables observed have RLS enabled; two views use `security_invoker=true`. These facts do not replace policy-level testing.

The repository currently contains 198 migration SQL files, while Supabase reports 143 applied migration records. Twenty-one timestamp groups contain duplicate version prefixes. Name reconciliation found 19 applied migration names without a matching current-branch file name and 75 branch file names without a matching applied remote record. This needs SQL-level reconciliation before any database reset, baseline replay or production migration.

## 5. Requested ICT outcome

The project requests:
1. An assigned ICT technical reviewer and database/security contact.
2. Written findings with severity, remediation owner and target date.
3. Approval or conditions for the production architecture and hosting arrangement.
4. Confirmation of institutional requirements for POPIA, records retention, backups, security monitoring and incident response.
5. A controlled test plan and sign-off process before production launch.

## 6. Current build evidence

The admin dashboard navigation role alignment is committed on branch `App` at:

`c6d1ad138806a31632fd61fd69753be46a76a673`

Both GitHub Actions workflows passed for that commit:
- [CUT Sport CI](https://github.com/siphenda-hue/CUTSportAppRep/actions/runs/45603554557)
- [Frontend build](https://github.com/siphenda-hue/CUTSportAppRep/actions/runs/45603554560)

These are build checks only. They do not represent ICT approval, penetration-test completion, payment acceptance, migration approval or confirmation of a live production deployment.

## 7. Approval

| Reviewer | Name | Outcome / conditions | Date |
|---|---|---|---|
| ICT application architecture |  | Pending |  |
| Database / Supabase administration |  | Pending |  |
| Information Security |  | Pending |  |
| Information Officer / Privacy |  | Pending |  |
| Infrastructure / Hosting |  | Pending |  |
| CUT Sport business owner |  | Pending |  |

**Prepared for review. No production security certification or institutional approval is implied.**
