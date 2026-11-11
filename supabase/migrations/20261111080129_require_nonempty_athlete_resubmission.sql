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
  if p_record_id is null or p_changes is null or pg_catalog.jsonb_typeof(p_changes) <> 'object' or p_changes = '{}'::jsonb then
    raise exception 'A record ID and at least one corrected field are required' using errcode = '22023';
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
