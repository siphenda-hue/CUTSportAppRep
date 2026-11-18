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
| Distinct 14-digit versions represented by those files | 168 |
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

A second pass compared all 51 files across the 21 duplicate-version groups against the live ledger using the normalized migration name (the filename without its timestamp prefix and `.sql` suffix).

- All **21 duplicated timestamp prefixes are absent from the live ledger** as versions.
- The 21 groups contain **51 files total** (30 duplicate occurrences beyond the first file per group).
- Of the **51 files** in those groups, **32 have a matching normalized migration name** in the ledger, but under a different applied version.
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

Do not resolve this by renaming all 51 files or assigning sequential timestamps in bulk. First establish which SQL statements have already affected production and whether the 19 unmatched files have been applied under other names, included in other migrations, or never applied.


## Live-data reconciliation of the 19 unmatched duplicate-group files

A read-only comparison was made against the connected production database on 19 November 2026. Each file's timestamp prefix was checked against `supabase_migrations.schema_migrations`; none of the 19 prefixes has a matching ledger version. The live records were then compared by the exact competition UUID where the SQL uses one, or by sport/name/season and expected standings for idempotent CTE-based imports.

**Important distinction:** a matching live record proves that the intended data is present; it does not prove that this exact repository file was applied by the migration runner. These entries remain ledger-untracked unless a separate ledger identity or historical execution record proves otherwise.

| Unmatched repository file | Live database evidence | Reconciliation classification |
|---|---|---|
| `20261111110000_import_ussa_basketball_2025_b_section_placements.sql` | Both 2025 Basketball B-Section competitions exist; CUT men's 5th and women's 4th standings are present. | Data present — exact expected records |
| `20261111120000_import_cut_cheerleading_samca_2025_results.sql` | 2025 SAMCA competition exists with CoEd Level 1st, All-Girls Level 5 2nd, and Pom Doubles 2nd standings. | Data present — exact expected records |
| `20261111130000_add_cut_ussa_cricket_2025_participation.sql` | 2025 USSA Cricket Tournament exists under Cricket with the expected dates and Stellenbosch venue; subsequent match/standing imports also exist. | Data present — exact event record; later enrichment exists |
| `20261111170000_import_cut_2025_free_state_cross_country_championships.sql` | Exact competition UUID exists with the CUT athlete placings retained in its description. | Data present — exact UUID and content |
| `20261111173000_add_2025_asa_cross_country_event_audit.sql` | Exact competition UUID exists as the 2025 ASA Cross Country event; no CUT athlete placings were inferred. | Data present — exact UUID and intended audit-only scope |
| `20261111180000_import_2025_ussa_cross_country_championships_audit.sql` | Exact competition UUID exists for the 2025 USSA Cross Country Championships; no unverified CUT athlete results were added. | Data present — exact UUID and intended audit-only scope |
| `20261111190000_import_2024_ussa_cross_country_championship_audit.sql` | Exact competition UUID exists; CUT team standing at position 6 is present. | Data present — exact UUID and expected team standing |
| `20261111200000_add_2024_asa_cross_country_championship_audit.sql` | Exact competition UUID exists for the 2024 ASA Cross Country Championships; no CUT affiliation was inferred from provincial entries. | Data present — exact UUID and intended audit-only scope |
| `20261111210000_add_2024_free_state_cross_country_championship_audit.sql` | Exact competition UUID exists for the 2024 Free State Cross Country Championships; no individual CUT results were added. | Data present — exact UUID and intended audit-only scope |
| `20261111210000_import_2019_ussa_esports_cut_result.sql` | Exact competition UUID exists; CUT eTitans second-place standing is present. | Data present — exact UUID and expected standing |
| `20261111220000_import_2022_cut_red_bull_campus_clutch.sql` | Exact competition UUID exists; CUT's Free State chapter win is represented by the first-place standing. | Data present — exact UUID and expected standing |
| `20261111230000_import_2026_varsity_esports_cut_rocket_league_finalist.sql` | Exact competition UUID exists; SuperNova (CUT) is recorded without an invented final placing. | Data present — exact UUID and intended finalist-only scope |
| `20261111240000_add_tennis_and_table_tennis_sport_categories.sql` | Tennis and Table Tennis both exist in `public.sports` with `is_active = false`. | Data present — both categories exist in intended inactive state |
| `20261111240000_import_cut_ussa_golf_2019_2022_2025.sql` | Exact 2019, 2022 and 2025 Golf competition UUIDs exist; 2022 CUT Golf 3rd and 2025 CUT Golf 2nd standings are present. | Data present — exact UUIDs and expected standings |
| `20261111250000_import_2019_cut_varsity_football_derby.sql` | Exact competition UUID exists with the CUT–UFS Bloemfontein Derby fixture and 2–0 result. | Data present — exact UUID and expected match |
| `20261111260000_import_cut_ussa_and_provincial_football_2022_2025.sql` | 2025 USSA Football competition and men's 12th / women's 18th standings exist. The 2022 USSA Football event and both qualification matches exist under corrected UUID suffix `2022f5b00001`. | Partially equivalent — see critical ID-collision finding below |
| `20261111270000_import_cut_abc_motsepe_and_mangaung_cup_2021_2022.sql` | ABC Motsepe 2021/22 competition exists with Stream B 6th and overall 12th standings; Mangaung Cup 2022 exists with CUT champion standing. The 2022 Sasol League description is also present. | Data present — exact IDs and expected standings/update |
| `20261111280000_import_2022_sasol_national_womens_football.sql` | Exact competition UUID exists with CUT FC's third-place standing and the two recorded group matches. | Data present — exact UUID and expected records |
| `20261111290000_reconcile_2024_free_state_sasol_womens_league.sql` | Target UUID exists with the migration's 1 February–8 September 2024 dates and reconciled description; the provincial final and 11–0 league fixture plus eight group standings are present. | Data present — exact target and reconciled state |

