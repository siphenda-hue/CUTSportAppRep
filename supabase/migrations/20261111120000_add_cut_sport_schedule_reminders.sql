create or replace function private.enqueue_cut_sport_schedule_reminders()
returns integer
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
declare
  inserted_count integer := 0;
  n integer := 0;
begin
  with due as (
    select f.id, f.sport_id, f.team_id, f.opponent, f.venue, f.starts_at,
           case when f.starts_at <= now() + interval '1 hour' then '1h' else '24h' end as reminder_window
    from public.fixtures f
    where f.status = 'scheduled'
      and (
        (f.starts_at > now() + interval '24 hours' - interval '15 minutes' and f.starts_at <= now() + interval '24 hours')
        or
        (f.starts_at > now() + interval '1 hour' - interval '15 minutes' and f.starts_at <= now() + interval '1 hour')
      )
  ),
  recipients as (
    select d.*, a.admin_profile_id as user_id
    from due d
    join public.sport_admin_assignments a
      on a.sport_id = d.sport_id
     and (a.team_id is null or a.team_id = d.team_id)
     and a.is_active = true
     and (a.starts_on is null or a.starts_on <= (now() at time zone 'Africa/Johannesburg')::date)
     and (a.ends_on is null or a.ends_on >= (now() at time zone 'Africa/Johannesburg')::date)
    where d.team_id is not null or a.team_id is null
    union
    select d.*, ath.profile_id as user_id
    from due d
    join public.athlete_team_memberships m
      on m.team_id = d.team_id and m.sport_id = d.sport_id and m.is_active = true
    join public.athletes ath
      on ath.id = m.athlete_id and ath.profile_id is not null and ath.approval_status = 'approved'
    where d.team_id is not null
  )
  insert into public.notifications
    (user_id, title, body, category, action_url, related_record_type, related_record_id, source_key)
  select r.user_id,
         case when r.reminder_window = '1h' then 'Fixture in 1 hour' else 'Fixture tomorrow' end,
         coalesce((select t.name from public.teams t where t.id = r.team_id), 'CUT Sport')
           || ' vs ' || r.opponent || ' · '
           || to_char(r.starts_at at time zone 'Africa/Johannesburg', 'Dy, DD Mon HH24:MI')
           || case when r.venue is not null then ' · ' || r.venue else '' end,
         'fixture_reminder', '/calendar', 'fixture', r.id,
         'fixture-reminder:' || r.id::text || ':' || r.reminder_window || ':' || r.user_id::text
  from recipients r
  where r.user_id is not null
  on conflict (source_key) where source_key is not null do nothing;
  get diagnostics n = row_count;
  inserted_count := inserted_count + n;

  with due as (
    select e.id, e.sport_id, e.title, e.venue, e.starts_at,
           case when e.starts_at <= now() + interval '1 hour' then '1h' else '24h' end as reminder_window
    from public.events e
    where e.published = true and e.archived_at is null and e.sport_id is not null
      and (
        (e.starts_at > now() + interval '24 hours' - interval '15 minutes' and e.starts_at <= now() + interval '24 hours')
        or
        (e.starts_at > now() + interval '1 hour' - interval '15 minutes' and e.starts_at <= now() + interval '1 hour')
      )
  )
  insert into public.notifications
    (user_id, title, body, category, action_url, related_record_type, related_record_id, source_key)
  select distinct a.admin_profile_id,
         case when d.reminder_window = '1h' then 'Event in 1 hour' else 'Event tomorrow' end,
         d.title || ' · '
           || to_char(d.starts_at at time zone 'Africa/Johannesburg', 'Dy, DD Mon HH24:MI')
           || case when d.venue is not null then ' · ' || d.venue else '' end,
         'event_reminder', '/calendar', 'event', d.id,
         'event-reminder:' || d.id::text || ':' || d.reminder_window || ':' || a.admin_profile_id::text
  from due d
  join public.sport_admin_assignments a
    on a.sport_id = d.sport_id and a.is_active = true
   and (a.starts_on is null or a.starts_on <= (now() at time zone 'Africa/Johannesburg')::date)
   and (a.ends_on is null or a.ends_on >= (now() at time zone 'Africa/Johannesburg')::date)
  on conflict (source_key) where source_key is not null do nothing;
  get diagnostics n = row_count;
  inserted_count := inserted_count + n;
  return inserted_count;
end;
$$;

revoke all on function private.enqueue_cut_sport_schedule_reminders() from public, anon, authenticated;

do $$
begin
  if not exists (select 1 from cron.job where jobname = 'cut-sport-schedule-reminders') then
    perform cron.schedule('cut-sport-schedule-reminders', '*/15 * * * *',
      'select private.enqueue_cut_sport_schedule_reminders();');
  end if;
end;
$$;
