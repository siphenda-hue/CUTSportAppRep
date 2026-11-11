drop index if exists public.trial_application_scores_application_idx;

create index if not exists trial_evaluation_criteria_created_by_idx
  on public.trial_evaluation_criteria(created_by);
create index if not exists trial_application_scores_application_opportunity_idx
  on public.trial_application_scores(application_id, opportunity_id);
create index if not exists trial_application_scores_criterion_opportunity_idx
  on public.trial_application_scores(criterion_id, opportunity_id);
create index if not exists trial_application_scores_reviewer_idx
  on public.trial_application_scores(reviewer_id);
create index if not exists athletes_team_sport_idx
  on public.athletes(team_id, sport_id);