### Critical 2022 USSA Football ID collision

The file `20261111260000_import_cut_ussa_and_provincial_football_2022_2025.sql` assigns UUID `a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001` to the 2022 USSA Football competition. In the live database that UUID belongs to the 2022 Varsity Sport Cricket Tournament. The file's `ON CONFLICT (id) DO UPDATE` clause does not update `sport_id`, `name`, or `season`, but it does update the description, dates and venue; its subsequent match insert would therefore attach football qualification matches to the Cricket competition if replayed against that existing row.

The live database currently has the correct Football competition under UUID `a43e3a9b-7c4e-4d7e-9f7c-2022f5b00001`, and both qualification matches are attached to that corrected Football record. The 2022 Cricket competition retains its cricket identity and its Varsity Cricket semi-final. The correction SQL is present in `20261111540000_reassign_2022_ussa_football_qualifier_matches.sql`, committed as `818ae1dfd00bd6551a9568e6cecfa472ff4c7ce7`; its filename prefix has an invalid hour component (`54`) and does not appear in the live migration ledger. The production match rows show an update at 16:41:18 UTC on 11 November 2026, consistent with the correction having been reflected in the live data.

**Do not replay the 2022/2025 Football import file as written.** Before any future migration rebuild, correct the source lineage and timestamp, retain the existing Cricket UUID, and test the repaired SQL against a disposable database. Do not change production as part of this audit.

### Batch conclusion

- All 19 files remain absent from the live migration ledger by their current filename timestamp.
- The intended records or category states for all 19 files are represented in the live database; the 2022 Football import is represented under its corrected UUID.
- This is evidence of **live data presence**, not proof that each of these 19 exact files was applied through Supabase's migration runner.
- No SQL migration, data mutation, migration-ledger repair, schema change, or deployment was performed during this comparison.
- The 2022 Football collision is a release-blocking portability issue: the repository source must not be replayed unchanged into a fresh or restored database.


## Follow-on reconciliation batch: Volleyball, Athletics, standings schema and cross-country

A second read-only batch reviewed five additional files from the remaining direct-name unmatched set.

| Repository file | Live state / ledger evidence | Classification |
|---|---|---|
| `20261111100000_import_ussa_volleyball_2024_2025_verified_placements.sql` | Both 2024 and 2025 USSA Volleyball competitions exist for Volleyball; each has CUT Volleyball Club in 7th place, matching the file's intended scope. | Live data present; exact records, no direct filename-ledger match |
| `20261111140000_import_ussa_athletics_2025_verified_results.sql` | 2025 USSA Track & Field Championships exists with the expected dates, venue and verified athlete result narrative. | Live data present; exact event and content, no direct filename-ledger match |
| `20261111143000_add_multi_sport_competition_standings.sql` | `competition_standings` exists with the expected columns, defaults, unique key, RLS, the two named policies and index. The live ledger has version `20261111095426`, name `competition_standings_and_multi_sport_competitions`; the current file's Git commit is dated 09:54:33 UTC, seven seconds after that ledger version, and its schema/policy definition matches the live objects. | Strong equivalent to an applied migration under a different ledger identity; preserve as lineage evidence, do not replay |
| `20261111144500_clarify_hollywoodbets_cut_participation.sql` | The 2026 record is now named `Hollywoodbets Super League (National Reference)` and explicitly states that CUT Ixias Ladies must not be attributed to that competition. | Live data reflects intended clarification; no direct filename-ledger match |
| `20261111150000_import_cut_bloemfontein_cross_country_2025_results.sql` | The 2025 Bloemfontein Cross Country League competition exists with the two verified league-result summaries in its description. | Live data present; exact event and content, no direct filename-ledger match |

### Standings-schema lineage note

The `competition_standings` ledger entry demonstrates another kind of mismatch: the live applied version/name (`20261111095426` / `competition_standings_and_multi_sport_competitions`) differs from the current repository filename (`20261111143000_add_multi_sport_competition_standings.sql`). The current file was added in commit `0e8f68912c69266bac61100a7c362d11f25a993d` at 09:54:33 UTC. This is strong evidence of the same schema operation being represented under different identities, but the ledger itself does not store the SQL body, so the evidence is described as a strong equivalent rather than an independently cryptographic body comparison.

The current file contains non-idempotent `CREATE POLICY` statements. Because the live policies already exist, replaying this file against the current project would fail on duplicate policy names. The current table and policies were inspected read-only; no DDL was executed.

### Batch conclusion

- Five more direct-name unmatched files were reviewed.
- Four have the expected live data/clarification already present, without a matching current filename identity in the ledger.
- The standings schema has a strong applied-ledger equivalent under version `20261111095426`.
- No database or migration-ledger changes were made.


## Follow-on reconciliation batch: historical hockey imports and statistics

Five further repository files were matched to live migration-ledger entries. In these cases the ledger `name` preserves the repository file's timestamp-prefixed name, while the applied `version` is an earlier execution timestamp.

