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


## Git-history evidence inspected (18 November 2026)

The repository history confirms that at least three migration filename mismatches were intentional alignment operations, not evidence that the underlying SQL was never applied:

| Migration subject | History evidence | Finding |
|---|---|---|
| Sports SELECT-policy consolidation | Commit `12869af35fe1e428aeb883a922b907d26ebca377` adds the migration under the applied Supabase version; commit `7c3ac843ef249eca54b03d88a32befab5597329e` removes the superseded filename. | The added and removed SQL bodies are identical in the commit diffs. This is a confirmed historical filename alignment. |
| Foreign-key covering indexes | Commit `17474eaad6e4cbfbff47f59c33e8bd0877a6bc03` adds the migration under the applied version; commit `f2f01a3aee17fa849ede161889116146938a6236` removes the superseded filename. | The added and removed SQL bodies are identical in the commit diffs. This is a confirmed historical filename alignment. |
| Restrict anonymous/client table privileges | Commit `72e7308f0e361b4d88dc0948e9a6c5b28500c418` adds the migration under the applied Supabase version; commit `e84b66e86135c10a466107ddfff484e513743990` removes the old filename. | The added and removed SQL bodies are identical in the commit diffs. This is a confirmed historical filename alignment. |

The 11 November commit `6136bb5b61ac8e978a2e2f8c76d8913b92c9109d` is a separate data-correction change to the Golf migration (UUID collision fix); it is not a filename-alignment proof.

These examples establish that the repository has previously used rename-by-replacement commits to align migration filenames with versions already recorded in Supabase. Therefore the raw count of files whose timestamp does not appear in the live ledger must not be interpreted as a count of unapplied migrations.

### Remaining work

- Inspect all remaining migration-directory commits, including older pages of history.
- Build a file-level lineage for all 198 current SQL files and all 143 ledger rows.
- Resolve the 21 duplicate version groups individually; no current evidence authorizes selecting one file or assuming all files in a group were applied.
- Compare historical SQL bodies wherever Git history preserves the predecessor content.
- Keep all production migration operations paused until a reviewer can trace every ledger row and every current migration file.


## Expanded Git-history lineage findings

The migration-directory history was paginated in full: **246 commits across three non-empty pages** (page 4 was empty). This includes the 6–17 November 2026 migration activity. Commit-level file metadata confirms the following filename replacement pairs:

| Applied ledger identity | Superseded repository filename | Current repository filename | History finding |
|---|---|---|---|
| `20261111084610` — `athlete_recruitment_and_trial_selection` | `20261111090000_athlete_recruitment_and_trial_selection.sql` | `20261111084610_athlete_recruitment_and_trial_selection.sql` | Same executable SQL was removed and re-added under the applied version; the replacement adds a descriptive comment. |
| `20261111084651` — `separate_recruitment_opportunity_write_policies` | `20261111090100_separate_recruitment_opportunity_write_policies.sql` | `20261111084651_separate_recruitment_opportunity_write_policies.sql` | Same executable SQL was removed and re-added under the applied version; the replacement restores descriptive comments. |
| `20261111085030` — `restrict_recruitment_column_permissions` | `20261111090200_restrict_recruitment_column_permissions.sql` | `20261111085030_restrict_recruitment_column_permissions.sql` | Same SQL body was removed and re-added under the applied version. |
| `20261111085208` — `protect_private_trial_evaluation_notes` | `20261111085130_protect_private_trial_evaluation_notes.sql` | `20261111085208_protect_private_trial_evaluation_notes.sql` | Same SQL body was removed and re-added under the applied version. |
| `20261111075041` — ledger name retains old prefix `20261111103000_athlete_self_service_review_visibility` | `20261111103000_athlete_self_service_review_visibility.sql` | `20261111075041_athlete_self_service_review_visibility.sql` | Same SQL body was removed and re-added under the applied version. |
| `20261111080034` — `harden_athlete_resubmission_guard_null_handling` | `20261111121500_harden_athlete_resubmission_guard_null_handling.sql` | `20261111080034_harden_athlete_resubmission_guard_null_handling.sql` | Same SQL body was removed and re-added under the applied version. |
| `20261111075930` — secure athlete resubmission migration | `20261111120000_secure_athlete_record_resubmission.sql` | `20261111075930_secure_athlete_record_resubmission.sql` | Same SQL body was removed and re-added under the applied version. |
| `20261106012659` — `release_unlinked_stale_yoco_orders` | `20261106013000_release_unlinked_stale_yoco_orders.sql` | `20261106012659_release_unlinked_stale_yoco_orders.sql` | Same SQL body was removed and re-added under the applied version. |

These are strong lineage proofs because the Git commits explicitly add/remove the exact paths and their patches contain the SQL body. For the recruitment table/schema migration and athlete self-service policy migration, the replacement differs in comments/blank lines only; the executable SQL statements match. For the other listed pairs, the added and removed SQL bodies match exactly. The live ledger provides the matching applied version/name identity. The historical ledger name for the athlete self-service policy remains prefixed with the superseded timestamp, which is a confirmed example of why ledger `name` values cannot be treated as current filenames.

