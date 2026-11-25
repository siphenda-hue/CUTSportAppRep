# Memorandum: Request for ICT Architecture and Security Review — CUT Sport Application

**To:** Central University of Technology — ICT Department  
**Cc:** CUT Sport Department; Information Officer / Information Security (as applicable)  
**From:** CUT Sport Application Project Team  
**Date:** 25 November 2026  
**Subject:** Request for technical, data architecture and security review of the CUT Sport application

## Purpose

The CUT Sport project team requests an ICT review of the CUT Sport application before further institutional rollout. The application is intended to provide a public sports information and heritage platform, athlete/player profiles, team and competition administration, team-season collaboration, news and events, recruitment workflows, and shop/ticketing functionality.

## System overview

The frontend is built with React 18 and Vite 6. Supabase provides authentication, PostgreSQL, Row Level Security, storage and server-side Edge Functions. The source is maintained in the GitHub repository `siphenda-hue/CUTSportAppRep`, branch `App`. Netlify is the current frontend hosting target. Yoco is the planned payment integration and requires final provider and end-to-end validation.

## Requested ICT review areas

1. Confirm the proposed architecture, hosting and institutional ownership model.
2. Review database schema, relationships, migrations, data classification and data lifecycle.
3. Assess authentication, role-based access, Row Level Security, database grants, SECURITY DEFINER functions and Edge Functions.
4. Review private/public storage, media handling and personal-information exposure.
5. Assess POPIA implications, particularly cross-border processing due to the current Supabase project region.
6. Review payment processing, webhook security, auditability and reconciliation.
7. Confirm backup, recovery, monitoring, incident response, CI/CD and production deployment arrangements.

## Important findings disclosed for review

- Live catalog inspection found 67 public tables, all with RLS enabled; RLS is not forced on table owners.
- Supabase Security Advisor reports leaked-password protection disabled and three authenticated-callable SECURITY DEFINER functions.
- The repository currently contains 198 migration SQL files, while live Supabase records 143 applied migrations. The initial schema baseline is absent from the repository and duplicate migration timestamps exist. This requires reconciliation before a clean rebuild or automated replay.
- The Supabase project is hosted in `sa-east-1` (São Paulo, Brazil), which requires a formal cross-border data-transfer assessment by CUT's Information Officer/legal team.
- Yoco live credentials, webhook validation and full payment reconciliation remain subject to confirmation.

These findings are disclosed to support a transparent review; they are not represented as completed compliance or security certification.

## Documents supplied

- System and data architecture
- Database schema inventory (table/column and foreign-key catalogue)
- Security architecture and review findings
- Role and access control matrix
- Infrastructure and integration register
- Risk register and ICT acceptance checklist

## Requested outcome

We request that ICT nominate a technical reviewer and provide written feedback identifying: (a) approved architecture decisions, (b) mandatory remediation, (c) required institutional integrations or hosting changes, (d) privacy/security approvals, and (e) production go-live conditions. The project team will maintain a remediation register and provide evidence of closure for each item.

**No claim of POPIA compliance, penetration-test completion or institutional production approval is made by this submission.**
