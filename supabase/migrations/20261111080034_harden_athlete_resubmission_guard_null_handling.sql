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
  if protected_changed and not approver and not coalesce(resubmission_allowed, false) then
    raise exception 'Only an assigned sport administrator can approve or publish athlete records'
      using errcode = '42501';
  end if;
  return new;
end;
$function$
;
