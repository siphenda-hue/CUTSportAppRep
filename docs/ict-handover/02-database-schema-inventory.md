# CUT Sport — Database Schema Inventory

**Snapshot:** 25 November 2026  
**Project:** Supabase `CUT Sport` (`tnkykdfxzwaqzbichxcl`), region `sa-east-1`, PostgreSQL 17  
**Scope:** `public` schema; 67 tables, 784 columns, 179 declared foreign-key constraints.

Row counts are point-in-time observations and will change. This catalogue excludes record values and secrets.

## Identity, profiles and administration

### `profiles` — 8 columns; observed rows: 1; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | — |
| `full_name` | `text` | nullable |
| `email` | `text` | nullable |
| `phone` | `text` | nullable |
| `student_number` | `text` | nullable, unique |
| `avatar_url` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `user_roles` — 4 columns; observed rows: 1; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `user_id` | `uuid` | — |
| `role` | `USER-DEFINED` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `sport_admin_profiles` — 10 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `profile_id` | `uuid` | — |
| `job_title` | `text` | — |
| `department` | `text` | default `'CUT Sport'::text` |
| `bio` | `text` | nullable |
| `office_location` | `text` | nullable |
| `official_email` | `text` | nullable |
| `official_phone` | `text` | nullable |
| `employment_status` | `text` | default `'active'::text`; check `employment_status = ANY (ARRAY['active'::text, 'inactive'::text, 'former'::text])` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `profile_id`.
### `sport_admin_assignments` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `admin_profile_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | nullable |
| `assignment_role` | `text` | check `assignment_role = ANY (ARRAY['sport_admin'::text, 'team_manager'::text, 'coach'::text])` |
| `starts_on` | `date` | nullable |
| `ends_on` | `date` | nullable |
| `is_active` | `boolean` | default `true` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `sport_admin_activity_logs` — 7 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `actor_id` | `uuid` | nullable |
| `action` | `text` | — |
| `entity_type` | `text` | — |
| `entity_id` | `uuid` | nullable |
| `details` | `jsonb` | default `'{}'::jsonb`; check `jsonb_typeof(details) = 'object'::text` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_staff_profiles` — 13 columns; observed rows: 3; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | nullable |
| `display_name` | `text` | check `length(btrim(display_name)) >= 2 AND length(btrim(display_name)) <= 120` |
| `role_title` | `text` | check `length(btrim(role_title)) >= 2 AND length(btrim(role_title)) <= 100` |
| `bio` | `text` | nullable; check `bio IS NULL OR length(bio) <= 1200` |
| `photo_url` | `text` | nullable; check `photo_url IS NULL OR photo_url ~ '^https?://'::text` |
| `display_order` | `integer` | default `0`; check `display_order >= 0 AND display_order <= 9999` |
| `is_published` | `boolean` | default `false` |
| `created_by` | `uuid` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `photo_path` | `text` | nullable |
Primary key: `id`.

## Sport, teams and competitions

### `sports` — 7 columns; observed rows: 13; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `name` | `text` | unique |
| `slug` | `text` | unique |
| `description` | `text` | nullable |
| `image_url` | `text` | nullable |
| `is_active` | `boolean` | default `true` |
| `display_order` | `integer` | default `0` |
Primary key: `id`.
### `teams` — 10 columns; observed rows: 17; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `sport_id` | `uuid` | — |
| `name` | `text` | — |
| `category` | `text` | nullable |
| `season` | `text` | nullable |
| `coach_name` | `text` | nullable |
| `image_url` | `text` | nullable |
| `is_active` | `boolean` | default `true` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `competition_id` | `uuid` | nullable |
Primary key: `id`.
### `competitions` — 9 columns; observed rows: 102; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `sport_id` | `uuid` | nullable |
| `name` | `text` | — |
| `season` | `text` | nullable |
| `start_date` | `date` | nullable |
| `end_date` | `date` | nullable |
| `venue` | `text` | nullable |
| `description` | `text` | nullable |
| `status` | `text` | default `'upcoming'::text` |
Primary key: `id`.
### `fixtures` — 14 columns; observed rows: 80; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | nullable |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | nullable |
| `opponent` | `text` | — |
| `venue` | `text` | nullable |
| `starts_at` | `timestamp with time zone` | — |
| `status` | `USER-DEFINED` | default `'scheduled'::fixture_status` |
| `home_score` | `integer` | nullable |
| `away_score` | `integer` | nullable |
| `result_summary` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `competition_match_id` | `uuid` | nullable |
| `source_url` | `text` | nullable |
Primary key: `id`.
### `fixture_result_submissions` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `fixture_id` | `uuid` | — |
| `submitted_by` | `uuid` | default `auth.uid()` |
| `home_score` | `integer` | check `home_score >= 0` |
| `away_score` | `integer` | check `away_score >= 0` |
| `result_summary` | `text` | nullable |
| `review_status` | `text` | default `'pending'::text`; check `review_status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])` |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
| `review_note` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `competition_standings` — 19 columns; observed rows: 220; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | — |
| `team_name` | `text` | — |
| `team_logo_url` | `text` | nullable |
| `group_name` | `text` | nullable |
| `position` | `integer` | nullable |
| `played` | `integer` | default `0`; check `played >= 0` |
| `won` | `integer` | default `0`; check `won >= 0` |
| `drawn` | `integer` | default `0`; check `drawn >= 0` |
| `lost` | `integer` | default `0`; check `lost >= 0` |
| `scored` | `integer` | default `0`; check `scored >= 0` |
| `conceded` | `integer` | default `0`; check `conceded >= 0` |
| `points_difference` | `integer` | nullable |
| `bonus_points` | `integer` | default `0`; check `bonus_points >= 0` |
| `points` | `integer` | default `0`; check `points >= 0` |
| `source_url` | `text` | nullable |
| `source_checked_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `competition_matches` — 17 columns; observed rows: 244; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | — |
| `source_match_id` | `text` | — |
| `starts_at` | `timestamp with time zone` | nullable |
| `home_team` | `text` | — |
| `away_team` | `text` | — |
| `home_score` | `integer` | nullable |
| `away_score` | `integer` | nullable |
| `match_status` | `text` | default `'scheduled'::text` |
| `match_round` | `text` | nullable |
| `group_name` | `text` | nullable |
| `venue` | `text` | nullable |
| `source_url` | `text` | — |
| `source_checked_at` | `timestamp with time zone` | default `now()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `statistics` | `jsonb` | default `'{}'::jsonb` |
Primary key: `id`.
### `competition_player_statistics` — 15 columns; observed rows: 181; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | — |
| `player_name` | `text` | — |
| `team_name` | `text` | — |
| `squad_number` | `integer` | nullable |
| `field_goals` | `integer` | default `0` |
| `penalty_corner_goals` | `integer` | default `0` |
| `penalty_stroke_goals` | `integer` | default `0` |
| `total_goals` | `integer` | default `0` |
| `source_url` | `text` | — |
| `source_checked_at` | `timestamp with time zone` | default `now()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `statistics` | `jsonb` | default `'{}'::jsonb` |
| `player_profile_id` | `uuid` | nullable |
Primary key: `id`.
### `competition_team_statistics` — 12 columns; observed rows: 53; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | — |
| `team_name` | `text` | — |
| `field_goals` | `integer` | default `0` |
| `penalty_corner_goals` | `integer` | default `0` |
| `penalty_stroke_goals` | `integer` | default `0` |
| `total_goals` | `integer` | default `0` |
| `source_url` | `text` | — |
| `source_checked_at` | `timestamp with time zone` | default `now()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `statistics` | `jsonb` | default `'{}'::jsonb` |
Primary key: `id`.
### `competition_squads` — 10 columns; observed rows: 22; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | — |
| `team_name` | `text` | check `length(TRIM(BOTH FROM team_name)) > 0` |
| `squad_label` | `text` | default `'Main squad'::text`; check `length(TRIM(BOTH FROM squad_label)) > 0` |
| `is_complete` | `boolean` | default `false` |
| `source_url` | `text` | nullable |
| `source_checked_at` | `timestamp with time zone` | nullable |
| `notes` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `competition_squad_members` — 11 columns; observed rows: 190; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `squad_id` | `uuid` | — |
| `player_name` | `text` | check `length(TRIM(BOTH FROM player_name)) > 0` |
| `squad_number` | `integer` | nullable; check `squad_number IS NULL OR squad_number >= 0` |
| `position` | `text` | nullable |
| `role` | `text` | nullable |
| `is_captain` | `boolean` | default `false` |
| `is_vice_captain` | `boolean` | default `false` |
| `display_order` | `integer` | default `0` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `player_profile_id` | `uuid` | nullable |
Primary key: `id`.
### `competition_honours` — 13 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `competition_id` | `uuid` | — |
| `winning_team` | `text` | check `length(btrim(winning_team)) > 0` |
| `achievement_type` | `text` | default `'champion'::text`; check `achievement_type = ANY (ARRAY['champion'::text, 'runner_up'::text, 'third_place'::text, 'promotion'::text, 'other'::text])` |
| `season` | `text` | nullable |
| `source_url` | `text` | check `source_url ~* '^https?://'::text` |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `recorded_by` | `uuid` | nullable |
| `approved_by` | `uuid` | nullable |
| `approved_at` | `timestamp with time zone` | nullable |
| `review_note` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.

## Athlete records and career history

### `athletes` — 32 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `profile_id` | `uuid` | nullable |
| `team_id` | `uuid` | nullable |
| `full_name` | `text` | — |
| `position` | `text` | nullable |
| `squad_number` | `integer` | nullable |
| `bio` | `text` | nullable |
| `photo_url` | `text` | nullable |
| `is_featured` | `boolean` | default `false` |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `sport_id` | `uuid` | nullable |
| `preferred_name` | `text` | nullable |
| `gender` | `text` | nullable; check `gender IS NULL OR (gender = ANY (ARRAY['female'::text, 'male'::text, 'non_binary'::text, 'prefer_not_to_say'::text]))` |
| `nationality` | `text` | nullable |
| `hometown` | `text` | nullable |
| `province` | `text` | nullable |
| `faculty` | `text` | nullable |
| `qualification` | `text` | nullable |
| `year_of_study` | `smallint` | nullable; check `year_of_study IS NULL OR year_of_study >= 1 AND year_of_study <= 12` |
| `student_status` | `text` | default `'current'::text`; check `student_status = ANY (ARRAY['current'::text, 'alumni'::text, 'former'::text, 'staff'::text])` |
| `years_representing_cut` | `smallint` | nullable; check `years_representing_cut IS NULL OR years_representing_cut >= 0` |
| `previous_clubs` | `ARRAY` | default `'{}'::text[]` |
| `profile_visibility` | `text` | default `'public'::text`; check `profile_visibility = ANY (ARRAY['public'::text, 'private'::text])` |
| `verified_at` | `timestamp with time zone` | nullable |
| `verified_by` | `uuid` | nullable |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `review_note` | `text` | nullable; Latest administrator review note; visible only through authorized athlete access. |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
| `player_profile_id` | `uuid` | nullable |
| `player_profile_link_note` | `text` | nullable |
Primary key: `id`.
### `athlete_team_memberships` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `position` | `text` | nullable; check `"position" IS NULL OR length("position") <= 120` |
| `squad_number` | `integer` | nullable; check `squad_number IS NULL OR squad_number >= 0 AND squad_number <= 999` |
| `is_active` | `boolean` | default `true` |
| `joined_at` | `date` | default `CURRENT_DATE` |
| `left_at` | `date` | nullable |
| `created_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `athlete_competitions` — 8 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `competition_id` | `uuid` | — |
| `team_id` | `uuid` | nullable |
| `season` | `text` | nullable |
| `participation_status` | `text` | default `'participated'::text`; check `participation_status = ANY (ARRAY['selected'::text, 'participated'::text, 'withdrawn'::text, 'injured'::text, 'reserve'::text])` |
| `notes` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `athlete_statistics` — 16 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `competition_id` | `uuid` | nullable |
| `fixture_id` | `uuid` | nullable |
| `season` | `text` | nullable |
| `period_label` | `text` | nullable |
| `metrics` | `jsonb` | default `'{}'::jsonb`; check `jsonb_typeof(metrics) = 'object'::text` |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `recorded_by` | `uuid` | nullable |
| `approved_by` | `uuid` | nullable |
| `approved_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `review_note` | `text` | nullable; Latest administrator review note; visible only through authorized athlete access. |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
Primary key: `id`.
### `athlete_achievements` — 15 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `title` | `text` | — |
| `description` | `text` | nullable |
| `category` | `text` | nullable |
| `award_date` | `date` | nullable |
| `competition_id` | `uuid` | nullable |
| `is_verified` | `boolean` | default `false` |
| `verified_by` | `uuid` | nullable |
| `verified_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `review_status` | `text` | default `'pending'::text`; check `review_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])`; Pending, approved or rejected review state. |
| `review_note` | `text` | nullable |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
Primary key: `id`.
### `athlete_media` — 17 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `media_type` | `text` | check `media_type = ANY (ARRAY['photo'::text, 'video'::text, 'certificate'::text, 'document'::text])` |
| `title` | `text` | nullable |
| `description` | `text` | nullable |
| `storage_path` | `text` | nullable |
| `external_url` | `text` | nullable |
| `visibility` | `text` | default `'public'::text`; check `visibility = ANY (ARRAY['public'::text, 'private'::text])` |
| `sort_order` | `integer` | default `0` |
| `uploaded_by` | `uuid` | nullable |
| `approved_by` | `uuid` | nullable |
| `approved_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `review_status` | `text` | default `'pending'::text`; check `review_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])`; Pending, approved or rejected review state. |
| `review_note` | `text` | nullable |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
Primary key: `id`.
### `athlete_messages` — 10 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `sender_id` | `uuid` | — |
| `recipient_id` | `uuid` | — |
| `parent_message_id` | `uuid` | nullable |
| `subject` | `text` | check `char_length(btrim(subject)) >= 1 AND char_length(btrim(subject)) <= 160` |
| `body` | `text` | check `char_length(btrim(body)) >= 1 AND char_length(btrim(body)) <= 5000` |
| `message_type` | `text` | default `'general'::text`; check `message_type = ANY (ARRAY['general'::text, 'correction'::text, 'announcement'::text])` |
| `read_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `athlete_review_history` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `record_type` | `text` | check `record_type = ANY (ARRAY['athlete'::text, 'statistics'::text, 'achievement'::text, 'media'::text])` |
| `record_id` | `uuid` | — |
| `from_status` | `text` | nullable |
| `to_status` | `text` | — |
| `previous_note` | `text` | nullable |
| `review_note` | `text` | nullable |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
| `changed_by` | `uuid` | nullable |
| `changed_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `player_profiles` — 11 columns; observed rows: 279; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `full_name` | `text` | unique |
| `display_name` | `text` | nullable |
| `claimed_by` | `uuid` | nullable, unique |
| `claimed_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `profile_visibility` | `text` | default `'public'::text`; check `profile_visibility = ANY (ARRAY['public'::text, 'private'::text])` |
| `photo_path` | `text` | nullable |
| `photo_approved_at` | `timestamp with time zone` | nullable |
| `photo_approved_by` | `uuid` | nullable |
Primary key: `id`.
### `player_profile_claims` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `player_profile_id` | `uuid` | — |
| `user_id` | `uuid` | — |
| `evidence_note` | `text` | nullable |
| `status` | `text` | default `'pending'::text`; check `status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
| `review_note` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `player_match_statistics` — 20 columns; observed rows: 14; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `player_name` | `text` | check `length(btrim(player_name)) > 0` |
| `player_profile_id` | `uuid` | nullable |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | nullable |
| `competition_id` | `uuid` | nullable |
| `fixture_id` | `uuid` | nullable |
| `competition_match_id` | `uuid` | nullable |
| `team_name` | `text` | check `length(btrim(team_name)) > 0` |
| `opponent` | `text` | check `length(btrim(opponent)) > 0` |
| `match_date` | `date` | — |
| `metrics` | `jsonb` | default `'{}'::jsonb`; check `jsonb_typeof(metrics) = 'object'::text` |
| `source_url` | `text` | check `source_url ~* '^https?://'::text` |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'correction_requested'::text])` |
| `recorded_by` | `uuid` | nullable |
| `approved_by` | `uuid` | nullable |
| `approved_at` | `timestamp with time zone` | nullable |
| `review_note` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `player_match_statistics_review_history` — 7 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `record_id` | `uuid` | — |
| `previous_status` | `text` | nullable |
| `new_status` | `text` | — |
| `review_note` | `text` | nullable |
| `reviewer_id` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `player_international_appearances` — 22 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `player_name` | `text` | check `btrim(player_name) <> ''::text` |
| `player_profile_id` | `uuid` | nullable |
| `sport_id` | `uuid` | — |
| `country` | `text` | check `btrim(country) <> ''::text` |
| `national_team` | `text` | nullable |
| `event_name` | `text` | nullable |
| `competition_id` | `uuid` | nullable |
| `season` | `text` | nullable |
| `appearance_date` | `date` | — |
| `appearance_type` | `text` | default `'international_match'::text` |
| `opponent` | `text` | nullable |
| `caps` | `integer` | nullable; check `caps IS NULL OR caps >= 1` |
| `metrics` | `jsonb` | default `'{}'::jsonb`; check `jsonb_typeof(metrics) = 'object'::text` |
| `source_url` | `text` | check `source_url ~* '^https?://'::text` |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `recorded_by` | `uuid` | nullable |
| `approved_by` | `uuid` | nullable |
| `approved_at` | `timestamp with time zone` | nullable |
| `review_note` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `player_awards` — 18 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `player_name` | `text` | — |
| `player_profile_id` | `uuid` | nullable |
| `sport_id` | `uuid` | nullable |
| `competition_id` | `uuid` | nullable |
| `season` | `text` | nullable |
| `team_name` | `text` | nullable |
| `award_title` | `text` | — |
| `award_category` | `text` | nullable |
| `award_date` | `date` | nullable |
| `source_url` | `text` | — |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `recorded_by` | `uuid` | nullable |
| `approved_by` | `uuid` | nullable |
| `approved_at` | `timestamp with time zone` | nullable |
| `review_note` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `athlete_player_profile_link_audit` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `athlete_full_name` | `text` | — |
| `sport_id` | `uuid` | nullable |
| `team_id` | `uuid` | nullable |
| `previous_player_profile_id` | `uuid` | nullable |
| `new_player_profile_id` | `uuid` | nullable |
| `previous_profile_name` | `text` | nullable |
| `new_profile_name` | `text` | nullable |
| `changed_by` | `uuid` | nullable |
| `changed_at` | `timestamp with time zone` | default `now()` |
| `reason` | `text` | nullable |
Primary key: `id`.
### `athlete_data_quality_reviews` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `athlete_id` | `uuid` | — |
| `issue_key` | `text` | check `length(issue_key) >= 1 AND length(issue_key) <= 500` |
| `issue_type` | `text` | check `issue_type = ANY (ARRAY['duplicate'::text, 'team'::text, 'position'::text, 'number'::text, 'mismatch'::text])` |
| `status` | `text` | default `'open'::text`; check `status = ANY (ARRAY['open'::text, 'reviewed'::text, 'resolved'::text, 'dismissed'::text])` |
| `review_note` | `text` | nullable |
| `created_by` | `uuid` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_by` | `uuid` | nullable |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
Primary key: `id`.
### `athlete_data_quality_review_history` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `review_id` | `uuid` | — |
| `athlete_id` | `uuid` | — |
| `issue_key` | `text` | — |
| `issue_type` | `text` | — |
| `previous_status` | `text` | nullable |
| `new_status` | `text` | — |
| `previous_note` | `text` | nullable |
| `new_note` | `text` | nullable |
| `changed_by` | `uuid` | nullable |
| `changed_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.