| Current repository file | Live ledger identity | Production verification |
|---|---|---|
| `20261111154500_seed_cut_hockey_competition_data.sql` | `20261111100512` — `20261111154500_seed_cut_hockey_competition_data` | 2023 men's/women's C-Section and 2026 men's/women's B-Section competitions, standings, matches and player statistics are present. |
| `20261111160000_add_hockey_team_statistics.sql` | `20261111100542` — `20261111160000_add_hockey_team_statistics` | `competition_team_statistics` exists with its unique key, index, RLS and both public-read and assigned-sport-admin policies. |
| `20261111160500_seed_hockey_team_statistics.sql` | `20261111100611` — `20261111160500_seed_hockey_team_statistics` | Four expected team summary rows exist for the 2023 and 2026 USSA hockey competitions. |
| `20261111163000_correct_hockey_match_links_and_statistics.sql` | `20261111101156` — `20261111163000_correct_hockey_match_links_and_statistics` | 2026 men's and women's match rows use official SAHA match IDs (7600–7628) rather than the earlier local aliases. |
| `20261111170000_import_cut_hockey_2024_2025.sql` | `20261111101547` — `20261111170000_import_cut_hockey_2024_2025` | 2024 and 2025 men's/women's competitions, standings, 15 match rows per competition, player statistics and team summary rows are present. |

These are **confirmed ledger matches under alternate applied versions**, not unapplied migrations. The live data counts observed were:

| Hockey competition | Standings | Matches | Player-stat rows | Team-stat rows |
|---|---:|---:|---:|---:|
| 2023 USSA Men C-Section | 14 (Pool A + Final Standing) | 6 | 8 | 1 |
| 2023 USSA Women C-Section | 8 (Pool A + Final Standing) | 5 | 8 | 1 |
| 2024 USSA Men B-Section | 12 (Pool A + Final Standing) | 15 | 4 | 1 |
| 2024 USSA Women C-Section | 8 (Pool A + Final Standing) | 10 | 8 | 1 |
| 2025 USSA Men B-Section | 12 (Pool A + Final Standing) | 15 | 5 | 1 |
| 2025 USSA Women B-Section | 12 (Pool A + Final Standing) | 15 | 7 | 1 |
| 2026 USSA Men B-Section | 6 (Pool A) | 5 | 5 | 1 |
| 2026 USSA Women B-Section | 16 (Pool A, Pool B + Final Standing) | 5 | 9 | 1 |

### Hockey data-quality observations retained

- The separate `Pool A` and `Final Standing` groups in the single-pool 2023–2025 competitions repeat the same team ranking where the tournament source presents both a pool table and a final placing. They are distinct group labels, not duplicate rows under the unique key.
- In the 2023 women's C-Section, the official team total is 14 while the published category breakdown (9 field goals + 4 penalty-corner goals + 0 penalty strokes) and named player rows total 13. The existing `statistics` JSONB explicitly records this as a source arithmetic inconsistency with one unreconciled goal. Do not invent a scorer or change the source totals.
- In the 2026 women's B-Section, team totals are 19 while the nine named player rows total 17. The existing `statistics` JSONB records two unattributed goals. Do not inflate player totals.
- The `competition_team_statistics` table has an additional `statistics jsonb` column beyond the base hockey-table migration. This is explained by the later applied migration `20261111102901` (`add_multisport_competition_statistics_and_rugby_2026`). RLS is enabled; the table is not FORCE RLS. Its public-read and assigned-sport-admin management policies are present.

No production data or schema was changed during this batch.


## Follow-on reconciliation batch: ABC Motsepe, Women's Varsity Football and cricket history

Five more files were reviewed against Git history and production data. None has a matching entry in the live migration ledger by its current timestamp or normalized migration name. Their intended records are nevertheless present in production. Git commit timestamps and the database's row timestamps for the 2024–2025 cricket match import are consistent with data being written directly before the migration files were committed; this is not proof of migration-runner execution.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111300000_import_2023_24_free_state_abc_motsepe_standings.sql` | Exact UUID exists with both Stream A (Central University of FS, 7th) and Stream B (Ixias FC, 9th) standings. The competition status is currently `upcoming`, because this file omits `status` and the table default was applied. | Data present; status metadata defect to correct in a future reviewed change |
| `20261111310000_correct_2024_womens_varsity_football_metadata.sql` | The 2024 Women's Varsity Football record ends on 29 July 2024; all four match rows exist, with the three group-stage rows labelled Group B and the playoff left ungrouped. | Live data reflects the intended correction |
| `20261111500000_import_2024_ussa_cricket_participation.sql` | Exact 2024 USSA Cricket competition UUID exists with the specified 2–6 December 2024 dates and Bloemfontein venue. | Data present; no direct ledger entry |
| `20261111510000_import_historical_cut_cricket_records.sql` | All nine competition UUIDs in the file exist, covering 2015/16, 2016, 2017, 2018, 2019, 2021, 2021/22, 2022 and 2025/26. Related match/player-stat rows from the later cricket enrichment files are present. | Data present; no direct ledger entry |
| `20261111520000_import_2024_2025_ussa_cricket_match_results.sql` | Both 2024 USSA Cricket outcome rows and all five 2025 USSA Cricket outcome rows exist. The match outcomes are held in the `statistics` JSONB where scorecard totals were not published; numeric scores remain null as intended. | Data present; no direct ledger entry |

