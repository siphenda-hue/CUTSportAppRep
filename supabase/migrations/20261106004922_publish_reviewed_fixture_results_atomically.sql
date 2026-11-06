-- Publish a reviewed score and accept its submission in one transaction.
create or replace function public.publish_fixture_result_submission(
  p_submission_id uuid,
  p_review_note text default null
)
returns void
language plpgsql
security invoker
set search_path = ''
as $function$
declare
  v_fixture_id uuid;
  v_sport_id uuid;
  v_home_score integer;
  v_away_score integer;
  v_result_summary text;
begin
  if (select auth.uid()) is null then
    raise exception 'Authentication is required' using errcode = '42501';
  end if;

  select s.fixture_id, s.home_score, s.away_score, s.result_summary
    into v_fixture_id, v_home_score, v_away_score, v_result_summary
  from public.fixture_result_submissions s
  where s.id = p_submission_id and s.review_status = 'pending'
  for update;

  if v_fixture_id is null then
    raise exception 'Pending result submission was not found' using errcode = 'P0002';
  end if;

  select f.sport_id into v_sport_id
  from public.fixtures f where f.id = v_fixture_id;

  if not private.can_manage_sport(v_sport_id) then
    raise exception 'Only an assigned sport administrator can publish official results'
      using errcode = '42501';
  end if;

  update public.fixtures
  set home_score = v_home_score,
      away_score = v_away_score,
      result_summary = v_result_summary,
      status = 'completed'::public.fixture_status
  where id = v_fixture_id;

  update public.fixture_result_submissions
  set review_status = 'accepted',
      reviewed_by = (select auth.uid()),
      reviewed_at = now(),
      review_note = p_review_note
  where id = p_submission_id;
end;
$function$;

revoke all on function public.publish_fixture_result_submission(uuid, text) from public, anon;
grant execute on function public.publish_fixture_result_submission(uuid, text) to authenticated;
