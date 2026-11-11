revoke insert,update,delete on public.recruitment_opportunities from authenticated;
grant insert(sport_id,team_id,title,description,venue,starts_at,closes_at,status,created_by) on public.recruitment_opportunities to authenticated;
grant update(sport_id,team_id,title,description,venue,starts_at,closes_at,status,updated_at) on public.recruitment_opportunities to authenticated;
grant delete on public.recruitment_opportunities to authenticated;
revoke insert,update on public.trial_applications from authenticated;
grant insert(opportunity_id,applicant_user_id,athlete_id,full_name,playing_position,experience,motivation) on public.trial_applications to authenticated;
grant update(status,coach_notes,reviewed_by,reviewed_at,updated_at) on public.trial_applications to authenticated;