### Cricket / football UUID collision confirmed at source

The historical cricket file deliberately assigns `a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001` to the 2022 Varsity Sport Cricket Tournament. This is the correct live Cricket record and has its own Varsity Cricket semi-final match. The separate 2022 USSA Football import incorrectly reused that same UUID. The corrected Football record is under `a43e3a9b-7c4e-4d7e-9f7c-2022f5b00001`. Preserve the Cricket UUID and the Football UUID separately; never reassign the Cricket record.

### Follow-up data-quality item

The 2023/24 Free State ABC Motsepe competition is a completed historical season, but its current database status is `upcoming`. The seed SQL omits the status column, so the database default was used. This is a real data-state defect, not evidence that the migration is unapplied. It should be corrected through a separately reviewed, idempotent change after this migration reconciliation is complete.

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2017–2025 cricket match history

Five more historical cricket files were inspected. None has a matching migration-ledger entry by current filename or normalized name, but all intended competition updates and match rows are present in the live database.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111530000_reconcile_2025_ussa_cricket_group_b_placing.sql` | The 2025 USSA Cricket description now records the four Group B results and the 186-run loss to Madibaz B, explicitly identifying CUT's fourth place as a Group B placing rather than an overall tournament rank. | Data present; no direct ledger entry |
| `20261111550000_import_2022_varsity_cricket_cut_semi_final.sql` | The 2022 Varsity Cricket semi-final is present under the Cricket UUID `...2022f5a00001`, with NWU 157/6 defeating CUT 152/6 by five runs and Delano Williams' sourced 26 not out. | Data present; exact match and correct Cricket UUID |
| `20261111560000_import_2019_varsity_cricket_cut_match.sql` | The 2019 Varsity Cricket group-stage result against UP-Tuks exists as a completed match with no invented score or date. | Data present; no direct ledger entry |
| `20261111570000_import_2018_varsity_cricket_cut_match.sql` | The 2018 Varsity Cricket group-stage result against UP-Tuks exists as a completed match; score and exact date remain null as the source does not publish them. | Data present; no direct ledger entry |
| `20261111580000_import_2017_ussa_cricket_qualifier_result.sql` | The 2017 USSA Cricket qualifier against UFS/Kovsies exists as a completed result, with no invented score or exact date. | Data present; no direct ledger entry |

The 2022 semi-final row is correctly attached to the 2022 Varsity Cricket competition using UUID `a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001`. This further confirms that the same UUID in the 2022 USSA Football import is a source-file collision, not a legitimate Football identity.

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2012, 2018 and 2023 USSA Cricket results

Five further historical cricket files were checked. None has a direct matching migration-ledger entry. All target competitions, match rows and player-stat rows are present in production.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111600000_import_2018_ussa_cricket_cut_uct_result.sql` | 2018 USSA Cricket A Section exists for 3–7 December in Stellenbosch; CUT's 180–76 win over UCT in the 7th-place play-off is present. | Data present; no direct ledger entry |
| `20261111610000_import_2023_ussa_cricket_cut_results.sql` | 2023 USSA Cricket A Week exists with four verified match rows (three Pool B wins and the 22-run Section B play-off win over UCT). The unverified scheduled final against Varsity College is not recorded as a result. | Data present; no direct ledger entry |
| `20261111620000_add_2023_ussa_cricket_jason_raubenheimer_bowling_record.sql` | Jason Raubenheimer's eight-wicket tournament record is present for the 2023 USSA competition. | Data present; no direct ledger entry |
| `20261111630000_add_2018_ussa_cricket_cut_bowling_figures.sql` | The three sourced 2018 UCT play-off bowling rows are present: Nealan van Heerden 3/10, Jason Raubenheimer 3/21 and Devon du Plessis 3/24. | Data present; no direct ledger entry |
| `20261111640000_import_2012_ussa_cricket_cut_participation.sql` | The 2012 USSA Cricket participation record exists with the three wins, two losses and retention of A Section status; no unsupported match or player rows are present. | Data present; no direct ledger entry |

The 2018 USSA A Section match is a separate competition from the 2018 Varsity Cricket group-stage match already documented above. Both competition records and their distinct match rows are present. No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2010–2013 Free State and national club cricket

