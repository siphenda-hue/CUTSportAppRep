# Migration Crosswalk — Read-only reconciliation snapshot

**Repository:** `siphenda-hue/CUTSportAppRep`  
**Branch:** `App`  
**Supabase project:** `tnkykdfxzwaqzbichxcl`  
**Snapshot date:** 18 November 2026  
**Scope:** Read-only comparison of repository filenames and the live `supabase_migrations.schema_migrations` ledger.

## Executive result

This snapshot confirms that migration history is not yet safe for automated replay or cleanup.

| Check | Result |
|---|---:|
| SQL files in `supabase/migrations/` | 198 |
| Distinct 14-digit versions represented by those files | 177 |
| Duplicate version groups | 21 |
| Applied rows in live migration ledger | 143 |
| Repository files with a direct migration-name match in the ledger | 123 |
| Ledger rows with no direct normalized filename match | 19 |
| Repository files not positively reconciled by direct name | 75 |

The 123 direct matches are name-based matches only. They are not a checksum comparison of the SQL file against the historical SQL that was executed. The 75 unmatched files are **not** classified as unapplied. Some may have been applied under earlier timestamps or names; others may be newer or duplicate-version files.

## Duplicate repository version groups

The following 21 timestamp versions occur more than once in the current repository:

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

A Supabase migration version is expected to identify one migration. Multiple files with the same version make ordering and replay ambiguous. Do not run these files as a batch.

## Ledger naming anomalies

The live ledger includes nine rows whose `name` value itself begins with a 14-digit timestamp, for example:

- Version `20261111075041`, name `20261111103000_athlete_self_service_review_visibility`
- Version `20261111100501`, name `20261111153000_add_hockey_match_and_player_statistics`
- Version `20261111100512`, name `20261111154500_seed_cut_hockey_competition_data`
- Version `20261111100542`, name `20261111160000_add_hockey_team_statistics`
- Version `20261111100611`, name `20261111160500_seed_hockey_team_statistics`
- Version `20261111101156`, name `20261111163000_correct_hockey_match_links_and_statistics`
- Version `20261111101547`, name `20261111170000_import_cut_hockey_2024_2025`
- Version `20261111101813`, name `20261111173000_complete_2023_hockey_standings`
- Version `20261111101854`, name `20261111174500_complete_2023_womens_hockey_standings`

This is consistent with historical filename/version changes, but it does not prove which current file content was applied. The repository history includes commits explicitly aligning migration filenames with applied Supabase versions and removing superseded filenames (16 November 2026). Those commits must be inspected as part of the crosswalk.

## Reconciliation rules

For every repository SQL file, record:

1. Current filename and 14-digit version.
2. Current Git blob SHA.
3. Earliest commit introducing the file and all subsequent rename/delete/replacement commits.
4. Any predecessor/successor filenames and their blob SHAs.
5. Matching live ledger version and name, if established.
6. Evidence class: `confirmed-applied`, `probable-historical-rename`, `candidate-unapplied`, `duplicate-version`, or `unresolved`.
7. Reviewer notes. Do not infer status from timestamp ordering or row counts alone.

For every live ledger row, record the corresponding repository file or explicitly mark it as a historical file absent from the current branch. Where possible, compare SQL content from the historical commit with the current file. A ledger row stores version/name metadata, not a cryptographic checksum of the SQL that ran.

## Required next audit steps

1. Fetch all migration files and Git history for the migration directory, including pagination beyond the first 100 commits.
2. Inspect the 16 November migration-alignment commits and the 11 November timestamp-collision fix.
3. Build a complete two-way table: repository file → ledger row and ledger row → repository file.
4. Compare blob contents across rename/replacement history for every apparent match.
5. Identify whether multiple same-version files have ever been applied separately or whether one was superseded before application.
6. Have the crosswalk reviewed before proposing any filename changes or baseline strategy.
7. Only after reconciliation, prepare a clean, portable migration history and test it against a disposable PostgreSQL/Supabase environment.

## Safety boundary

No database schema, data, migration ledger, repository migration file, or deployment was changed as part of this snapshot. Do not run `supabase db push`, `supabase migration repair`, `supabase db reset`, bulk migration operations, or manually edit `supabase_migrations.schema_migrations` until the crosswalk is complete and reviewed.

The next task is a **Git-history and content crosswalk**, not a production migration.
