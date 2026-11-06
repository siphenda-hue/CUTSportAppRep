-- Applied to Supabase project tnkykdfxzwaqzbichxcl on 2026-11-06.
-- Scoped sport operations, result submissions, athlete approval guards and publishing policies.

revoke all privileges on table public.teams, public.competitions, public.fixtures,
  public.articles, public.events, public.athletes, public.athlete_statistics,
  public.athlete_achievements, public.athlete_media from anon;
grant select on table public.teams, public.competitions, public.fixtures,
  public.articles, public.events, public.athletes, public.athlete_statistics,
  public.athlete_achievements, public.athlete_media to anon;
revoke truncate, references, trigger on table public.teams, public.competitions,
  public.fixtures, public.articles, public.events, public.athletes,
  public.athlete_statistics, public.athlete_achievements, public.athlete_media
from anon, authenticated;

alter table public.events add column if not exists sport_id uuid references public.sports(id);

create policy "Assigned sport admins read all teams" on public.teams
for select to authenticated using ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins insert teams" on public.teams
for insert to authenticated with check ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins update teams" on public.teams
for update to authenticated using ((select private.can_manage_sport(sport_id)))
with check ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins delete teams" on public.teams
for delete to authenticated using ((select private.can_manage_sport(sport_id)));

