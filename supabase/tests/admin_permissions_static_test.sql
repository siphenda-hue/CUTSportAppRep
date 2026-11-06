-- Static security regression checks for the admin permission rollout.
-- Run with psql against a test project after applying the migrations.
-- Authenticated role/sport-assignment behavior tests require dedicated fixture users.

do $$
begin
  if not (select c.relrowsecurity from pg_class c where c.oid='public.teams'::regclass) then
    raise exception 'RLS is not enabled on teams';
  end if;
  if not (select c.relrowsecurity from pg_class c where c.oid='public.fixture_result_submissions'::regclass) then
    raise exception 'RLS is not enabled on fixture_result_submissions';
  end if;
  if has_table_privilege('anon','public.teams','insert') then
    raise exception 'anon unexpectedly has INSERT on teams';
  end if;
  if has_table_privilege('anon','public.articles','update') then
    raise exception 'anon unexpectedly has UPDATE on articles';
  end if;
  if has_table_privilege('authenticated','public.fixtures','truncate') then
    raise exception 'authenticated unexpectedly has TRUNCATE on fixtures';
  end if;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='fixtures' and policyname='Assigned sport admins update fixtures') then
    raise exception 'Scoped fixture update policy is missing';
  end if;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='fixture_result_submissions' and policyname='Assigned coaches submit fixture results') then
    raise exception 'Fixture result submission policy is missing';
  end if;
  if not exists (select 1 from pg_trigger where tgname='athletes_guard_approval_fields'
    and not tgisinternal) then
    raise exception 'Athlete approval guard trigger is missing';
  end if;
  if not exists (select 1 from pg_trigger where tgname='fixtures_validate_sport_links'
    and not tgisinternal) then
    raise exception 'Fixture sport-link validation trigger is missing';
  end if;
  if not has_function_privilege('authenticated','public.publish_fixture_result_submission(uuid,text)','execute') then
    raise exception 'Authenticated role cannot execute the reviewed result publisher';
  end if;
  if has_function_privilege('anon','public.publish_fixture_result_submission(uuid,text)','execute') then
    raise exception 'Anonymous role can execute the reviewed result publisher';
  end if;
end;
$$;