## Team hub and staff operations

### `team_hub_seasons` — 15 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `season_label` | `text` | check `char_length(btrim(season_label)) >= 1 AND char_length(btrim(season_label)) <= 80` |
| `status` | `text` | default `'draft'::text`; check `status = ANY (ARRAY['draft'::text, 'in_progress'::text, 'completed'::text])` |
| `starts_on` | `date` | nullable |
| `ends_on` | `date` | nullable |
| `squad_submitted_at` | `timestamp with time zone` | nullable |
| `squad_submitted_by` | `uuid` | nullable |
| `created_by` | `uuid` | default `auth.uid()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `closed_at` | `timestamp with time zone` | nullable |
| `team_name_snapshot` | `text` | — |
| `team_category_snapshot` | `text` | nullable |
Primary key: `id`.
### `team_hub_season_members` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `athlete_id` | `uuid` | — |
| `player_profile_id` | `uuid` | nullable |
| `membership_status` | `text` | default `'selected'::text`; check `membership_status = ANY (ARRAY['selected'::text, 'retained'::text, 'released'::text])` |
| `position` | `text` | nullable |
| `squad_number` | `integer` | nullable; check `squad_number IS NULL OR squad_number >= 0 AND squad_number <= 999` |
| `selected_at` | `timestamp with time zone` | default `now()` |
| `selected_by` | `uuid` | default `auth.uid()` |
| `player_name` | `text` | nullable |
Primary key: `id`.
### `team_hub_posts` — 15 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `post_type` | `text` | check `post_type = ANY (ARRAY['practice'::text, 'squad_announcement'::text, 'instruction'::text])` |
| `status` | `text` | default `'published'::text`; check `status = ANY (ARRAY['published'::text, 'postponed'::text, 'cancelled'::text])` |
| `title` | `text` | check `char_length(btrim(title)) >= 3 AND char_length(btrim(title)) <= 180` |
| `body` | `text` | nullable; check `body IS NULL OR char_length(body) <= 5000` |
| `starts_at` | `timestamp with time zone` | nullable |
| `ends_at` | `timestamp with time zone` | nullable |
| `venue` | `text` | nullable; check `venue IS NULL OR char_length(venue) <= 240` |
| `status_note` | `text` | nullable; check `status_note IS NULL OR char_length(status_note) <= 1000` |
| `created_by` | `uuid` | default `auth.uid()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_hub_polls` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `post_id` | `uuid` | nullable |
| `poll_type` | `text` | default `'general'::text`; check `poll_type = ANY (ARRAY['attendance'::text, 'general'::text])` |
| `question` | `text` | check `char_length(btrim(question)) >= 3 AND char_length(btrim(question)) <= 500` |
| `status` | `text` | default `'open'::text`; check `status = ANY (ARRAY['open'::text, 'closed'::text])` |
| `closes_at` | `timestamp with time zone` | nullable |
| `created_by` | `uuid` | default `auth.uid()` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_hub_poll_options` — 4 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `poll_id` | `uuid` | — |
| `label` | `text` | check `char_length(btrim(label)) >= 1 AND char_length(btrim(label)) <= 120` |
| `display_order` | `integer` | default `0` |
Primary key: `id`.
### `team_hub_poll_responses` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `poll_id` | `uuid` | — |
| `option_id` | `uuid` | — |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `player_profile_id` | `uuid` | — |
| `user_id` | `uuid` | — |
| `responded_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_hub_practice_attendance` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `practice_post_id` | `uuid` | — |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `season_member_id` | `uuid` | — |
| `status` | `text` | check `status = ANY (ARRAY['present'::text, 'late'::text, 'absent'::text])` |
| `note` | `text` | nullable; check `note IS NULL OR char_length(note) <= 500` |
| `marked_by` | `uuid` | — |
| `marked_at` | `timestamp with time zone` | default `now()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_hub_player_development_notes` — 13 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `season_member_id` | `uuid` | — |
| `review_date` | `date` | default `CURRENT_DATE` |
| `category` | `text` | check `category = ANY (ARRAY['technical'::text, 'tactical'::text, 'physical'::text, 'mental'::text, 'teamwork'::text, 'general'::text])` |
| `progress_summary` | `text` | check `length(btrim(progress_summary)) >= 1 AND length(btrim(progress_summary)) <= 4000` |
| `development_focus` | `text` | nullable; check `development_focus IS NULL OR length(development_focus) <= 4000` |
| `next_action` | `text` | nullable; check `next_action IS NULL OR length(next_action) <= 2000` |
| `follow_up_on` | `date` | nullable |
| `created_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_hub_social_content` — 13 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `platform` | `text` | check `platform = ANY (ARRAY['Instagram'::text, 'Facebook'::text, 'TikTok'::text, 'YouTube'::text, 'CUT official platforms'::text])` |
| `content_format` | `text` | check `content_format = ANY (ARRAY['Post'::text, 'Story'::text, 'Reel / Short'::text, 'Video'::text, 'Graphic'::text, 'Carousel'::text])` |
| `scheduled_at` | `timestamp with time zone` | — |
| `content_idea` | `text` | check `char_length(btrim(content_idea)) >= 1 AND char_length(btrim(content_idea)) <= 160` |
| `caption` | `text` | check `char_length(btrim(caption)) >= 1 AND char_length(btrim(caption)) <= 1800` |
| `status` | `text` | default `'planned'::text`; check `status = ANY (ARRAY['planned'::text, 'ready'::text, 'published'::text, 'cancelled'::text])` |
| `created_by` | `uuid` | — |
| `updated_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `media_asset_id` | `uuid` | nullable |
Primary key: `id`.
### `team_hub_media_assets` — 15 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `storage_path` | `text` | unique |
| `title` | `text` | check `char_length(btrim(title)) >= 1 AND char_length(btrim(title)) <= 180` |
| `description` | `text` | default `''::text`; check `char_length(description) <= 1200` |
| `asset_type` | `text` | check `asset_type = ANY (ARRAY['image'::text, 'video'::text, 'document'::text])` |
| `original_filename` | `text` | check `char_length(original_filename) >= 1 AND char_length(original_filename) <= 255` |
| `mime_type` | `text` | check `mime_type = ANY (ARRAY['image/jpeg'::text, 'image/png'::text, 'image/webp'::text, 'image/gif'::text, 'video/mp4'::text, 'video/quicktime'::text, 'video/webm'::text, 'application/pdf'::text])` |
| `size_bytes` | `bigint` | check `size_bytes >= 1 AND size_bytes <= 52428800` |
| `uploaded_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
| `approval_status` | `text` | default `'pending'::text`; check `approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])` |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
| `review_notes` | `text` | default `''::text`; check `char_length(review_notes) <= 1200` |
Primary key: `id`.
### `team_hub_fixture_attendance` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `fixture_id` | `uuid` | — |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `season_member_id` | `uuid` | — |
| `status` | `text` | check `status = ANY (ARRAY['present'::text, 'late'::text, 'absent'::text])` |
| `note` | `text` | nullable; check `note IS NULL OR char_length(note) <= 500` |
| `marked_by` | `uuid` | — |
| `marked_at` | `timestamp with time zone` | default `now()` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `team_hub_player_availability` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `season_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `season_member_id` | `uuid` | — |
| `status` | `text` | check `status = ANY (ARRAY['available'::text, 'modified_training'::text, 'unavailable'::text, 'returning_to_training'::text])` |
| `reason_category` | `text` | default `'undisclosed'::text`; check `reason_category = ANY (ARRAY['injury'::text, 'illness'::text, 'personal'::text, 'other'::text, 'undisclosed'::text])` |
| `effective_from` | `date` | default `CURRENT_DATE` |
| `expected_return_on` | `date` | nullable |
| `staff_note` | `text` | nullable; check `staff_note IS NULL OR char_length(staff_note) <= 1000`; Short operational note only; do not enter diagnoses or treatment details. |
| `created_by` | `uuid` | default `auth.uid()` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `coach_action_tasks` — 18 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `title` | `text` | check `length(btrim(title)) >= 3 AND length(btrim(title)) <= 160` |
| `description` | `text` | nullable; check `description IS NULL OR length(description) <= 3000` |
| `assigned_to` | `uuid` | — |
| `due_date` | `date` | nullable |
| `priority` | `text` | default `'normal'::text`; check `priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text, 'urgent'::text])` |
| `status` | `text` | default `'todo'::text`; check `status = ANY (ARRAY['todo'::text, 'in_progress'::text, 'blocked'::text, 'completed'::text, 'cancelled'::text])` |
| `created_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
| `completed_at` | `timestamp with time zone` | nullable |
| `season_id` | `uuid` | nullable |
| `season_member_id` | `uuid` | nullable |
| `outcome_review` | `text` | nullable; check `outcome_review IS NULL OR length(btrim(outcome_review)) >= 1 AND length(btrim(outcome_review)) <= 3000` |
| `outcome_reviewed_at` | `timestamp with time zone` | nullable |
| `outcome_reviewed_by` | `uuid` | nullable |
Primary key: `id`.
### `coach_action_task_history` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `task_id` | `uuid` | — |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | — |
| `action_type` | `text` | check `action_type = ANY (ARRAY['created'::text, 'assigned'::text, 'status_changed'::text, 'updated'::text])` |
| `previous_values` | `jsonb` | nullable |
| `new_values` | `jsonb` | default `'{}'::jsonb` |
| `changed_by` | `uuid` | nullable |
| `changed_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `report_export_history` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `created_by` | `uuid` | — |
| `report_type` | `text` | check `report_type = ANY (ARRAY['athlete_performance'::text, 'team_sheet'::text, 'squad_announcement'::text, 'team_season_performance'::text, 'player_development'::text, 'competition_report'::text, 'event_report'::text])` |
| `report_title` | `text` | check `char_length(report_title) >= 1 AND char_length(report_title) <= 180` |
| `scope_label` | `text` | nullable; check `scope_label IS NULL OR char_length(scope_label) <= 180` |
| `season_id` | `uuid` | nullable |
| `period_start` | `date` | nullable |
| `period_end` | `date` | nullable |
| `output_format` | `text` | check `output_format = ANY (ARRAY['pdf'::text, 'csv'::text])` |
| `export_action` | `text` | default `'print_dialog_opened'::text`; check `export_action = ANY (ARRAY['print_dialog_opened'::text, 'csv_download_started'::text])` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.

## Content, events and communications

### `articles` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `title` | `text` | — |
| `slug` | `text` | unique |
| `excerpt` | `text` | nullable |
| `body` | `text` | nullable |
| `cover_image_url` | `text` | nullable |
| `author_id` | `uuid` | nullable |
| `sport_id` | `uuid` | nullable |
| `status` | `text` | default `'draft'::text`; check `status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text])` |
| `published_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `article_comments` — 5 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `article_id` | `uuid` | — |
| `user_id` | `uuid` | — |
| `body` | `text` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `events` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `title` | `text` | — |
| `description` | `text` | nullable |
| `venue` | `text` | nullable |
| `starts_at` | `timestamp with time zone` | — |
| `ends_at` | `timestamp with time zone` | nullable |
| `ticketed` | `boolean` | default `false` |
| `published` | `boolean` | default `false` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `sport_id` | `uuid` | nullable |
| `archived_at` | `timestamp with time zone` | nullable |
Primary key: `id`.
### `event_rsvps` — 5 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `event_id` | `uuid` | — |
| `user_id` | `uuid` | — |
| `status` | `text` | default `'going'::text`; check `status = ANY (ARRAY['going'::text, 'interested'::text, 'cancelled'::text])` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `sponsors` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `name` | `text` | — |
| `slug` | `text` | unique |
| `description` | `text` | nullable |
| `logo_url` | `text` | nullable |
| `website_url` | `text` | nullable |
| `sponsorship_tier` | `text` | nullable |
| `display_order` | `integer` | default `0` |
| `is_active` | `boolean` | default `true` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `notifications` — 11 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `user_id` | `uuid` | — |
| `title` | `text` | — |
| `body` | `text` | — |
| `read_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `source_key` | `text` | nullable |
| `category` | `text` | default `'general'::text` |
| `action_url` | `text` | nullable |
| `related_record_type` | `text` | nullable |
| `related_record_id` | `uuid` | nullable |
Primary key: `id`.

## Shop, tickets and payments

### `products` — 10 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `name` | `text` | — |
| `slug` | `text` | unique |
| `description` | `text` | nullable |
| `category` | `text` | nullable |
| `price_cents` | `integer` | check `price_cents >= 0` |
| `image_url` | `text` | nullable |
| `stock_quantity` | `integer` | default `0`; check `stock_quantity >= 0` |
| `is_active` | `boolean` | default `false` |
| `created_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `orders` — 18 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `user_id` | `uuid` | — |
| `order_number` | `text` | unique |
| `status` | `USER-DEFINED` | default `'pending'::order_status` |
| `subtotal_cents` | `integer` | default `0` |
| `total_cents` | `integer` | default `0` |
| `currency` | `text` | default `'ZAR'::text` |
| `payment_reference` | `text` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `order_kind` | `text` | default `'shop'::text`; check `order_kind = ANY (ARRAY['shop'::text, 'event'::text])` |
| `payment_provider` | `text` | nullable |
| `payment_status` | `text` | default `'unpaid'::text`; check `payment_status = ANY (ARRAY['unpaid'::text, 'pending'::text, 'succeeded'::text, 'failed'::text, 'refunded'::text])` |
| `yoco_checkout_id` | `text` | nullable |
| `yoco_payment_id` | `text` | nullable |
| `paid_at` | `timestamp with time zone` | nullable |
| `checkout_expires_at` | `timestamp with time zone` | nullable |
| `checkout_request_id` | `uuid` | nullable |
| `yoco_redirect_url` | `text` | nullable |
Primary key: `id`.
### `order_items` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `order_id` | `uuid` | — |
| `product_id` | `uuid` | nullable |
| `product_name` | `text` | — |
| `quantity` | `integer` | check `quantity > 0` |
| `unit_price_cents` | `integer` | check `unit_price_cents >= 0` |
| `item_type` | `text` | default `'product'::text`; check `item_type = ANY (ARRAY['product'::text, 'event_ticket'::text])` |
| `event_id` | `uuid` | nullable |
| `ticket_type_id` | `uuid` | nullable |
Primary key: `id`.
### `tickets` — 8 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `event_id` | `uuid` | — |
| `user_id` | `uuid` | — |
| `ticket_code_hash` | `text` | unique |
| `redeemed_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `order_id` | `uuid` | nullable |
| `ticket_type_id` | `uuid` | nullable |
Primary key: `id`.
### `event_ticket_types` — 10 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `event_id` | `uuid` | — |
| `name` | `text` | — |
| `description` | `text` | nullable |
| `price_cents` | `integer` | check `price_cents >= 0` |
| `quantity_available` | `integer` | default `0`; check `quantity_available >= 0` |
| `max_per_order` | `integer` | default `6`; check `max_per_order >= 1 AND max_per_order <= 20` |
| `is_active` | `boolean` | default `true` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `yoco_webhook_events` — 4 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `text` | — |
| `event_type` | `text` | — |
| `checkout_id` | `text` | nullable |
| `processed_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.

