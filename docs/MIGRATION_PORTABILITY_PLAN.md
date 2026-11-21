# CUT Sport App — Migration Portability Plan

**Repository:** `siphenda-hue/CUTSportAppRep`  
**Branch:** `App`  
**Supabase project:** `tnkykdfxzwaqzbichxcl`  
**Status:** Audit complete; no production changes made  
**Last reviewed:** 19 November 2026

## 1. Current audit position

The migration audit established:

- `supabase/migrations/` contains 198 SQL files representing 168 unique 14-digit timestamp versions.
- There are 21 duplicate timestamp groups containing 51 files in total (30 duplicate occurrences beyond the first file per group). Of these, 32 files match ledger names under alternate applied versions and 19 were investigated as unmatched duplicate-group files.
- The live `supabase_migrations.schema_migrations` ledger contains 143 rows.
- 123 repository files have normalized-name matches in the live ledger.
- 75 current repository files have no direct normalized-name match. All 75 have been checked against Git history and relevant live database state. Their intended data or schema effects are present, but this does not prove that each exact file was executed by the migration runner.
- 19 live ledger rows have no current repository filename. Their live objects/security/index effects were checked. One has a strong equivalent current file; 18 original SQL sources are absent from the current branch.
- Five hockey migrations were separately confirmed in the live ledger under alternate applied versions.
- The current branch cannot yet be treated as a complete, reproducible database baseline.

See [MIGRATION_CROSSWALK.md](./MIGRATION_CROSSWALK.md) for file-level evidence.

## 2. Release-blocking findings

### 2.1 Missing baseline source

The applied ledger entry `20261101215551_initial_cut_sport_schema` has no current source file and no exact-path Git history in this repository. The live project contains the core schema, but the original SQL cannot be reconstructed from the migration ledger alone.

**Impact:** a clean database cannot reliably be recreated from the current Git repository.

### 2.2 Missing historical SQL sources

Eighteen further applied ledger entries have no current source file. The live schema contains the corresponding objects and policy state, but the original migration SQL is not available in the current branch.

### 2.3 2022 USSA Football UUID collision

The 2022 USSA Football import reuses the UUID belonging to the 2022 Varsity Sport Cricket Tournament. Replaying the file as written could update the Cricket competition's descriptive fields and attach Football matches to it. The live database currently has Football under a corrected UUID, but the correction file uses malformed timestamp prefix `20261111540000` (hour component `54`) and is not in the live ledger.

**Rule:** do not replay the 2022/2025 Football import file unchanged. Preserve the Cricket UUID and the corrected Football UUID as separate identities.


## 2.3.1 Detailed 2022 Cricket/Football collision verification (22 November 2026)

The repository SQL and live production rows were rechecked against the exact competition and match UUIDs. This section supersedes any ambiguity in the shorter collision summary above; it does not authorize a production change.

| Item | Repository/live finding |
|---|---|
| Cricket competition UUID | `a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001` |
| Correct Football competition UUID | `a43e3a9b-7c4e-4d7e-9f7c-2022f5b00001` |
| Live Cricket row | Sport ID is Cricket (`481726ef-be80-4f8e-a0c4-c5f8c41a0f74`); title is Varsity Sport Cricket Tournament; dates 3–5 October 2022; venue UP-Tuks, Pretoria; description records the semi-final run. |
| Live Football row | Sport ID is Football (`4c1ccd6f-3965-422a-ad25-19aaa2797f23`); title is USSA Football Tournament; dates 5–9 December 2022; venue Secunda. |
| Football match rows | `cut-men-univen-ussa-2022` (CUT 1–0 University of Venda) and `cut-women-ukzn-ussa-2022` (CUT 3–4 University of KwaZulu-Natal) exist under the corrected Football competition. |
| Cricket semi-final migration | `20261111550000_import_2022_varsity_cricket_cut_semi_final.sql` inserts the NWU–CUT 157–152 match against the Cricket UUID. |

### Replay-order implication

The unsafe Football import `20261111260000_import_cut_ussa_and_provincial_football_2022_2025.sql` first upserts the Football description into the Cricket UUID and inserts its two qualifier matches there. The later Cricket import `20261111510000_import_historical_cut_cricket_records.sql` restores the Cricket competition metadata on that same UUID. The correction `20261111540000_reassign_2022_ussa_football_qualifier_matches.sql` then creates the separate Football row and moves the two match rows.

Therefore, replaying only part of this sequence can leave the Cricket metadata overwritten or the Football qualifier matches attached to Cricket. The correction file's timestamp is invalid as a Supabase migration version: `20261111540000` encodes hour `54`. It is not present as a matching version in the live migration ledger. The live database currently has the corrected rows, but that live state does not prove the repository sequence is safely replayable.

### Required remediation before any replay

- Keep the existing migration files unchanged while the migration crosswalk is open.
- Use the Supabase CLI's `supabase migration new <descriptive_name>` workflow to generate a valid, forward-only migration filename when a suitable local CLI workspace is available. Do not invent a timestamp or apply a migration to production to obtain a filename.
- The forward-only migration must be safe if the correct Football row already exists, must only move the two explicitly identified Football qualifier match rows, and must assert/preserve the Cricket competition's existing metadata. It must not rewrite or delete the Cricket competition or its semi-final.
- Before testing, inspect the resulting SQL and run it only in a disposable local database after the baseline and migration order have been reconciled. Verify both competition UUIDs, sport IDs, dates, descriptions, the two Football match associations and the Cricket semi-final association.
- Do not use `migration repair`, edit the live migration ledger, or apply this correction to production during portability work.

