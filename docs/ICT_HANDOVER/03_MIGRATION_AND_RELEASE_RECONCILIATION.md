# CUT Sport — Migration and Release Reconciliation

**Snapshot:** 25 November 2026  
**Priority:** High — resolve before database reset, baseline replay or bulk schema deployment.

## 1. Finding

A comparison of the current GitHub `App` branch with the connected Supabase migration history found a material mismatch:

| Source | Count observed |
|---|---:|
| SQL files under `supabase/migrations/` on branch `App` | 198 |
| Applied migration records returned by Supabase | 143 |
| Unique timestamp prefixes in repository migration files | 168 |
| Timestamp groups used by more than one SQL file | 21 |

There are also migration-name differences between the repository and remote history. Some remote migration names are absent from the branch; some branch files are not represented in remote history. Some historical migration names contain an embedded timestamp, so a simple filename comparison is not enough to determine whether a migration is missing, renamed or superseded.

**This is not proof that 55 migrations are safe to apply.** The mismatch requires a migration-by-migration reconciliation using exact SQL content, schema state and migration history.

## 2. Duplicate timestamp groups

The following timestamp prefixes are shared by multiple SQL files:

- `20261111110000` (2 files)
- `20261111120000` (2 files)
- `20261111130000` (2 files)
- `20261111170000` (2 files)
- `20261111173000` (2 files)
- `20261111180000` (2 files)
- `20261111190000` (3 files)
- `20261111193000` (2 files)
- `20261111200000` (2 files)
- `20261111210000` (4 files)
- `20261111220000` (3 files)
- `20261111230000` (3 files)
- `20261111240000` (4 files)
- `20261111250000` (3 files)
- `20261111260000` (2 files)
- `20261111270000` (2 files)
- `20261111280000` (3 files)
- `20261111290000` (2 files)
- `20261111300000` (2 files)
- `20261111310000` (2 files)
- `20261111430000` (2 files)

Supabase migration ordering relies on unique version identifiers. Duplicate timestamps can make ordering, replay and environment parity ambiguous. The current GitHub Actions filename audit passed, but that does not demonstrate remote/local migration parity or safe replay.

## 3. Risk

Potential consequences include:
- A new environment may not be reproducible from the checked-in migration set.
- A migration could be applied twice, skipped or applied in an unintended order.
- A schema reset or baseline replay could lose data or fail partway through.
- Production and development databases may drift.
- Historical data imports may be mixed with schema migrations in a way that is difficult to reproduce.
- A reviewer may incorrectly infer that a successful frontend build proves the database is deployable.

## 4. Safe remediation procedure

1. Freeze schema deployment and do not run `db reset`, `db push`, bulk migration application or baseline replay against production.
2. Export the remote migration history and current schema definition to a secure, access-controlled review location.
3. Build a reconciliation worksheet with one row per repository SQL file: file name, timestamp, semantic name, checksum, DDL/DML classification, remote history match, and whether the resulting change is already present in the live schema.
4. Inspect each duplicate timestamp group and assign a unique, chronological version only after confirming execution order and dependencies.
5. Identify remote-applied migrations missing from the branch. Recover the exact original SQL from source control/backup if available; do not recreate them from names alone.
6. Identify branch files absent from remote history. Determine whether they are genuinely pending, already applied under another version, data-only imports, or obsolete.
7. Review any migration that imports historical sports data separately from schema changes. Preserve source URLs, evidence notes and reconciliation records.
8. Create a clean baseline only through an approved process with a verified database backup and a tested restore.
9. Test the full migration sequence against a disposable database and compare schema, constraints, views, functions, grants and RLS policies.
10. Obtain ICT/database-owner approval before production changes.

## 5. Release controls

Before any production release:
- Confirm the target branch and commit SHA.
- Confirm CI and frontend build passed for that exact SHA.
- Confirm migration parity and successful staging migration.
- Confirm environment variables and secrets are set in the hosting/provider consoles.
- Confirm rollback and database recovery procedures.
- Confirm payment provider mode and webhook endpoint.
- Obtain an approved maintenance window and change record.

## 6. Current release snapshot

The dashboard role-gate change at commit `c6d1ad138806a31632fd61fd69753be46a76a673` passed both:
- [CUT Sport CI](https://github.com/siphenda-hue/CUTSportAppRep/actions/runs/45603554557)
- [CUT Sport frontend build](https://github.com/siphenda-hue/CUTSportAppRep/actions/runs/45603554560)

These checks validate the configured CI/build jobs only. They do not resolve the migration reconciliation issue, certify the database security posture or prove that Netlify production deployment is currently available.