Five further cricket history files were compared with production. None has a matching live migration-ledger entry; all intended competition and match records are present.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111650000_import_2011_national_cricket_club_championship_cut_third_place.sql` | 2011 National Cricket Club Championship exists as completed, with CUT's third-place finish. Four indexed Section One fixtures are present; scores remain null because accessible source scorecards were not verified. | Data present; no direct ledger entry |
| `20261111660000_import_2010_2011_free_state_super_league_cricket_titles.sql` | Separate completed 2010 and 2011 Free State Super League title records exist. | Data present; no direct ledger entry |
| `20261111670000_import_2011_national_club_championship_cut_fixtures.sql` | All four 19–23 September 2011 fixtures exist under the 2011 National Cricket Club Championship, with no invented scores or player figures. | Data present; no direct ledger entry |
| `20261111680000_import_2012_national_club_championship_cut_campaign.sql` | 2012 National Club Championship Section Two exists with four fixtures; the 23 April UWC match is recorded as CUT 243/7 defeating UWC 188, and Ian O'Neill's 97 is present. Three other indexed fixtures retain null scores. | Data present; no direct ledger entry |
| `20261111690000_import_2013_free_state_cricket_league_achievements.sql` | 2013 Free State Super League record exists: CUT first team second, with CUT second and third teams recorded as champions of their respective leagues. | Data present; no direct ledger entry |

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2014–2018 cricket achievements and enrichment

Five more files were reviewed. None has a matching live migration-ledger entry by the current name; the intended competition descriptions, matches and player records are present.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111700000_import_2014_cut_cricket_achievements.sql` | Both the 2014 Free State Cricket First Division title and 2014 USSA Cricket participation/SA team selection record exist with the expected metadata. | Data present; no direct ledger entry |
| `20261111710000_import_2015_cut_welkom_varsity_pro20_cricket_title.sql` | The 2015 Varsity Pro-20 Student Cricket Tournament exists with CUT Welkom Campus recorded as winner. | Data present; no direct ledger entry |
| `20261111720000_enrich_2015_16_cut_cricket_awards_and_2016_national_campaign.sql` | The 2015/16 MCA title description includes the reported 160-run season highlight, 6/20 bowling figures and provincial awards. The 2016 National Club Championship dates and five-match campaign are present, along with the accessible match/player details. | Data present; no direct ledger entry |
| `20261111730000_enrich_2018_varsity_cricket_cut_tournament_context.sql` | The 2018 Varsity Cricket description includes the sourced UP-Tuks group-stage win with bonus point and explicitly does not invent CUT's score or final placing. | Data present; no direct ledger entry |
| `20261111740000_reconcile_2018_ussa_cricket_seventh_place.sql` | The 2018 USSA Cricket A Section description contains the seventh-place finish, 180–76 UCT play-off result and three sourced bowling figures. | Data present; no direct ledger entry |

### Cricket-statistics representation note

Some historical cricket batting, bowling and award records are stored in `competition_player_statistics.statistics` JSONB. The legacy numeric `field_goals`, `penalty_corner_goals`, `penalty_stroke_goals` and `total_goals` columns are zero placeholders on those cricket rows; they must not be interpreted as a cricket player's runs or wickets. The app's cricket presentation should read the typed values from `statistics` and label them by `stat_category`.

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2012–2023 Mangaung / Free State cricket leagues

