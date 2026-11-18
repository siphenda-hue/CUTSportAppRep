# CUT Sport database portability readiness audit

**Reviewed:** 18 November 2026  
**Repository:** `siphenda-hue/CUTSportAppRep`  
**Branch:** `App`  
**Supabase project:** CUT Sport (`tnkykdfxzwaqzbichxcl`)  
**Scope:** Read-only repository and migration-history inspection. No database writes or deployments were performed.

## 1. Executive result

The project uses PostgreSQL, which is a strong foundation for moving the database to another managed or self-managed PostgreSQL service. However, **the database is not yet migration-portability-ready**. The most important blocker is a mismatch between the repository's SQL migration filenames and the live Supabase migration ledger.

### Findings verified during this review

| Check | Result |
|---|---|
| SQL files in `supabase/migrations/` | 198 |
| Duplicate 14-digit migration filename versions | 21 version groups |
| Rows in live `supabase_migrations.schema_migrations` | 143 |
| Distinct live migration versions | 143 |
| Live versions in 14-digit format | 143 |
| Supabase CLI project config at `supabase/config.toml` | Not present in branch at time of review |
| Dedicated backup/restore runbook | Not previously present |
| PostgreSQL portability architecture | Documented in `docs/ARCHITECTURE.md` |

The duplicate filename versions include multiple files sharing the same 14-digit prefix. Examples include `20261111110000`, `20261111120000`, `20261111190000`, `20261111210000`, `20261111220000`, `20261111230000` and `20261111240000`. The complete list should be obtained from the current Git tree during remediation rather than copied manually from this summary.

The live migration ledger has unique version values, but the applied migration names do not consistently match the current repository filenames. Some live ledger names contain timestamp-prefixed text in the name field. This suggests the source migration files were renamed/re-timestamped after some migrations were applied, or were applied through a different migration workflow. It must be reconciled before relying on a fresh database replay.

## 2. Why this matters

Supabase migration history uses migration version identifiers. Two repository files with the same version prefix cannot safely represent two independently ordered migrations. A fresh environment may reject, misorder or ambiguously reconcile these files.

The live project has 143 unique applied migration versions, while the current repository has 198 migration files. The counts alone do not establish which 55 files are unapplied: filenames and ledger names must be compared using the full migration contents and Git history. **Do not infer that any file is safe to apply just because its current filename is absent from the ledger.**

## 3. Immediate safeguards

Until the migration reconciliation is complete:

1. Do not run `supabase db push`, `supabase migration repair`, `supabase db reset` or any bulk migration operation against production.
2. Do not rename or delete historical SQL migration files.
3. Do not edit the live `supabase_migrations.schema_migrations` table manually.
4. Do not create a new production migration until its version is unique and the current ledger/source relationship is understood.
5. Keep all new schema changes in reviewed, version-controlled SQL migration files.
6. Make and verify an independent encrypted backup before any schema reconciliation or infrastructure migration.

This audit is a blocker report, not a request to change the production database.

## 4. Reconciliation procedure

Perform this in a disposable staging project/database first.

### Step 1 — Freeze and preserve evidence

- Record the Git commit SHA and branch used for the audit.
- Export the full list of migration filenames and their file contents/checksums.
- Export the complete live migration ledger (`version`, `name`) to a secure audit artefact.
- Capture a schema-only dump from the live database.
- Create an encrypted full logical backup and verify that it can be read.
- Record PostgreSQL version, installed extensions, roles, grants, policies, functions, triggers, views and publication/subscription settings.

### Step 2 — Build an explicit migration crosswalk

Create a reviewed CSV/Markdown crosswalk with one row per repository SQL file:

- repository filename and 14-digit prefix;
- Git blob SHA / content checksum;
- live ledger version and name, if matched;
- whether the migration is confirmed applied, confirmed unapplied, superseded, or unresolved;
- reviewer and evidence.

Match by SQL content and Git history as well as names. Names alone are not sufficient where files have been renamed. A migration marked unresolved must not be applied.

### Step 3 — Establish a clean canonical history

- Choose the exact set of migration files that reproduces the current production schema from an empty PostgreSQL database.
- Give every migration a unique 14-digit version.
- Preserve already-applied production migration identities. If a historical file must be renamed for the canonical repository, document the mapping and use the supported migration-history reconciliation process only after staging validation.
- Consolidate duplicate-version files only when their order and effects are proven. Do not concatenate SQL blindly: order can change data outcomes and dependencies.
- Keep data imports/seeds distinct from schema migrations where possible, and make them idempotent with explicit source provenance.
- Create a fresh staging database and replay the canonical migration set from zero.
- Compare the resulting schema and key data invariants with the production snapshot.

### Step 4 — Verify before production