### Additional migration history notes

- The 11 November commit `863225e5e4c2ae518535ee929b26654368391084` modifies the initial schema migration source to align it with the SQL that was actually applied. This is a content correction, not just a filename change. Its exact historical file lineage and content need separate review.
- The 11 November commit `6136bb5b61ac8e978a2e2f8c76d8913b92c9109d` corrects a Golf seed UUID collision. This is a substantive migration content change and must not be mistaken for a rename.
- The 16 November migration filename-alignment examples already documented above remain confirmed.
- These lineage proofs resolve specific mismatches; they do not yet reconcile every current file or every ledger row.

## Current reconciliation status

**Confirmed historical filename replacement cases documented:** 11 (including the three 16 November cases documented above and the eight additional pairs listed here).  
**Still unresolved:** all remaining unmatched files, every duplicate-version group, the full historical content of the initial schema, and all ledger rows without a current same-name file.

Do not extrapolate these confirmed cases to other files. Each remaining file requires its own Git lineage and ledger evidence.


## Duplicate-version group reconciliation

A second pass compared every file in the 21 duplicate-version groups against the live ledger using the normalized migration name (the filename without its timestamp prefix and `.sql` suffix).

- All **21 duplicated timestamp prefixes are absent from the live ledger** as versions.
- Of the **42 files** in those groups, **23 have a matching normalized migration name** in the ledger, but under a different applied version.
- The remaining **19 files have no matching normalized migration name** in the live ledger and remain unresolved candidates.
- None of these 19 is labelled unapplied here: a migration may have been applied under a changed name or represented by a later/superseding SQL migration.

### Duplicate groups with name-matched ledger evidence

| Shared repository timestamp | Files with a normalized ledger-name match | Files without a normalized ledger-name match |
|---|---:|---:|
| `20261111110000` | 1 | 1 |
| `20261111120000` | 1 | 1 |
| `20261111130000` | 1 | 1 |
| `20261111170000` | 1 | 1 |
| `20261111173000` | 1 | 1 |
| `20261111180000` | 1 | 1 |
| `20261111190000` | 2 | 1 |
| `20261111193000` | 2 | 0 |
| `20261111200000` | 1 | 1 |
| `20261111210000` | 2 | 2 |
| `20261111220000` | 2 | 1 |
| `20261111230000` | 2 | 1 |
| `20261111240000` | 2 | 2 |
| `20261111250000` | 2 | 1 |
| `20261111260000` | 1 | 1 |
| `20261111270000` | 1 | 1 |
| `20261111280000` | 2 | 1 |
| `20261111290000` | 1 | 1 |
| `20261111300000` | 1 | 1 |
| `20261111310000` | 1 | 1 |
| `20261111430000` | 2 | 0 |
| **Total** | **23** | **19** |

### Unmatched files in duplicate groups

These 19 files have no direct normalized-name counterpart in the current live ledger:

- `20261111110000_import_ussa_basketball_2025_b_section_placements.sql`
- `20261111120000_import_cut_cheerleading_samca_2025_results.sql`
- `20261111130000_add_cut_ussa_cricket_2025_participation.sql`
- `20261111170000_import_cut_2025_free_state_cross_country_championships.sql`
- `20261111173000_add_2025_asa_cross_country_event_audit.sql`
- `20261111180000_import_2025_ussa_cross_country_championships_audit.sql`
- `20261111190000_import_2024_ussa_cross_country_championship_audit.sql`
- `20261111200000_add_2024_asa_cross_country_championship_audit.sql`
- `20261111210000_add_2024_free_state_cross_country_championship_audit.sql`
- `20261111210000_import_2019_ussa_esports_cut_result.sql`
- `20261111220000_import_2022_cut_red_bull_campus_clutch.sql`
- `20261111230000_import_2026_varsity_esports_cut_rocket_league_finalist.sql`
- `20261111240000_add_tennis_and_table_tennis_sport_categories.sql`
- `20261111240000_import_cut_ussa_golf_2019_2022_2025.sql`
- `20261111250000_import_2019_cut_varsity_football_derby.sql`
- `20261111260000_import_cut_ussa_and_provincial_football_2022_2025.sql`
- `20261111270000_import_cut_abc_motsepe_and_mangaung_cup_2021_2022.sql`
- `20261111280000_import_2022_sasol_national_womens_football.sql`
- `20261111290000_reconcile_2024_free_state_sasol_womens_league.sql`

### Interpretation

The duplicate timestamps are a repository-level collision problem even though none of those duplicated prefixes appears as an applied version in the live ledger. The files with normalized-name matches show that some were applied under different versions. The other files require individual Git-history review and live-data comparison before they can be classified.

Do not resolve this by renaming all 42 files or assigning sequential timestamps in bulk. First establish which SQL statements have already affected production and whether the 19 unmatched files have been applied under other names, included in other migrations, or never applied.