Five more historical competition files were reviewed. None has a matching migration-ledger entry by current name. All five competition records are present in production.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111750000_import_2019_mca_cricket_cut_team_records.sql` | 2019 MCA League competition exists with CUT 1 and CUT 2 source figures and the documented one-match arithmetic discrepancy. Separate live standings rows place CUT 1 sixth and CUT 2 seventh; their provenance is expected in the later standings-backfill migration and is not attributed to this seed file. | Competition data present; later standings lineage pending review |
| `20261111760000_import_2021_mca_cricket_cut_participation.sql` | 2021 MCA League participation record exists for October–November 2021; no unsupported standings or results were added. | Data present; no direct ledger entry |
| `20261111770000_import_2023_mca_cricket_cut_participation.sql` | 2023 MCA League participation record exists; the annual-report description distinguishes MCA participation from the separately mentioned Free State Cricket League and FCSU League. | Data present; no direct ledger entry |
| `20261111780000_import_2022_mca_first_round_cricket.sql` | Separate 2022/23 MCA first-round record exists with 8 October–26 November 2022 dates. It remains distinct from the 2021/22 MCA season that ended in March 2022. | Data present; no direct ledger entry |
| `20261111790000_import_2012_free_state_cricket_league_achievements.sql` | 2012 Free State Cricket Leagues record exists with first-team second place and second/third-team league titles; no unsupported fixture or scorecard rows were added. | Data present; no direct ledger entry |

The 2019 MCA source's CUT 1 figures still contain the documented arithmetic gap: 8 played, 3 wins, 4 losses and 0 no-results account for only 7 matches. The source values are preserved and no missing outcome is inferred.

No production data, schema, migration history or deployment was changed during this batch.


## Security and permissions reconciliation — 19 November 2026

A read-only review was performed against the live Supabase catalog and migration ledger for the core athlete approval, fixture result review, Yoco checkout, shop administration, anonymous access and public-season policies.

### Migration ledger matches

The following repository migrations are present in the live ledger under their exact versions and names:

- `20261106004403_scoped_operations_athlete_approval_and_publishing`
- `20261106004631_protect_athlete_visibility_and_index_result_submissions`
- `20261106004647_allow_private_athlete_edits_without_approval`
- `20261106004922_publish_reviewed_fixture_results_atomically`
- `20261106010233_add_service_role_policy_for_yoco_webhook_events`
- `20261106010527_tighten_client_grants_for_checkout_tables`
- `20261106011716_shop_admin_product_catalog_management`
- `20261116142045_index_uncovered_foreign_keys`
- `20261116142716_consolidate_sports_read_policies`
- `20261116165748_consolidate_teams_read_policies`
- `20261116165921_consolidate_articles_events_read_policies`
- `20261116170900_scope_public_seasons_and_preserve_heritage_reads`

### Live security controls verified

- All 19 reviewed core tables (including athletes, athlete statistics/achievements/media, fixture submissions, orders, tickets, products, Yoco webhook events, competitions and competition statistics) have RLS enabled.
- No RLS-disabled ordinary table was found in the public schema during the broader scan.
- No public-schema table was found granting `anon` INSERT, UPDATE, DELETE or TRUNCATE.
- The client privilege hardening is reflected in the live grants: `orders`, `order_items` and `tickets` have authenticated SELECT only; anonymous users have no table privileges on these checkout records; authenticated users have no TRUNCATE on the reviewed tables.
- `yoco_webhook_events` has no anon/authenticated table grants and has a single explicit `FOR ALL TO service_role` policy.
- `products` has authenticated DML grants because the later `shop_admin_product_catalog_management` migration intentionally restores them. Its RLS policy limits all product management operations to users with `shop_admin` or `super_admin`; anonymous users retain SELECT only.
- Athlete profile, statistic, achievement and media tables have publication/ownership/assigned-staff policies. Their write policies are assigned-staff scoped; approval/publishing fields are additionally protected by trigger guards.
- Fixture result submissions are restricted to authenticated assigned staff; the submit policy enforces the caller as submitter and starts the row in pending status. Official publication is through `public.publish_fixture_result_submission(uuid,text)`, which is SECURITY INVOKER, requires `auth.uid()`, checks `private.can_manage_sport`, updates the fixture and accepts the submission atomically. Execute is revoked from PUBLIC/anon and granted to authenticated.
- The sports, teams, articles and events public-read policies reflect the intended active/published-only model. Authenticated users additionally read assigned records.
- The competition read policy is present for anon/authenticated: current and previous year seasons, Varsity Netball/Football/Cup records, and competitions with a positive win value in standings. The match and player/team competition statistics tables retain public SELECT policies and assigned-sport-admin management policies, supporting public historical result browsing.
- The reviewed trigger functions are SECURITY INVOKER. SECURITY DEFINER helpers in the private schema use a fixed empty search path; management helpers require a non-null authenticated UID. Public SECURITY DEFINER RPCs found in the scan deny anon execution and include authentication/authorization checks in their bodies.

### Conditional default-privilege portability risk

The live database has separate default ACLs for objects created by `postgres` and `supabase_admin`.

- For objects created by `postgres`, the current public-schema default table ACL gives anon SELECT and authenticated SELECT/INSERT/UPDATE/DELETE (but not TRUNCATE/REFERENCES/TRIGGER/MAINTAIN), consistent with the hardening migration.
- For objects created by `supabase_admin`, the default table ACL still gives anon and authenticated the full table privilege set (`arwdDxtm`). The 16 November hardening migration alters default privileges for `postgres` only, not `supabase_admin`.
- The inspected core tables (athletes, competitions, orders, products, profiles and Yoco webhook events) are owned by `postgres`, and the current live schema scan found no RLS-disabled ordinary public tables or anon DML grants.

This is a **conditional future-object risk**, not evidence of a current table exposure: if future migrations create exposed public tables as `supabase_admin`, they may inherit broad anon/authenticated grants. Future schema changes should use the established `postgres` migration owner or explicitly harden `supabase_admin` default privileges as a separately reviewed migration. Do not change default ACLs during this portability audit.

### Security reconciliation conclusion

The reviewed live security state matches the expected role model for existing tables. The shop-admin product DML grants are intentional and constrained by RLS. The main portability follow-up is to standardize the migration execution role and decide whether to harden the `supabase_admin` default ACL. This audit did not alter any policy, grant, function, table, row, migration-ledger entry or deployment.


## Follow-on reconciliation batch: 2016 cricket fixtures and 2017–2019 hockey history

Five further files were checked. None has a matching migration-ledger entry. Their intended records are present in the live database.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111800000_import_2016_national_club_championship_cut_fixtures.sql` | All five 2016 National Club Championship fixtures exist under the correct competition. Four retain null scores because the indexed scorecards were not verified; the Union Stars fixture is enriched separately. | Data present; no direct ledger entry |
| `20261111810000_enrich_2016_national_club_championship_cut_vs_union_stars.sql` | Union Stars' 261/6 vs CUT's 89 all out, 172-run result and the sourced player batting/bowling figures are present. | Data present; no direct ledger entry |
| `20261111900000_add_official_cut_source_to_2019_varsity_cricket.sql` | The 2019 Varsity Cricket description now cites the CUT Annual Report as independent confirmation of participation, while retaining the UP-Tuks six-wicket result and no unsupported score/date. | Live description reflects source clarification |
| `20261111910000_import_2018_2019_ussa_mens_hockey_records.sql` | 2018 USSA Men B-Section and 2019 USSA Men C-Section competitions exist with the five 2018 losses, five 2019 match results, fifth-place finish and Zandre Pretorius' nine-goal total. The file itself notes that equivalent records were applied directly before it was committed. | Data present; no direct ledger entry |
| `20261111920000_import_2017_ussa_hockey_team_participation.sql` | Separate 2017 men's and women's USSA Hockey participation records exist, with no unsupported section, placing or match data. | Data present; no direct ledger entry |

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2009 and 2014 hockey, hockey standings backfills and 2025 cricket

