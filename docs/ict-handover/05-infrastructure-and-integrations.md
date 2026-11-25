# CUT Sport — Infrastructure and Integration Register

**Snapshot date:** 25 November 2026

## 1. Platform inventory

| Component | Current observed configuration | Operational notes |
|---|---|---|
| Source repository | GitHub `siphenda-hue/CUTSportAppRep`, branch `App` | Latest dashboard commit at snapshot: `c6d1ad138806a31632fd61fd69753be46a76a673`. |
| Frontend | React 18.3.1, React DOM 18.3.1, React Router 6.28.0, Vite 6.4.1 | Static single-page application. Node 22 in CI. |
| Backend / database | Supabase project `CUT Sport`, PostgreSQL 17, region `sa-east-1` | Project status reported `ACTIVE_HEALTHY` at snapshot. |
| Authentication | Supabase Auth | Leaked-password protection was reported disabled by Security Advisor. MFA policy must be confirmed. |
| Object storage | `cut-sport-media` private; `player-profile-photos` public | Both configured with 50 MiB object limit; see security review. |
| Hosting | Netlify site `https://cutsportapp.netlify.app` | Site had previously been reported published while production deploys/Agent Runners were paused for operational credits. Current billing/deploy controls require live confirmation. |
| CI | GitHub Actions `CUT Sport CI` and `CUT Sport frontend build` | Both passed on commit `c6d1ad138806a31632fd61fd69753be46a76a673`. |

## 2. Edge Functions observed in repository

- `event-report` — event sales/attendee reporting workflow.
- `manage-shop-order` — shop-order management.
- `my-tickets` — user's ticket access.
- `redeem-ticket` — ticket gate redemption.
- `yoco-checkout` — checkout initiation.
- `yoco-webhook` — payment-provider webhook processing.

ICT should review each function for JWT verification, CORS allow-list, input validation, authorization, rate limits, secret access, error redaction, logging and replay protection. Never place service-role or Yoco secrets in Vite `VITE_*` variables or client bundles.

## 3. External integrations

| Integration | Purpose | Status / evidence | Required confirmation |
|---|---|---|---|
| Yoco | Shop checkout and event ticket payments | Database schema, checkout functions and webhook event table/migrations exist. | Confirm live merchant account, credentials, webhook signature validation, test/live mode, refund flow and end-to-end reconciliation. Provider documents/credentials are not included in this handover. |
| Netlify | Frontend hosting and deployment | Site URL is known; prior operational-credit notice paused production deploys and Agent Runners. | Verify current team billing, deployment controls, build environment, environment variables and rollback access. No deployment was triggered for this review. |
| GitHub Actions | CI and frontend build | Both workflows passed on the latest dashboard commit. | Review workflow token permissions and lockfile process; restrict write permissions to minimum. |
| Supabase Storage | Media and player portraits | Two buckets observed; one private, one public. | Verify bucket policies, file scanning, signed URL expiry, image metadata/privacy and deletion lifecycle. |

## 4. Build and deployment pipeline

The repository workflows use Node.js 22. The CI workflow installs locked dependencies with `npm ci`, audits migration filenames and builds Vite. The frontend build workflow currently declares `contents: write` and has a step that may commit/push a generated `package-lock.json`. ICT should consider committing the lockfile as a reviewed source artifact and reducing routine workflow token permissions to read-only.

Deployment is separate from GitHub build success. A green GitHub workflow does not mean Netlify production has deployed the commit. Confirm the deployed commit SHA in Netlify before announcing a release.

## 5. Secrets and configuration

The checked-in `.env.example` contains placeholders only for:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`

These are public client configuration values; the publishable key is not a substitute for RLS. Service-role keys, database passwords, Yoco secrets and webhook signing secrets must be stored only in server-side platform secret stores. Rotate any secret that has been exposed in chat, source control, build logs or client bundles.

## 6. Recovery and continuity items for ICT

- Confirm Supabase backup schedule, retention and point-in-time recovery entitlement.
- Conduct a restore test to a non-production project and record RPO/RTO.
- Document Netlify rollback and GitHub protected-branch procedures.
- Define incident response contacts, severity levels, breach assessment and notification process.
- Document operational owner for DNS/domain, certificates, hosting billing and provider account recovery.
