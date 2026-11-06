-- Index new foreign keys and tighten approval/publish guards.
create index if not exists fixture_result_submissions_fixture_id_idx
  on public.fixture_result_submissions(fixture_id);
create index if not exists fixture_result_submissions_submitted_by_idx
  on public.fixture_result_submissions(submitted_by);
create index if not exists events_sport_id_idx on public.events(sport_id);