**Current disposition:** live data is correct; repository replay remains blocked pending a valid CLI-generated forward-only migration and disposable replay verification. No production database or deployment was changed during this check.

### 2.4 Historical metadata and statistics issues

Keep these visible during the rebuild; do not silently rewrite source facts:

- 2023/24 Free State ABC Motsepe competition currently has status `upcoming`, although it is a completed historical season.
- 2019 MCA CUT 1 figures have one unexplained match in the played/win/loss arithmetic.
- 2023 USSA women's hockey has one goal not reconciled by the published scoring breakdown.
- 2026 USSA women's hockey has two team goals without named-player attribution.
- Cricket batting/bowling facts are stored in `competition_player_statistics.statistics` JSONB. Legacy hockey goal columns are zero placeholders and must not be interpreted as cricket totals.

## 3. Safe execution principles

1. **Production remains read-only during recovery.** No `db push`, `db reset --linked`, `migration repair`, direct ledger edits, destructive DDL, bulk replays, or production data fixes.
2. Preserve every current migration file and its history until the crosswalk is approved.
3. Do not rename or delete migration files to make the local and remote lists appear aligned.
4. Never fabricate original migration SQL. Mark recovered source separately from reconstructed source.
5. Use a local or disposable environment for all replay tests. A Supabase development branch may incur cost; do not create one without separate approval.
6. Keep database credentials, role dumps and production data dumps out of Git.

## 4. Recovery and portability phases

### Phase A — Freeze and archive evidence

- Record the current branch head and the crosswalk commit.
- Preserve the current 198 migration files and all 143 live ledger rows.
- Export a read-only copy of the migration ledger for audit records.
- Preserve the live schema/role dumps in a restricted location, not in the public repository.
- Recover original SQL from available local backups, earlier repositories/branches, SQL-editor history or other retained project archives where available.

### Phase B — Create a schema-only evidence dump

Use the Supabase CLI against the existing project, with a database connection string supplied securely by the project owner:

```bash
supabase db dump --db-url "$DB_URL" -f roles.sql --role-only
supabase db dump --db-url "$DB_URL" -f schema.sql
```

These are export commands. Review the output locally and keep it private. A separate data-only export is not required to establish the schema baseline; if needed for validation, store it outside Git and protect it as production data.

Supabase's current CLI documentation describes `db dump` for schema/role export and `db pull` for creating a baseline migration. **Do not run `db pull` against production as part of this audit**: the CLI may record the pulled baseline as applied in the remote migration history. A baseline must first be prepared and reviewed offline.

### Phase C — Reconstruct the baseline

- Compare the schema dump with the current migration chain and the ledger-only evidence.
- Recover the original initial schema SQL if possible.
- If it cannot be recovered, create a clearly labelled **reconstructed baseline** from the schema dump. Do not present it as the original migration.
- Include custom objects and policies in `auth` and `storage` where relevant, including the private `cut-sport-media` bucket and its policies.
- Verify functions, triggers, indexes, constraints, RLS policies, grants, storage configuration and extensions.
- Separate schema creation from historical data imports and operational configuration.

### Phase D — Build a disposable replay environment

- Use a local Supabase stack or an approved throwaway development environment.
- Replay the reviewed baseline and the reconciled migration chain from an empty database.
- Never use `db reset --linked` against the production project.
- Verify that migrations are ordered, idempotent where appropriate, and do not collide on IDs or policy names.
- Add automated assertions for the 2022 Cricket/Football UUID separation and the historical competition records.
- Verify the private storage bucket, 50 MiB upload limit, MIME restrictions, RLS and grants.
- Test anonymous, authenticated, athlete, assigned sport-admin and super-admin access separately.

### Phase E — Resolve migration history strategy

Only after the disposable replay succeeds:

- Produce a reviewed mapping from every live ledger version to a current source file, recovered source, or reconstructed baseline component.
- Decide whether to retain the existing applied history and continue forward, or to establish a new baseline for a separate clean environment.
- Do not repair the production ledger merely to silence CLI warnings. Supabase `migration repair` inserts or deletes migration-history rows; use it only if a reviewed, explicit reconciliation decision requires it and the owner separately authorizes the change.
- Keep the current production ledger unchanged until a tested strategy is approved.

### Phase F — Separate production release approval

Any future production migration, data correction, storage change or deployment requires a separate explicit approval. The current audit does not authorize those actions.

## 5. Required acceptance checks

A portability candidate is not complete until all checks pass:

- [ ] Fresh disposable database can be built from the reviewed source set.
- [ ] All expected public tables, columns, types, constraints and indexes exist.
- [ ] All required functions and triggers exist with correct security-definer/search-path settings.
- [ ] RLS is enabled on all intended tables; policy definitions and grants match the reviewed production state.
- [ ] Private storage bucket and storage-object policies are recreated correctly.
- [ ] 2022 Varsity Cricket and 2022 USSA Football have separate, correct competition UUIDs.
- [ ] Historical competitions, standings, matches and player-stat JSONB survive the rebuild.
- [ ] Known source discrepancies remain explicit and are not converted into invented results.
- [ ] Public read access for current/previous seasons and approved heritage records is tested separately from authenticated/admin access.
- [ ] No production migration ledger or live deployment was changed during validation.

## 6. Supabase references

- [Local development workflow](https://supabase.com/docs/guides/local-development/cli-workflows)
- [Supabase CLI — db dump](https://supabase.com/docs/reference/cli/supabase-db-dump)
- [Supabase CLI — db pull](https://supabase.com/docs/reference/cli/supabase-db-pull)
- [Supabase CLI — migration repair](https://supabase.com/docs/reference/cli/supabase-migration-repair)
- [Backup and restore using the CLI](https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore)