Five additional files were reviewed. None has a matching migration-ledger entry by current name; all intended production rows are present.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111930000_import_2009_free_state_hockey_third_place.sql` | 2009 Free State men's hockey competition exists; the third-place match is recorded 4–4, with the 4–3 UFS Reds shoot-out win held in the match's JSONB statistics. | Data present; no direct ledger entry |
| `20261111940000_import_2014_ussa_hockey_team_placements.sql` | 2014 men's and women's USSA Hockey competitions exist, with CUT men's 4th and women's C-Section 2nd standings. | Data present; no direct ledger entry |
| `20261111950000_backfill_2018_2019_ussa_hockey_standings.sql` | 2018 CUT men's B-Section 6th and 2019 CUT men's C-Section 5th standings exist with the expected played/win/draw/loss and goal totals. | Data present; no direct ledger entry |
| `20261111960000_add_2014_ussa_hockey_standings.sql` | CUT's 2014 men's 4th and women's 2nd standings are present. Unpublished match totals remain zero/default rather than being invented. | Data present; no direct ledger entry |
| `20261111970000_add_2025_ussa_cricket_group_b_standing.sql` | CUT's 2025 USSA Cricket Group B fourth-place standing is present (five played, two wins, three losses). It is not represented as an overall tournament placing. | Data present; no direct ledger entry |

The 2009 hockey record correctly distinguishes the regulation-time 4–4 draw from the shoot-out score stored in JSONB (UFS Reds 4, CUT 1 3). The 2018/2019 hockey standings also account for the team-position rows referenced in the earlier competition/match review.

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: cricket standings, player-name enrichment and source corrections

Five further files were checked. None has a matching live migration-ledger entry by current name. Their intended production changes are present.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261111980000_add_2023_ussa_cricket_pool_b_standing.sql` | CUT's 2023 USSA Cricket Pool B, Section 2 first-place standing exists: 3 played, 3 wins, 15 points, 610 runs scored and 427 conceded. | Data present; no direct ledger entry |
| `20261111990000_add_2014_free_state_cricket_first_division_title.sql` | The 2014 Free State Cricket First Division has the CUT Second Team — First Division champions row at position 1. | Data present; no direct ledger entry |
| `20261112010000_expand_2015_16_cut_cricket_player_names.sql` | The two MCA League records are expanded to Koot Pienaar (160 runs) and Marlon James (6/20), with the Netwerk24 name-expansion source retained. | Data present; no direct ledger entry |
| `20261112020000_backfill_2019_mca_cricket_cut_standings.sql` | CUT 1 sixth and CUT 2 seventh standings exist with the published match/points values. CUT 1's one-match arithmetic gap remains explicit; no missing result is inferred. | Data present; no direct ledger entry |
| `20261112030000_add_official_cut_source_to_2018_cricket_records.sql` | Both 2018 Varsity Cricket and 2018 USSA Cricket descriptions include the CUT Annual Report 2018 as independent participation corroboration. | Live descriptions reflect source clarification |

The 2019 MCA standings confirm the source positions while preserving the one unexplained CUT 1 result. The 2015/16 name expansion changes display names only; it retains the original runs, wickets and award facts.

No production data, schema, migration history or deployment was changed during this batch.


## Follow-on reconciliation batch: 2021–2025/26 cricket source and participation context

Four further files were reviewed. None has a matching live migration-ledger entry by current name; all intended production descriptions or competition records are present.

| Repository file | Live database evidence | Classification |
|---|---|---|
| `20261112040000_add_official_source_to_2021_22_mca_cricket_record.sql` | The 2021/22 MCA record includes the official CUT Annual Report 2022 source and the CUT 1 first / CUT 2 fourth final positions. | Live description reflects source clarification |
| `20261112050000_add_ussa_2021_cricket_timing_context.sql` | The 2021 USSA Cricket description retains both date references: CUT's annual report categorises participation under December 2021, while UFH's later report indicates the event was held in January 2022. No match results are inferred. | Live description reflects timing reconciliation and source discrepancy |
| `20261112060000_add_2023_free_state_cricket_competitions.sql` | Both distinct 2023 records exist: Free State Cricket League and Free State Cricket Union League — First Round. | Data present; no direct ledger entry |
| `20261112070000_add_official_source_to_2025_26_mangaung_cricket_league.sql` | The 2025/26 Mangaung Cricket League description includes the direct CUT Annual Report source, with participation and dates only. | Live description reflects source clarification |

No production data, schema, migration history or deployment was changed during this batch.


## Final unmatched-file check: 2018 Varsity Cricket tournament dates

`20261111590000_set_2018_varsity_cricket_tournament_dates.sql` has no matching live migration-ledger entry by current name. The target 2018 Varsity Cricket competition exists with the expected 29 January–3 February 2018 dates, its sourced competition context and one group-stage match row. The date correction is therefore reflected in live data, but the file is not ledger-confirmed.

No production data, schema, migration history or deployment was changed during this check.


## Reconciliation of the 19 live-ledger entries with no current repository filename

The final comparison found 19 rows in `supabase_migrations.schema_migrations` whose normalized names do not match any current migration filename. Exact GitHub path-history checks returned no commit history for the corresponding timestamp-prefixed paths. One entry has a strong equivalent current file; the other 18 are represented in the live schema but their original SQL source is absent from the current repository branch.

