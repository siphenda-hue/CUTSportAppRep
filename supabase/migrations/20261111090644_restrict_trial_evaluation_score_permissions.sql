revoke all on table public.trial_evaluation_criteria from public, anon, authenticated;
revoke all on table public.trial_application_scores from public, anon, authenticated;

grant select on table public.trial_evaluation_criteria to authenticated;
grant insert (opportunity_id, title, description, max_score, display_order, created_by)
  on table public.trial_evaluation_criteria to authenticated;

grant select on table public.trial_application_scores to authenticated;
grant insert (application_id, opportunity_id, criterion_id, reviewer_id, score, comments)
  on table public.trial_application_scores to authenticated;
grant update (score, comments)
  on table public.trial_application_scores to authenticated;