create policy "Assigned sport admins insert competitions" on public.competitions
for insert to authenticated with check (sport_id is not null and (select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins update competitions" on public.competitions
for update to authenticated using (sport_id is not null and (select private.can_manage_sport(sport_id)))
with check (sport_id is not null and (select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins delete competitions" on public.competitions
for delete to authenticated using (sport_id is not null and (select private.can_manage_sport(sport_id)));

create policy "Assigned sport admins insert fixtures" on public.fixtures
for insert to authenticated with check ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins update fixtures" on public.fixtures
for update to authenticated using ((select private.can_manage_sport(sport_id)))
with check ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins delete fixtures" on public.fixtures
for delete to authenticated using ((select private.can_manage_sport(sport_id)));

create or replace function private.validate_fixture_sport_links()
returns trigger language plpgsql security invoker set search_path = ''
as $function$
declare linked_sport_id uuid;
begin
  if new.team_id is not null then
    select t.sport_id into linked_sport_id from public.teams t where t.id = new.team_id;
    if linked_sport_id is null or linked_sport_id <> new.sport_id then
      raise exception 'Fixture team must belong to the fixture sport' using errcode = '23514';
    end if;
  end if;
  if new.competition_id is not null then
    select c.sport_id into linked_sport_id from public.competitions c where c.id = new.competition_id;
    if linked_sport_id is not null and linked_sport_id <> new.sport_id then
      raise exception 'Fixture competition must belong to the fixture sport' using errcode = '23514';
    end if;
  end if;
  return new;
end;
$function$;
create trigger fixtures_validate_sport_links
before insert or update of sport_id, team_id, competition_id on public.fixtures
for each row execute function private.validate_fixture_sport_links();

create table public.fixture_result_submissions (
  id uuid primary key default gen_random_uuid(),
  fixture_id uuid not null references public.fixtures(id) on delete cascade,
  submitted_by uuid not null references auth.users(id) on delete restrict default auth.uid(),
  home_score integer not null check (home_score >= 0),
  away_score integer not null check (away_score >= 0),
  result_summary text,
  review_status text not null default 'pending' check (review_status in ('pending','accepted','rejected')),
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  review_note text,
  created_at timestamptz not null default now()
);
alter table public.fixture_result_submissions enable row level security;
revoke all privileges on table public.fixture_result_submissions from anon;
grant select, insert, update on table public.fixture_result_submissions to authenticated;
revoke truncate, references, trigger on table public.fixture_result_submissions from authenticated;

create policy "Assigned staff read fixture result submissions" on public.fixture_result_submissions
for select to authenticated using (
  exists (select 1 from public.fixtures f where f.id = fixture_id
    and private.can_manage_athlete(f.sport_id, f.team_id))
);
create policy "Assigned coaches submit fixture results" on public.fixture_result_submissions
for insert to authenticated with check (
  submitted_by = (select auth.uid()) and review_status = 'pending'
  and reviewed_by is null and reviewed_at is null
  and exists (select 1 from public.fixtures f where f.id = fixture_id
    and f.team_id is not null and f.status <> 'cancelled'::public.fixture_status
    and private.can_manage_athlete(f.sport_id, f.team_id))
);
create policy "Sport admins review fixture results" on public.fixture_result_submissions
for update to authenticated using (
  exists (select 1 from public.fixtures f where f.id = fixture_id
    and private.can_manage_sport(f.sport_id))
) with check (
  exists (select 1 from public.fixtures f where f.id = fixture_id
    and private.can_manage_sport(f.sport_id))
);

create or replace function private.guard_fixture_result_review()
returns trigger language plpgsql security invoker set search_path = ''
as $function$
declare fixture_sport_id uuid;
begin
  select f.sport_id into fixture_sport_id from public.fixtures f where f.id = new.fixture_id;
  if tg_op = 'INSERT' then
    if new.review_status <> 'pending' or new.reviewed_by is not null or new.reviewed_at is not null then
      raise exception 'Result submissions must start pending' using errcode = '42501';
    end if;
  elsif (new.review_status is distinct from old.review_status
    or new.reviewed_by is distinct from old.reviewed_by
    or new.reviewed_at is distinct from old.reviewed_at
    or new.review_note is distinct from old.review_note)
    and not private.can_manage_sport(fixture_sport_id) then
    raise exception 'Only an assigned sport administrator can review a result' using errcode = '42501';
  end if;
  if tg_op = 'UPDATE' and new.submitted_by is distinct from old.submitted_by then
    raise exception 'Submission owner cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$function$;
create trigger fixture_result_submissions_guard_review
before insert or update on public.fixture_result_submissions
for each row execute function private.guard_fixture_result_review();

create or replace function private.guard_athlete_approval_fields()
returns trigger language plpgsql security invoker set search_path = ''
as $function$
declare
  row_data jsonb := to_jsonb(new);
  old_data jsonb;
  target_sport_id uuid;
  target_team_id uuid;
  approver boolean;
  protected_changed boolean := false;
begin
  if tg_op = 'UPDATE' then old_data := to_jsonb(old); end if;
  if tg_table_name = 'athletes' then
    target_sport_id := nullif(row_data->>'sport_id','')::uuid;
    target_team_id := nullif(row_data->>'team_id','')::uuid;
    if tg_op = 'INSERT' then
      protected_changed := coalesce(row_data->>'approval_status','pending') <> 'pending'
        or row_data->>'verified_by' is not null or row_data->>'verified_at' is not null;
    else
      protected_changed := row_data->>'approval_status' is distinct from old_data->>'approval_status'
        or row_data->>'verified_by' is distinct from old_data->>'verified_by'
        or row_data->>'verified_at' is distinct from old_data->>'verified_at'
;
    end if;
  else
    select a.sport_id, a.team_id into target_sport_id, target_team_id
    from public.athletes a where a.id = nullif(row_data->>'athlete_id','')::uuid;
    if tg_table_name = 'athlete_statistics' then
      if tg_op = 'INSERT' then
        protected_changed := coalesce(row_data->>'approval_status','pending') <> 'pending'
          or row_data->>'approved_by' is not null or row_data->>'approved_at' is not null;
      else
        protected_changed := row_data->>'approval_status' is distinct from old_data->>'approval_status'
          or row_data->>'approved_by' is distinct from old_data->>'approved_by'
          or row_data->>'approved_at' is distinct from old_data->>'approved_at';
      end if;
    elsif tg_table_name = 'athlete_achievements' then
      if tg_op = 'INSERT' then
        protected_changed := coalesce(row_data->>'is_verified','false') <> 'false'
          or row_data->>'verified_by' is not null or row_data->>'verified_at' is not null;
      else
        protected_changed := row_data->>'is_verified' is distinct from old_data->>'is_verified'
          or row_data->>'verified_by' is distinct from old_data->>'verified_by'
          or row_data->>'verified_at' is distinct from old_data->>'verified_at';
      end if;
    elsif tg_table_name = 'athlete_media' then
      if tg_op = 'INSERT' then
        protected_changed := row_data->>'approved_by' is not null or row_data->>'approved_at' is not null;
      else
        protected_changed := row_data->>'approved_by' is distinct from old_data->>'approved_by'
          or row_data->>'approved_at' is distinct from old_data->>'approved_at'
          or (row_data->>'visibility' = 'public'
              and old_data->>'visibility' is distinct from 'public');
      end if;
    end if;
  end if;
  if target_sport_id is null and target_team_id is not null then
    select t.sport_id into target_sport_id from public.teams t where t.id = target_team_id;
  end if;
  approver := coalesce(private.can_manage_sport(target_sport_id), false);
  if protected_changed and not approver then
    raise exception 'Only an assigned sport administrator can approve or publish athlete records'
      using errcode = '42501';
  end if;
  return new;
end;
$function$;
create trigger athletes_guard_approval_fields before insert or update on public.athletes
for each row execute function private.guard_athlete_approval_fields();
create trigger athlete_statistics_guard_approval_fields before insert or update on public.athlete_statistics
for each row execute function private.guard_athlete_approval_fields();
create trigger athlete_achievements_guard_approval_fields before insert or update on public.athlete_achievements
for each row execute function private.guard_athlete_approval_fields();
create trigger athlete_media_guard_approval_fields before insert or update on public.athlete_media
for each row execute function private.guard_athlete_approval_fields();

create policy "Assigned sport admins read all articles" on public.articles
for select to authenticated using ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins insert articles" on public.articles
for insert to authenticated with check ((select private.can_manage_sport(sport_id))
  and (author_id is null or author_id = (select auth.uid())));
create policy "Assigned sport admins update articles" on public.articles
for update to authenticated using ((select private.can_manage_sport(sport_id)))
with check ((select private.can_manage_sport(sport_id))
  and (author_id is null or author_id = (select auth.uid())));
create policy "Assigned sport admins delete articles" on public.articles
for delete to authenticated using ((select private.can_manage_sport(sport_id)));

create policy "Assigned sport admins read all events" on public.events
for select to authenticated using ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins insert events" on public.events
for insert to authenticated with check ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins update events" on public.events
for update to authenticated using ((select private.can_manage_sport(sport_id)))
with check ((select private.can_manage_sport(sport_id)));
create policy "Assigned sport admins delete events" on public.events
for delete to authenticated using ((select private.can_manage_sport(sport_id)));
