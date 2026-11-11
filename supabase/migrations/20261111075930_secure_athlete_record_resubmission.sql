CREATE OR REPLACE FUNCTION private.guard_athlete_approval_fields()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare
  row_data jsonb := to_jsonb(new);
  old_data jsonb;
  target_sport_id uuid;
  target_team_id uuid;
  approver boolean;
  protected_changed boolean := false;
  resubmission_allowed boolean := false;
  request_user uuid := auth.uid();
begin
  if tg_op = 'UPDATE' then old_data := to_jsonb(old); end if;

  if tg_table_name = 'athletes' then
    target_sport_id := nullif(row_data->>'sport_id','')::uuid;
    target_team_id := nullif(row_data->>'team_id','')::uuid;
    if tg_op = 'INSERT' then
      protected_changed :=
        coalesce(row_data->>'approval_status','pending') <> 'pending'
        or row_data->>'verified_by' is not null
        or row_data->>'verified_at' is not null
        or row_data->>'reviewed_by' is not null
        or row_data->>'reviewed_at' is not null
        or row_data->>'review_note' is not null;
    else
      protected_changed :=
        row_data->>'approval_status' is distinct from old_data->>'approval_status'
        or row_data->>'verified_by' is distinct from old_data->>'verified_by'
        or row_data->>'verified_at' is distinct from old_data->>'verified_at'
        or row_data->>'reviewed_by' is distinct from old_data->>'reviewed_by'
        or row_data->>'reviewed_at' is distinct from old_data->>'reviewed_at'
        or row_data->>'review_note' is distinct from old_data->>'review_note'
        or (row_data->>'profile_visibility' = 'public'
            and old_data->>'profile_visibility' is distinct from 'public');

      resubmission_allowed :=
        pg_catalog.current_setting('app.athlete_resubmission_user', true) = request_user::text
        and request_user is not null
        and old.profile_id = request_user
        and old.approval_status = 'rejected'
        and new.approval_status = 'pending'
        and new.verified_by is null
        and new.verified_at is null
        and new.reviewed_by is null
        and new.reviewed_at is null
        and new.review_note is null;
    end if;
  else
    select a.sport_id, a.team_id into target_sport_id, target_team_id
    from public.athletes a
    where a.id = nullif(row_data->>'athlete_id','')::uuid;

    if tg_table_name = 'athlete_statistics' then
      if tg_op = 'INSERT' then
        protected_changed := coalesce(row_data->>'approval_status','pending') <> 'pending'
          or row_data->>'approved_by' is not null or row_data->>'approved_at' is not null
          or row_data->>'reviewed_by' is not null or row_data->>'reviewed_at' is not null
          or row_data->>'review_note' is not null;
      else
        protected_changed := row_data->>'approval_status' is distinct from old_data->>'approval_status'
          or row_data->>'approved_by' is distinct from old_data->>'approved_by'
          or row_data->>'approved_at' is distinct from old_data->>'approved_at'
          or row_data->>'reviewed_by' is distinct from old_data->>'reviewed_by'
          or row_data->>'reviewed_at' is distinct from old_data->>'reviewed_at'
          or row_data->>'review_note' is distinct from old_data->>'review_note';

        select exists (
          select 1 from public.athletes a
          where a.id = new.athlete_id and a.profile_id = request_user
        ) into resubmission_allowed;
        resubmission_allowed :=
          resubmission_allowed
          and pg_catalog.current_setting('app.athlete_resubmission_user', true) = request_user::text
          and request_user is not null
          and old.approval_status = 'rejected'
          and new.approval_status = 'pending'
          and new.approved_by is null and new.approved_at is null
          and new.reviewed_by is null and new.reviewed_at is null and new.review_note is null;
      end if;
    elsif tg_table_name = 'athlete_achievements' then
      if tg_op = 'INSERT' then
        protected_changed := coalesce(row_data->>'is_verified','false') <> 'false'
          or row_data->>'verified_by' is not null or row_data->>'verified_at' is not null
          or coalesce(row_data->>'review_status','pending') <> 'pending'
          or row_data->>'reviewed_by' is not null or row_data->>'reviewed_at' is not null
          or row_data->>'review_note' is not null;
      else
        protected_changed := row_data->>'is_verified' is distinct from old_data->>'is_verified'
          or row_data->>'verified_by' is distinct from old_data->>'verified_by'
          or row_data->>'verified_at' is distinct from old_data->>'verified_at'
          or row_data->>'review_status' is distinct from old_data->>'review_status'
          or row_data->>'reviewed_by' is distinct from old_data->>'reviewed_by'
          or row_data->>'reviewed_at' is distinct from old_data->>'reviewed_at'
          or row_data->>'review_note' is distinct from old_data->>'review_note';

        select exists (
          select 1 from public.athletes a
          where a.id = new.athlete_id and a.profile_id = request_user
        ) into resubmission_allowed;
        resubmission_allowed :=
          resubmission_allowed
          and pg_catalog.current_setting('app.athlete_resubmission_user', true) = request_user::text
          and request_user is not null
          and old.review_status = 'rejected'
          and new.review_status = 'pending'
          and new.is_verified = false and new.verified_by is null and new.verified_at is null
          and new.reviewed_by is null and new.reviewed_at is null and new.review_note is null;
      end if;
    elsif tg_table_name = 'athlete_media' then
      if tg_op = 'INSERT' then
        protected_changed := row_data->>'approved_by' is not null or row_data->>'approved_at' is not null
          or coalesce(row_data->>'review_status','pending') <> 'pending'
          or row_data->>'reviewed_by' is not null or row_data->>'reviewed_at' is not null
          or row_data->>'review_note' is not null;
      else
        protected_changed := row_data->>'approved_by' is distinct from old_data->>'approved_by'
          or row_data->>'approved_at' is distinct from old_data->>'approved_at'
          or row_data->>'review_status' is distinct from old_data->>'review_status'
          or row_data->>'reviewed_by' is distinct from old_data->>'reviewed_by'
          or row_data->>'reviewed_at' is distinct from old_data->>'reviewed_at'
          or row_data->>'review_note' is distinct from old_data->>'review_note'
          or (row_data->>'visibility' = 'public'
              and old_data->>'visibility' is distinct from 'public');

        select exists (
          select 1 from public.athletes a
          where a.id = new.athlete_id and a.profile_id = request_user
        ) into resubmission_allowed;
        resubmission_allowed :=
          resubmission_allowed
          and pg_catalog.current_setting('app.athlete_resubmission_user', true) = request_user::text
          and request_user is not null
          and old.review_status = 'rejected'
          and new.review_status = 'pending'
          and new.approved_by is null and new.approved_at is null
          and new.reviewed_by is null and new.reviewed_at is null and new.review_note is null
          and new.visibility = 'private';
      end if;
    end if;
  end if;

  if target_sport_id is null and target_team_id is not null then
    select t.sport_id into target_sport_id from public.teams t where t.id = target_team_id;
  end if;

  approver := coalesce(private.can_manage_sport(target_sport_id), false);
  if protected_changed and not approver and not resubmission_allowed then
    raise exception 'Only an assigned sport administrator can approve or publish athlete records'
      using errcode = '42501';
  end if;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.resubmit_athlete_record(p_record_type text, p_record_id uuid, p_changes jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user uuid := auth.uid();
  v_athlete public.athletes%rowtype;
  v_stats public.athlete_statistics%rowtype;
  v_achievement public.athlete_achievements%rowtype;
  v_media public.athlete_media%rowtype;
  v_new_athlete public.athletes%rowtype;
  v_new_stats public.athlete_statistics%rowtype;
  v_new_achievement public.athlete_achievements%rowtype;
  v_new_media public.athlete_media%rowtype;
begin
  if v_user is null then
    raise exception 'You must be signed in to resubmit an athlete record' using errcode = '42501';
  end if;
  if p_record_id is null or p_changes is null or pg_catalog.jsonb_typeof(p_changes) <> 'object' then
    raise exception 'A record ID and an object of corrected fields are required' using errcode = '22023';
  end if;

  if p_record_type = 'athlete' then
    select * into v_athlete
    from public.athletes
    where id = p_record_id and profile_id = v_user and approval_status = 'rejected'
    for update;
    if not found then raise exception 'Rejected athlete profile not found for this account' using errcode = '42501'; end if;
    if (p_changes - array['full_name','preferred_name','position','gender','nationality','hometown','province','faculty','qualification','year_of_study','student_status','years_representing_cut','previous_clubs','squad_number','bio','photo_url']) <> '{}'::jsonb then
      raise exception 'One or more athlete profile fields cannot be changed here' using errcode = '22023';
    end if;
    select pg_catalog.jsonb_populate_record(v_athlete, p_changes) into v_new_athlete;
    if pg_catalog.btrim(coalesce(v_new_athlete.full_name,'')) = '' then raise exception 'Full name is required' using errcode = '22023'; end if;
    perform pg_catalog.set_config('app.athlete_resubmission_user', v_user::text, true);
    update public.athletes set
      full_name=v_new_athlete.full_name, preferred_name=v_new_athlete.preferred_name,
      position=v_new_athlete.position, gender=v_new_athlete.gender, nationality=v_new_athlete.nationality,
      hometown=v_new_athlete.hometown, province=v_new_athlete.province, faculty=v_new_athlete.faculty,
      qualification=v_new_athlete.qualification, year_of_study=v_new_athlete.year_of_study,
      student_status=v_new_athlete.student_status, years_representing_cut=v_new_athlete.years_representing_cut,
      previous_clubs=v_new_athlete.previous_clubs, squad_number=v_new_athlete.squad_number,
      bio=v_new_athlete.bio, photo_url=v_new_athlete.photo_url,
      approval_status='pending', verified_by=null, verified_at=null,
      review_note=null, reviewed_by=null, reviewed_at=null, updated_at=pg_catalog.now()
    where id=p_record_id;
  elsif p_record_type = 'statistics' then
    select s.* into v_stats
    from public.athlete_statistics s
    join public.athletes a on a.id=s.athlete_id
    where s.id=p_record_id and a.profile_id=v_user and s.approval_status='rejected'
    for update of s;
    if not found then raise exception 'Rejected statistics record not found for this account' using errcode = '42501'; end if;
    if (p_changes - array['competition_id','fixture_id','season','period_label','metrics']) <> '{}'::jsonb then
      raise exception 'One or more statistics fields cannot be changed here' using errcode = '22023';
    end if;
    select pg_catalog.jsonb_populate_record(v_stats, p_changes) into v_new_stats;
    if pg_catalog.jsonb_typeof(v_new_stats.metrics) <> 'object' then raise exception 'Statistics metrics must be an object' using errcode = '22023'; end if;
    perform pg_catalog.set_config('app.athlete_resubmission_user', v_user::text, true);
    update public.athlete_statistics set
      competition_id=v_new_stats.competition_id, fixture_id=v_new_stats.fixture_id,
      season=v_new_stats.season, period_label=v_new_stats.period_label, metrics=v_new_stats.metrics,
      approval_status='pending', approved_by=null, approved_at=null,
      review_note=null, reviewed_by=null, reviewed_at=null, updated_at=pg_catalog.now()
    where id=p_record_id;
  elsif p_record_type = 'achievement' then
    select x.* into v_achievement
    from public.athlete_achievements x
    join public.athletes a on a.id=x.athlete_id
    where x.id=p_record_id and a.profile_id=v_user and x.review_status='rejected'
    for update of x;
    if not found then raise exception 'Rejected achievement not found for this account' using errcode = '42501'; end if;
    if (p_changes - array['title','description','category','award_date','competition_id']) <> '{}'::jsonb then
      raise exception 'One or more achievement fields cannot be changed here' using errcode = '22023';
    end if;
    select pg_catalog.jsonb_populate_record(v_achievement, p_changes) into v_new_achievement;
    if pg_catalog.btrim(coalesce(v_new_achievement.title,'')) = '' then raise exception 'Achievement title is required' using errcode = '22023'; end if;
    perform pg_catalog.set_config('app.athlete_resubmission_user', v_user::text, true);
    update public.athlete_achievements set
      title=v_new_achievement.title, description=v_new_achievement.description,
      category=v_new_achievement.category, award_date=v_new_achievement.award_date,
      competition_id=v_new_achievement.competition_id,
      review_status='pending', is_verified=false, verified_by=null, verified_at=null,
      review_note=null, reviewed_by=null, reviewed_at=null
    where id=p_record_id;
  elsif p_record_type = 'media' then
    select m.* into v_media
    from public.athlete_media m
    join public.athletes a on a.id=m.athlete_id
    where m.id=p_record_id and a.profile_id=v_user and m.review_status='rejected'
    for update of m;
    if not found then raise exception 'Rejected media record not found for this account' using errcode = '42501'; end if;
    if (p_changes - array['media_type','title','description','external_url']) <> '{}'::jsonb then
      raise exception 'Only media type, title, description and external URL can be corrected' using errcode = '22023';
    end if;
    select pg_catalog.jsonb_populate_record(v_media, p_changes) into v_new_media;
    if v_new_media.external_url is not null and v_new_media.external_url !~* '^https?://' then
      raise exception 'Media URL must start with http:// or https://' using errcode = '22023';
    end if;
    perform pg_catalog.set_config('app.athlete_resubmission_user', v_user::text, true);
    update public.athlete_media set
      media_type=v_new_media.media_type, title=v_new_media.title,
      description=v_new_media.description, external_url=v_new_media.external_url,
      visibility='private', review_status='pending', approved_by=null, approved_at=null,
      review_note=null, reviewed_by=null, reviewed_at=null
    where id=p_record_id;
  else
    raise exception 'Unsupported athlete record type' using errcode = '22023';
  end if;

  return pg_catalog.jsonb_build_object('success',true,'record_type',p_record_type,'record_id',p_record_id,'review_status','pending');
end;
$function$
;

revoke all on function public.resubmit_athlete_record(text, uuid, jsonb) from public, anon, authenticated;
grant execute on function public.resubmit_athlete_record(text, uuid, jsonb) to authenticated;
comment on function public.resubmit_athlete_record(text, uuid, jsonb) is 'Intentional authenticated per-user operation. SECURITY DEFINER is narrowly scoped to resubmitting an owned rejected athlete record; auth.uid ownership, rejected state, strict editable-field allowlists, and trigger-enforced transition checks are required.';
