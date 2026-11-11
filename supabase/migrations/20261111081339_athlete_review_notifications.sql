alter table public.notifications
  add column if not exists category text not null default 'general',
  add column if not exists action_url text,
  add column if not exists related_record_type text,
  add column if not exists related_record_id uuid;

alter table public.notifications enable row level security;

drop policy if exists "Users read own notifications" on public.notifications;
create policy "Users read own notifications"
on public.notifications for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users update own notifications" on public.notifications;
create policy "Users update own notifications"
on public.notifications for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.notifications from public, anon, authenticated;
grant select on table public.notifications to authenticated;
grant update (read_at) on table public.notifications to authenticated;
grant all on table public.notifications to service_role;

create or replace function private.notify_athlete_review_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_old jsonb := pg_catalog.to_jsonb(old);
  v_new jsonb := pg_catalog.to_jsonb(new);
  v_status_column text;
  v_old_status text;
  v_new_status text;
  v_athlete_id uuid;
  v_owner_id uuid;
  v_sport_id uuid;
  v_athlete_name text;
  v_note text;
  v_record_type text;
  v_source text;
  v_title text;
  v_body text;
begin
  v_status_column := case
    when tg_table_name = 'athletes' then 'approval_status'
    when tg_table_name = 'athlete_statistics' then 'approval_status'
    else 'review_status'
  end;
  v_old_status := v_old ->> v_status_column;
  v_new_status := v_new ->> v_status_column;

  if v_old_status is not distinct from v_new_status then
    return new;
  end if;

  v_record_type := case tg_table_name
    when 'athletes' then 'athlete'
    when 'athlete_statistics' then 'statistics'
    when 'athlete_achievements' then 'achievement'
    when 'athlete_media' then 'media'
    else 'record'
  end;

  v_athlete_id := case when tg_table_name = 'athletes'
    then (v_new ->> 'id')::uuid
    else (v_new ->> 'athlete_id')::uuid
  end;

  select a.profile_id, a.sport_id,
         coalesce(nullif(a.preferred_name, ''), nullif(a.full_name, ''), 'Athlete')
    into v_owner_id, v_sport_id, v_athlete_name
  from public.athletes a
  where a.id = v_athlete_id;

  if v_old_status = 'pending' and v_new_status in ('approved', 'rejected') then
    if v_owner_id is null then
      return new;
    end if;
    v_note := nullif(pg_catalog.btrim(coalesce(v_new ->> 'review_note', '')), '');
    v_title := case when v_new_status = 'approved'
      then 'Your CUT Sport submission was approved'
      else 'Your CUT Sport submission needs changes'
    end;
    v_body := case
      when v_new_status = 'approved'
        then 'Your ' || v_record_type || ' submission has been approved.'
      else 'Your ' || v_record_type || ' submission was returned for correction.'
           || case when v_note is not null then ' Reviewer feedback: ' || v_note else ' Please open your profile to review the feedback and resubmit.' end
    end;
    v_source := 'athlete-review:' || v_record_type || ':' || (v_new ->> 'id')
      || ':' || v_new_status || ':' || pg_catalog.txid_current()::text;

    insert into public.notifications
      (user_id, title, body, source_key, category, action_url, related_record_type, related_record_id)
    values
      (v_owner_id, v_title, v_body, v_source, 'athlete_review', '/profile', v_record_type, (v_new ->> 'id')::uuid)
    on conflict (source_key) where source_key is not null do nothing;

  elsif v_old_status = 'rejected' and v_new_status = 'pending' then
    v_source := 'athlete-resubmission:' || v_record_type || ':' || (v_new ->> 'id')
      || ':' || pg_catalog.txid_current()::text;
    v_title := 'Athlete correction resubmitted';
    v_body := v_athlete_name || ' resubmitted a ' || v_record_type
      || ' record for review. Open the approvals queue to review the correction.';

    insert into public.notifications
      (user_id, title, body, source_key, category, action_url, related_record_type, related_record_id)
    select recipients.user_id, v_title, v_body,
      v_source || ':' || recipients.user_id::text,
      'athlete_review', '/admin/approvals', v_record_type, (v_new ->> 'id')::uuid
    from (
      select distinct saa.admin_profile_id as user_id
      from public.sport_admin_assignments saa
      where saa.sport_id = v_sport_id
        and saa.is_active = true
        and (saa.starts_on is null or saa.starts_on <= current_date)
        and (saa.ends_on is null or saa.ends_on >= current_date)
      union
      select ur.user_id
      from public.user_roles ur
      where ur.role::text = 'super_admin'
    ) recipients
    where recipients.user_id is not null
      and recipients.user_id is distinct from v_owner_id
    on conflict (source_key) where source_key is not null do nothing;
  end if;

  return new;
end;
$function$;

revoke all on function private.notify_athlete_review_change() from public, anon, authenticated;

drop trigger if exists athletes_notify_review_change on public.athletes;
create trigger athletes_notify_review_change
after update of approval_status on public.athletes
for each row execute function private.notify_athlete_review_change();

drop trigger if exists athlete_statistics_notify_review_change on public.athlete_statistics;
create trigger athlete_statistics_notify_review_change
after update of approval_status on public.athlete_statistics
for each row execute function private.notify_athlete_review_change();

drop trigger if exists athlete_achievements_notify_review_change on public.athlete_achievements;
create trigger athlete_achievements_notify_review_change
after update of review_status on public.athlete_achievements
for each row execute function private.notify_athlete_review_change();

drop trigger if exists athlete_media_notify_review_change on public.athlete_media;
create trigger athlete_media_notify_review_change
after update of review_status on public.athlete_media
for each row execute function private.notify_athlete_review_change();

create index if not exists notifications_user_created_idx
on public.notifications (user_id, created_at desc);
