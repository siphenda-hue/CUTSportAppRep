# CUT Sport — ICT Handover Pack

**Snapshot date:** 25 November 2026  
**Repository:** `siphenda-hue/CUTSportAppRep`  
**Branch:** `App`  
**Status:** Working technical handover for ICT assessment — not a production security certification.

## Documents in this pack

1. [System and data architecture](01_SYSTEM_AND_DATA_ARCHITECTURE.md) — application topology, data domains, database inventory, key relationships, storage, integrations and data flows.
2. [Security architecture and review](02_SECURITY_ARCHITECTURE_AND_REVIEW.md) — trust boundaries, authentication, authorisation, RLS, edge-function controls, storage, privacy risks and ICT verification checklist.
3. [Migration and release reconciliation](03_MIGRATION_AND_RELEASE_RECONCILIATION.md) — migration-history mismatch, duplicate migration timestamps and safe remediation requirements.
4. [ICT review checklist](04_ICT_REVIEW_CHECKLIST.md) — items for ICT, Information Security, Infrastructure and Information Officer review.

## Evidence and status labels

- **Observed:** read directly from the current `App` branch or connected Supabase project on the snapshot date.
- **Build verified:** a GitHub Actions build or CI workflow passed for the cited commit.
- **Needs validation:** configuration or behaviour requires controlled test evidence, an administrator review or a provider-console check.
- **Not confirmed:** the available connection did not establish the control. Do not treat it as implemented.

## Important limitations

- This is a technical description of the inspected branch and connected database. It is not a penetration-test report, POPIA compliance certificate, institutional risk acceptance or proof of production deployment.
- The dashboard navigation was aligned to the role checks in the inspected React components. Supabase RLS and server-side checks remain the actual data-access controls.
- No production deployment, payment transaction, credential rotation, database policy change or migration replay was performed as part of this documentation snapshot.
- Migration parity requires reconciliation before any database reset, baseline replay or bulk migration application.
- ICT should verify the live Netlify site and project billing/deployment state directly before authorising release.

## Snapshot commit

The dashboard role-gate alignment is recorded at commit `c6d1ad138806a31632fd61fd69753be46a76a673`. Both CI and frontend build workflows passed for that commit:
- [CI run](https://github.com/siphenda-hue/CUTSportAppRep/actions/runs/45603554557)
- [Frontend build](https://github.com/siphenda-hue/CUTSportAppRep/actions/runs/45603554560)
