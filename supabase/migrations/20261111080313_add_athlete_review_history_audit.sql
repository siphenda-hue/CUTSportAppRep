create table public.athlete_review_history (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  record_type text not null check (record_type = any (array['athlete','statistics','achievement','media'])),
  record_id uuid not null,
  from_status text,
  to_status text not null,
  previous_note text,
  review_note text,
  reviewed_by uuid references public.profiles(id) on delete set null,
  reviewed_at timestamptz,
  changed_by uuid references public.profiles(id) on delete set null,
  changed_at timestamptz not null default now()
);
create index athlete_review_history_athlete_changed_idx on public.athlete_review_history (athlete_id, changed_at desc);
create index athlete_review_history_record_idx on public.athlete_review_history (record_type, record_id, changed_at desc);
alter table public.athlete_review_history enable row level security;
grant select on public.athlete_review_history to authenticated;
create policy "Athletes and assigned staff read review history"
on public.athlete_review_history for select to authenticated
using (exists (
  select 1 from public.athletes a
  where a.id = athlete_review_history.athlete_id
    and (a.profile_id = (select auth.uid()) or private.can_manage_athlete(a.sport_id, a.team_id))
));
create or replace function private.log_athlete_review_history()
returns trigger language plpgsql security definer set search_path = ''
as $function$
declare
  v_old_status text; v_new_status text; v_old_note text; v_new_note text;
  v_reviewed_by uuid; v_reviewed_at timestamptz; v_athlete_id uuid; v_record_type text;
begin
  if tg_table_name = 'athletes' then
    v_record_type := 'athlete'; v_athlete_id := new.id;
    v_old_status := old.approval_status; v_new_status := new.approval_status;
    v_old_note := old.review_note; v_new_note := new.review_note;
    v_reviewed_by := new.reviewed_by; v_reviewed_at := new.reviewed_at;
  elsif tg_table_name = 'athlete_statistics' then
    v_record_type := 'statistics'; v_athlete_id := new.athlete_id;
    v_old_status := old.approval_status; v_new_status := new.approval_status;
    v_old_note := old.review_note; v_new_note := new.review_note;
    v_reviewed_by := new.reviewed_by; v_reviewed_at := new.reviewed_at;
  elsif tg_table_name = 'athlete_achievements' then
    v_record_type := 'achievement'; v_athlete_id := new.athlete_id;
    v_old_status := old.review_status; v_new_status := new.review_status;
    v_old_note := old.review_note; v_new_note := new.review_note;
    v_reviewed_by := new.reviewed_by; v_reviewed_at := new.reviewed_at;
  elsif tg_table_name = 'athlete_media' then
    v_record_type := 'media'; v_athlete_id := new.athlete_id;
    v_old_status := old.review_status; v_new_status := new.review_status;
    v_old_note := old.review_note; v_new_note := new.review_note;
    v_reviewed_by := new.reviewed_by; v_reviewed_at := new.reviewed_at;
  else
    return new;
  end if;
  if v_old_status is distinct from v_new_status
     or v_old_note is distinct from v_new_note
     or old.reviewed_by is distinct from new.reviewed_by
     or old.reviewed_at is distinct from new.reviewed_at then
    insert into public.athlete_review_history (
      athlete_id, record_type, record_id, from_status, to_status,
      previous_note, review_note, reviewed_by, reviewed_at, changed_by
    ) values (
      v_athlete_id, v_record_type, new.id, v_old_status, v_new_status,
      v_old_note, v_new_note, v_reviewed_by, v_reviewed_at, auth.uid()
    );
  end if;
  return new;
end;
$function$;
revoke all on function private.log_athlete_review_history() from public, anon, authenticated;
drop trigger if exists athlete_review_history_log on public.athletes;
create trigger athlete_review_history_log after update on public.athletes for each row execute function private.log_athlete_review_history();
drop trigger if exists athlete_statistics_review_history_log on public.athlete_statistics;
create trigger athlete_statistics_review_history_log after update on public.athlete_statistics for each row execute function private.log_athlete_review_history();
drop trigger if exists athlete_achievements_review_history_log on public.athlete_achievements;
create trigger athlete_achievements_review_history_log after update on public.athlete_achievements for each row execute function private.log_athlete_review_history();
drop trigger if exists athlete_media_review_history_log on public.athlete_media;
create trigger athlete_media_review_history_log after update on public.athlete_media for each row execute function private.log_athlete_review_history();