Require all of the following:
- Clean replay from an empty PostgreSQL database succeeds.
- Migration ledger and repository versions match exactly according to the crosswalk.
- No duplicate migration versions remain.
- All constraints, indexes, functions, triggers, views, RLS policies and grants are present.
- Seed/import scripts do not duplicate or corrupt existing records when rerun.
- Public and private access tests pass for every role.
- Payment and ticket workflows pass sandbox tests.
- A backup restore to a separate PostgreSQL instance succeeds.

Only then approve production migration-history reconciliation.

## 5. Backup and restore baseline

### 5.1 What must be backed up

A complete recovery set consists of multiple artefacts:

1. **Database data and schema:** PostgreSQL logical backup.
2. **Roles and grants:** role definitions and grants, reviewed for secrets and environment-specific ownership.
3. **Extensions:** extension names and versions plus destination compatibility notes.
4. **Storage objects:** separate export of all Supabase Storage buckets/objects and their metadata.
5. **Identity mapping:** application user IDs and external identity-provider subject mappings. Do not assume managed password hashes or active sessions can be ported.
6. **Functions and jobs:** Edge Function source, job schedules and deployment configuration.
7. **Secrets inventory:** names, owners, rotation dates and destination secret-manager mapping only; never store secret values in Git.
8. **External integrations:** webhook endpoints, callback URLs, provider merchant references and DNS/hosting configuration.

### 5.2 PostgreSQL logical backup

Use a trusted machine or controlled CI runner with network access and a database connection string supplied securely at runtime. Do not put connection strings in shell history, GitHub files, logs or chat.

Example custom-format backup:

```bash
pg_dump --format=custom --no-owner --no-acl \
  --file=cut-sport-$(date -u +%Y%m%dT%H%M%SZ).dump \
  "$CUT_SPORT_DATABASE_URL"
```

Example schema-only snapshot:

```bash
pg_dump --schema-only --no-owner --no-acl \
  --file=cut-sport-schema.sql \
  "$CUT_SPORT_DATABASE_URL"
```

The connection variable must be injected through a secure environment/secret manager. The backup must be encrypted at rest and transferred to an institution-controlled location with access logging and retention policy.

### 5.3 Restore rehearsal

Restore into a separate, disposable PostgreSQL instance:

```bash
createdb cut_sport_restore_test
pg_restore --exit-on-error --no-owner --no-acl \
  --dbname=cut_sport_restore_test \
  cut-sport-backup.dump
```

Then run schema, foreign-key, row-count, financial-reconciliation, RLS and application smoke tests. A successful `pg_dump` command is not proof of recoverability; the restore rehearsal is mandatory.

These examples are operator runbook templates, not commands that have been run against the production database in this review.

## 6. PostgreSQL portability inventory

Before selecting a destination, collect and compare:

- PostgreSQL server version and supported target versions.
- Installed extensions and versions.
- Schemas, tables, sequences, views and materialized views.
- Functions, procedures, triggers and event triggers.
- RLS policies and table/sequence/function grants.
- Publication/subscription and logical replication configuration.
- Large objects, custom types, enums, collations and extensions.
- Scheduled jobs and background workers.
- Supabase Auth dependencies and any references to `auth.uid()`, `auth.jwt()` or `auth.users`.
- Supabase Storage buckets, object keys, policies and signed URL usage.
- Edge Function source, secrets, outbound network dependencies and webhook URLs.
- Realtime channel/subscription dependencies.
- Database API exposure settings and CORS/Auth redirect configuration.

Use standard PostgreSQL features for the application-owned schema where practical. Supabase-specific functions and schemas may remain in the current environment, but they must be clearly isolated and have a replacement design before a provider move.

## 7. Recommended next engineering tasks

1. Complete the migration crosswalk against the current live ledger and Git history.
2. Add Supabase CLI project configuration only after confirming the intended CLI version and project settings; do not fabricate a local migration baseline.
3. Establish a staging project and prove a clean migration replay.
4. Establish an encrypted off-platform backup destination controlled by CUT.
5. Perform the first full restore drill and record RPO/RTO.
6. Add CI validation that rejects duplicate migration versions for all new changes, after the legacy baseline has been reconciled.
7. Introduce provider-neutral data, auth, storage and notification adapters in the frontend/backend.

## 8. Review boundary

This audit performed read-only inspection of the GitHub branch and the Supabase migration ledger. It did not:

- alter production tables, data, roles, policies or migration history;
- run or apply SQL migrations;
- create or restore a database backup;
- create a staging project;
- modify Netlify, GitHub Actions or production deployment settings;
- expose or copy any secret values.

**Status:** Portability architecture documented; migration-history reconciliation and independent backup/restore are outstanding prerequisites for a safe infrastructure move.