| Applied ledger version | Ledger name | Live database evidence | Portability classification |
|---|---|---|---|
| `20261101215551` | `initial_cut_sport_schema` | The live public schema contains the core CUT Sport tables, constraints, indexes and RLS policies. No source file or exact path history exists in the current repository. | **Critical source gap:** baseline schema must be recovered or reconstructed before a clean database can be built from Git |
| `20261105183759` | `add_sponsors_catalog` | `public.sponsors` exists with RLS, public read for active sponsors and sport-admin/super-admin management. Current row count: 0. | Live effect present; original SQL source missing |
| `20261105225033` | `athlete_and_sport_admin_profiles` | `sport_admin_profiles`, `sport_admin_assignments` and `sport_admin_activity_logs` exist with RLS and expected primary/scope indexes. Current row counts: 0. | Live effect present; original SQL source missing |
| `20261105225119` | `tighten_profile_rls_and_scoped_admin_access` | RLS is enabled on profiles and sport-admin tables. Current policies scope admin profile/assignment visibility to the owner or super admin and reserve assignment changes for super admins. | Live security state present; original SQL source missing |
| `20261105225213` | `index_athlete_admin_profile_relations` | Athlete profile/player-profile link indexes and sport-admin assignment sport/team indexes exist. | Live indexes present; original SQL source missing |
| `20261105225227` | `remove_duplicate_athlete_read_policy` | The current `athletes` table has distinct public-published and athlete-own-profile SELECT policies; no duplicate policy with the same purpose was found in the inspected policy set. | Live policy state present; original SQL source missing |
| `20261105225306` | `enforce_team_scoped_staff_permissions` | `private.can_manage_athlete` exists as a security-definer function and current athlete/achievement/statistics/membership policies invoke it with sport/team scope. | Live security state present; original SQL source missing |
| `20261111095426` | `competition_standings_and_multi_sport_competitions` | The current `20261111143000_add_multi_sport_competition_standings.sql` file and live table/policy state are a strong equivalent; see the standings-schema lineage note above. | Strong equivalent current source found |
| `20261112004826` | `athlete_canonical_profile_link_audit` | `athlete_player_profile_link_audit` exists with RLS, super-admin-only SELECT policy, and the private audit/synchronisation functions. Current row count: 0. | Live effect present; original SQL source missing |
| `20261112005817` | `persistent_athlete_data_quality_reviews` | `athlete_data_quality_reviews` and `athlete_data_quality_review_history` exist with RLS and assigned-staff review policies. Both currently contain 0 rows. | Live effect present; original SQL source missing |
| `20261112005906` | `tighten_athlete_data_quality_review_grants` | Data-quality review tables grant authenticated users SELECT only; writes are reserved to service_role. No anon table grant is present. | Live grant state present; original SQL source missing |
| `20261112171159` | `team_hub_social_content_calendar` | `team_hub_social_content` exists with RLS, season-scoped create/read/update/delete policies and a season/schedule index. Current row count: 0. | Live effect present; original SQL source missing |
| `20261112171622` | `cut_sport_private_media_library` | `team_hub_media_assets` exists with RLS; the `cut-sport-media` bucket is private and has team/season-scoped storage policies. Current asset row count: 0. | Live effect present; original SQL source missing |
| `20261112171854` | `cut_sport_media_free_plan_upload_limit` | The private `cut-sport-media` bucket has a 52,428,800-byte (50 MiB) file limit; the media table also constrains `size_bytes` to the same maximum. | Live limit present; original SQL source missing |
| `20261112203558` | `student_journey_hot_path_indexes` | Relevant profile, athlete, player-profile, team-membership, sport-admin and fixture indexes exist, including athlete/profile and membership lookup indexes. | Live indexes present; original SQL source missing |
| `20261112203649` | `rls_auth_uid_initplan_optimization` | Inspected athlete, sponsor, admin, Team Hub, media and attendance policy definitions use scalar subqueries such as `(SELECT auth.uid())` rather than repeated per-row `auth.uid()` evaluation. | Live policy state present; original SQL source missing |
| `20261113152908` | `add_fixture_match_attendance` | `team_hub_fixture_attendance` exists with RLS, fixture/season/member foreign keys, a unique fixture/member index and status/note fields. Current row count: 0. | Live effect present; original SQL source missing |
| `20261113152922` | `scope_fixture_attendance_policy_rows` | Attendance policies require assigned Team Hub season access, a matching non-cancelled fixture and a selected/retained season member; players can read their own attendance. | Live security state present; original SQL source missing |
| `20261113153029` | `restrict_fixture_attendance_table_grants` | `team_hub_fixture_attendance` grants authenticated users INSERT/SELECT/UPDATE only; no anon grant and no authenticated DELETE grant. service_role retains backend access. | Live grant state present; original SQL source missing |

### Ledger-only source-gap conclusion

- All 19 ledger-only entries have corresponding live objects or security/index state; the competition-standings entry has a strong equivalent current file.
- 18 original migration SQL sources are not present in the current repository branch and have no exact-path GitHub commit history.
- The initial schema migration is the most important gap. Without its source, the current repository cannot be treated as a complete reproducible database baseline.
- Several Team Hub and audit structures are present but currently empty: sponsors, sport-admin profiles/assignments/activity logs, athlete identity-link audit, athlete data-quality reviews/history, Team Hub seasons/social content/media assets and fixture attendance all have zero rows in the inspected production state.
- The private `cut-sport-media` bucket is 50 MiB per file and is not public. The database's Team Hub media and fixture-attendance policies are scoped to authorised season access.
- Do not delete or rename these ledger rows, fabricate historical source SQL, or run migration repair/push/reset operations. The next safe portability step is to recover the original SQL where possible and generate a reviewed schema baseline from the live project for the unrecoverable initial schema; then compare that baseline against the full current Git migration chain in a disposable database.

No production schema, data, grants, migration ledger or deployment was changed during this reconciliation.