## Recruitment and trials

### `recruitment_opportunities` — 12 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `sport_id` | `uuid` | — |
| `team_id` | `uuid` | nullable |
| `title` | `text` | check `length(btrim(title)) >= 3 AND length(btrim(title)) <= 140` |
| `description` | `text` | nullable |
| `venue` | `text` | nullable |
| `starts_at` | `timestamp with time zone` | nullable |
| `closes_at` | `timestamp with time zone` | nullable |
| `status` | `text` | default `'draft'::text`; check `status = ANY (ARRAY['draft'::text, 'open'::text, 'closed'::text, 'cancelled'::text])` |
| `created_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `trial_applications` — 13 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `opportunity_id` | `uuid` | — |
| `applicant_user_id` | `uuid` | — |
| `athlete_id` | `uuid` | nullable |
| `full_name` | `text` | check `length(btrim(full_name)) >= 2 AND length(btrim(full_name)) <= 120` |
| `playing_position` | `text` | nullable |
| `experience` | `text` | nullable |
| `motivation` | `text` | nullable; check `motivation IS NULL OR length(motivation) <= 3000` |
| `status` | `text` | default `'submitted'::text`; check `status = ANY (ARRAY['submitted'::text, 'shortlisted'::text, 'selected'::text, 'not_selected'::text])` |
| `reviewed_by` | `uuid` | nullable |
| `reviewed_at` | `timestamp with time zone` | nullable |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `trial_application_reviews` — 4 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `application_id` | `uuid` | — |
| `coach_notes` | `text` | nullable; check `coach_notes IS NULL OR length(coach_notes) <= 4000` |
| `reviewer_id` | `uuid` | nullable |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `application_id`.
### `trial_evaluation_criteria` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `opportunity_id` | `uuid` | — |
| `title` | `text` | check `length(btrim(title)) >= 2 AND length(btrim(title)) <= 120` |
| `description` | `text` | nullable; check `description IS NULL OR length(description) <= 1000` |
| `max_score` | `numeric` | default `10`; check `max_score > 0::numeric AND max_score <= 1000::numeric` |
| `display_order` | `integer` | default `0` |
| `created_by` | `uuid` | — |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.
### `trial_application_scores` — 9 columns; observed rows: 0; RLS: enabled
| Column | PostgreSQL type | Nullability / constraints |
|---|---|---|
| `id` | `uuid` | default `gen_random_uuid()` |
| `application_id` | `uuid` | — |
| `opportunity_id` | `uuid` | — |
| `criterion_id` | `uuid` | — |
| `reviewer_id` | `uuid` | — |
| `score` | `numeric` | check `score >= 0::numeric AND score <= 1000::numeric` |
| `comments` | `text` | nullable; check `comments IS NULL OR length(comments) <= 2000` |
| `created_at` | `timestamp with time zone` | default `now()` |
| `updated_at` | `timestamp with time zone` | default `now()` |
Primary key: `id`.

## Foreign-key relationship index

- `public.athlete_statistics` (`reviewed_by`) → `public.profiles` (`id`)
- `public.athlete_achievements` (`reviewed_by`) → `public.profiles` (`id`)
- `public.athlete_achievements` (`verified_by`) → `public.profiles` (`id`)
- `public.athlete_review_history` (`reviewed_by`) → `public.profiles` (`id`)
- `public.athlete_review_history` (`changed_by`) → `public.profiles` (`id`)
- `public.athlete_messages` (`sender_id`) → `public.profiles` (`id`)
- `public.athlete_messages` (`recipient_id`) → `public.profiles` (`id`)
- `public.athlete_media` (`reviewed_by`) → `public.profiles` (`id`)
- `public.athlete_statistics` (`approved_by`) → `public.profiles` (`id`)
- `public.athlete_statistics` (`recorded_by`) → `public.profiles` (`id`)
- `public.sport_admin_profiles` (`profile_id`) → `public.profiles` (`id`)
- `public.athletes` (`verified_by`) → `public.profiles` (`id`)
- `public.notifications` (`user_id`) → `public.profiles` (`id`)
- `public.tickets` (`user_id`) → `public.profiles` (`id`)
- `public.event_rsvps` (`user_id`) → `public.profiles` (`id`)
- `public.orders` (`user_id`) → `public.profiles` (`id`)
- `public.article_comments` (`user_id`) → `public.profiles` (`id`)
- `public.profiles` (`id`) → `auth.users` (`id`)
- `public.user_roles` (`user_id`) → `public.profiles` (`id`)
- `public.athletes` (`profile_id`) → `public.profiles` (`id`)
- `public.articles` (`author_id`) → `public.profiles` (`id`)
- `public.athlete_media` (`uploaded_by`) → `public.profiles` (`id`)
- `public.athlete_media` (`approved_by`) → `public.profiles` (`id`)
- `public.sport_admin_activity_logs` (`actor_id`) → `public.profiles` (`id`)
- `public.athletes` (`reviewed_by`) → `public.profiles` (`id`)
- `public.fixtures` (`sport_id`) → `public.sports` (`id`)
- `public.team_staff_profiles` (`sport_id`) → `public.sports` (`id`)
- `public.team_hub_player_availability` (`sport_id`) → `public.sports` (`id`)
- `public.team_hub_player_development_notes` (`sport_id`) → `public.sports` (`id`)
- `public.team_hub_seasons` (`sport_id`) → `public.sports` (`id`)
- `public.coach_action_tasks` (`sport_id`) → `public.sports` (`id`)
- `public.player_awards` (`sport_id`) → `public.sports` (`id`)
- `public.player_international_appearances` (`sport_id`) → `public.sports` (`id`)
- `public.player_match_statistics` (`sport_id`) → `public.sports` (`id`)
- `public.athlete_team_memberships` (`sport_id`) → `public.sports` (`id`)
- `public.recruitment_opportunities` (`sport_id`) → `public.sports` (`id`)
- `public.events` (`sport_id`) → `public.sports` (`id`)
- `public.sport_admin_assignments` (`sport_id`) → `public.sports` (`id`)
- `public.athletes` (`sport_id`) → `public.sports` (`id`)
- `public.articles` (`sport_id`) → `public.sports` (`id`)
- `public.teams` (`sport_id`) → `public.sports` (`id`)
- `public.competitions` (`sport_id`) → `public.sports` (`id`)
- `public.fixtures` (`team_id`) → `public.teams` (`id`)
- `public.team_hub_player_development_notes` (`team_id`) → `public.teams` (`id`)
- `public.team_hub_seasons` (`team_id`, `sport_id`) → `public.teams` (`id`, `sport_id`)
- `public.coach_action_tasks` (`team_id`, `sport_id`) → `public.teams` (`id`, `sport_id`)
- `public.coach_action_tasks` (`team_id`) → `public.teams` (`id`)
- `public.teams` (`competition_id`) → `public.competitions` (`id`)
- `public.player_match_statistics` (`team_id`) → `public.teams` (`id`)
- `public.athlete_team_memberships` (`team_id`, `sport_id`) → `public.teams` (`id`, `sport_id`)
- `public.athlete_team_memberships` (`team_id`) → `public.teams` (`id`)
- `public.recruitment_opportunities` (`team_id`, `sport_id`) → `public.teams` (`id`, `sport_id`)
- `public.athlete_competitions` (`team_id`) → `public.teams` (`id`)
- `public.sport_admin_assignments` (`team_id`) → `public.teams` (`id`)
- `public.team_hub_player_availability` (`team_id`) → `public.teams` (`id`)
- `public.athletes` (`team_id`) → `public.teams` (`id`)
- `public.team_staff_profiles` (`team_id`, `sport_id`) → `public.teams` (`id`, `sport_id`)
- `public.athlete_competitions` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_statistics` (`athlete_id`) → `public.athletes` (`id`)
- `public.team_hub_season_members` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_review_history` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_messages` (`athlete_id`) → `public.athletes` (`id`)
- `public.trial_applications` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_achievements` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_media` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_team_memberships` (`athlete_id`) → `public.athletes` (`id`)
- `public.athletes` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.athlete_data_quality_reviews` (`athlete_id`) → `public.athletes` (`id`)
- `public.athlete_data_quality_review_history` (`athlete_id`) → `public.athletes` (`id`)
- `public.competition_squads` (`competition_id`) → `public.competitions` (`id`)
- `public.competition_honours` (`competition_id`) → `public.competitions` (`id`)
- `public.player_awards` (`competition_id`) → `public.competitions` (`id`)
- `public.player_international_appearances` (`competition_id`) → `public.competitions` (`id`)
- `public.player_match_statistics` (`competition_id`) → `public.competitions` (`id`)
- `public.competition_team_statistics` (`competition_id`) → `public.competitions` (`id`)
- `public.competition_player_statistics` (`competition_id`) → `public.competitions` (`id`)
- `public.competition_matches` (`competition_id`) → `public.competitions` (`id`)
- `public.competition_standings` (`competition_id`) → `public.competitions` (`id`)
- `public.athlete_achievements` (`competition_id`) → `public.competitions` (`id`)
- `public.athlete_statistics` (`competition_id`) → `public.competitions` (`id`)
- `public.athlete_competitions` (`competition_id`) → `public.competitions` (`id`)
- `public.fixtures` (`competition_id`) → `public.competitions` (`id`)
- `public.athlete_statistics` (`fixture_id`) → `public.fixtures` (`id`)
- `public.team_hub_fixture_attendance` (`fixture_id`) → `public.fixtures` (`id`)
- `public.fixtures` (`competition_match_id`) → `public.competition_matches` (`id`)
- `public.player_match_statistics` (`fixture_id`) → `public.fixtures` (`id`)
- `public.fixture_result_submissions` (`fixture_id`) → `public.fixtures` (`id`)
- `public.article_comments` (`article_id`) → `public.articles` (`id`)
- `public.order_items` (`product_id`) → `public.products` (`id`)
- `public.tickets` (`order_id`) → `public.orders` (`id`)
- `private.shop_order_status_events` (`order_id`) → `public.orders` (`id`)
- `public.order_items` (`order_id`) → `public.orders` (`id`)
- `public.order_items` (`ticket_type_id`) → `public.event_ticket_types` (`id`)
- `public.order_items` (`event_id`) → `public.events` (`id`)
- `public.event_rsvps` (`event_id`) → `public.events` (`id`)
- `public.tickets` (`event_id`) → `public.events` (`id`)
- `public.event_ticket_types` (`event_id`) → `public.events` (`id`)
- `public.tickets` (`ticket_type_id`) → `public.event_ticket_types` (`id`)
- `public.coach_action_tasks` (`assigned_to`) → `public.sport_admin_profiles` (`profile_id`)
- `public.sport_admin_assignments` (`admin_profile_id`) → `public.sport_admin_profiles` (`profile_id`)
- `public.fixture_result_submissions` (`submitted_by`) → `auth.users` (`id`)
- `public.fixture_result_submissions` (`reviewed_by`) → `auth.users` (`id`)
- `public.athlete_messages` (`parent_message_id`) → `public.athlete_messages` (`id`)
- `public.trial_evaluation_criteria` (`opportunity_id`) → `public.recruitment_opportunities` (`id`)
- `public.trial_applications` (`opportunity_id`) → `public.recruitment_opportunities` (`id`)
- `public.recruitment_opportunities` (`created_by`) → `auth.users` (`id`)
- `public.trial_application_scores` (`application_id`, `opportunity_id`) → `public.trial_applications` (`id`, `opportunity_id`)
- `public.trial_applications` (`applicant_user_id`) → `auth.users` (`id`)
- `public.trial_applications` (`reviewed_by`) → `auth.users` (`id`)
- `public.trial_application_reviews` (`application_id`) → `public.trial_applications` (`id`)
- `public.trial_application_reviews` (`reviewer_id`) → `auth.users` (`id`)
- `public.trial_evaluation_criteria` (`created_by`) → `auth.users` (`id`)
- `public.trial_application_scores` (`criterion_id`, `opportunity_id`) → `public.trial_evaluation_criteria` (`id`, `opportunity_id`)
- `public.trial_application_scores` (`reviewer_id`) → `auth.users` (`id`)
- `public.athlete_team_memberships` (`created_by`) → `auth.users` (`id`)
- `public.player_match_statistics` (`competition_match_id`) → `public.competition_matches` (`id`)
- `public.competition_player_statistics` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.competition_squad_members` (`squad_id`) → `public.competition_squads` (`id`)
- `public.competition_squad_members` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.player_profiles` (`claimed_by`) → `auth.users` (`id`)
- `public.player_profile_claims` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.player_profiles` (`photo_approved_by`) → `auth.users` (`id`)
- `public.player_match_statistics` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.player_international_appearances` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.player_awards` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.team_hub_season_members` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.team_hub_poll_responses` (`player_profile_id`) → `public.player_profiles` (`id`)
- `public.player_profile_claims` (`user_id`) → `auth.users` (`id`)
- `public.player_profile_claims` (`reviewed_by`) → `auth.users` (`id`)
- `public.player_match_statistics` (`approved_by`) → `auth.users` (`id`)
- `public.player_match_statistics` (`recorded_by`) → `auth.users` (`id`)
- `public.player_match_statistics_review_history` (`record_id`) → `public.player_match_statistics` (`id`)
- `public.player_international_appearances` (`recorded_by`) → `auth.users` (`id`)
- `public.player_international_appearances` (`approved_by`) → `auth.users` (`id`)
- `public.player_awards` (`approved_by`) → `auth.users` (`id`)
- `public.player_awards` (`recorded_by`) → `auth.users` (`id`)
- `public.player_match_statistics_review_history` (`reviewer_id`) → `auth.users` (`id`)
- `public.athlete_data_quality_reviews` (`updated_by`) → `auth.users` (`id`)
- `public.athlete_data_quality_reviews` (`created_by`) → `auth.users` (`id`)
- `public.athlete_data_quality_reviews` (`reviewed_by`) → `auth.users` (`id`)
- `public.athlete_data_quality_review_history` (`review_id`) → `public.athlete_data_quality_reviews` (`id`)
- `public.athlete_data_quality_review_history` (`changed_by`) → `auth.users` (`id`)
- `public.coach_action_tasks` (`season_member_id`) → `public.team_hub_season_members` (`id`)
- `public.coach_action_tasks` (`outcome_reviewed_by`) → `auth.users` (`id`)
- `public.coach_action_tasks` (`created_by`) → `auth.users` (`id`)
- `public.coach_action_task_history` (`task_id`) → `public.coach_action_tasks` (`id`)
- `public.coach_action_tasks` (`season_id`) → `public.team_hub_seasons` (`id`)
- `public.team_hub_posts` (`season_id`, `team_id`, `sport_id`) → `public.team_hub_seasons` (`id`, `team_id`, `sport_id`)
- `public.team_hub_season_members` (`season_id`, `team_id`, `sport_id`) → `public.team_hub_seasons` (`id`, `team_id`, `sport_id`)
- `public.team_hub_polls` (`season_id`, `team_id`, `sport_id`) → `public.team_hub_seasons` (`id`, `team_id`, `sport_id`)
- `public.team_hub_poll_responses` (`season_id`, `team_id`, `sport_id`) → `public.team_hub_seasons` (`id`, `team_id`, `sport_id`)
- `public.team_hub_player_development_notes` (`season_id`) → `public.team_hub_seasons` (`id`)
- `public.report_export_history` (`season_id`) → `public.team_hub_seasons` (`id`)
- `public.team_hub_social_content` (`season_id`) → `public.team_hub_seasons` (`id`)
- `public.team_hub_media_assets` (`season_id`) → `public.team_hub_seasons` (`id`)
- `public.team_hub_fixture_attendance` (`season_id`, `team_id`, `sport_id`) → `public.team_hub_seasons` (`id`, `team_id`, `sport_id`)
- `public.team_hub_player_availability` (`season_id`) → `public.team_hub_seasons` (`id`)
- `public.team_hub_player_availability` (`season_id`, `team_id`, `sport_id`) → `public.team_hub_seasons` (`id`, `team_id`, `sport_id`)
- `public.team_hub_practice_attendance` (`season_member_id`) → `public.team_hub_season_members` (`id`)
- `public.team_hub_player_availability` (`season_member_id`) → `public.team_hub_season_members` (`id`)
- `public.team_hub_fixture_attendance` (`season_id`, `season_member_id`) → `public.team_hub_season_members` (`season_id`, `id`)
- `public.team_hub_player_development_notes` (`season_member_id`) → `public.team_hub_season_members` (`id`)
- `public.team_hub_practice_attendance` (`practice_post_id`) → `public.team_hub_posts` (`id`)
- `public.team_hub_polls` (`post_id`) → `public.team_hub_posts` (`id`)
- `public.team_hub_poll_options` (`poll_id`) → `public.team_hub_polls` (`id`)
- `public.team_hub_poll_responses` (`poll_id`) → `public.team_hub_polls` (`id`)
- `public.team_hub_poll_responses` (`poll_id`, `option_id`) → `public.team_hub_poll_options` (`poll_id`, `id`)
- `public.team_hub_practice_attendance` (`marked_by`) → `auth.users` (`id`)
- `public.team_hub_player_development_notes` (`created_by`) → `auth.users` (`id`)
- `public.report_export_history` (`created_by`) → `auth.users` (`id`)
- `public.team_hub_social_content` (`created_by`) → `auth.users` (`id`)
- `public.team_hub_social_content` (`updated_by`) → `auth.users` (`id`)
- `public.team_hub_social_content` (`media_asset_id`) → `public.team_hub_media_assets` (`id`)
- `public.team_hub_media_assets` (`reviewed_by`) → `auth.users` (`id`)
- `public.team_hub_media_assets` (`uploaded_by`) → `auth.users` (`id`)
- `public.team_hub_fixture_attendance` (`marked_by`) → `auth.users` (`id`)
- `public.team_staff_profiles` (`created_by`) → `auth.users` (`id`)
- `public.competition_honours` (`recorded_by`) → `auth.users` (`id`)
- `public.competition_honours` (`approved_by`) → `auth.users` (`id`)
