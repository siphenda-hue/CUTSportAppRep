create table public.trial_application_reviews (
 application_id uuid primary key references public.trial_applications(id) on delete cascade,
 coach_notes text,
 reviewer_id uuid references auth.users(id) on delete set null,
 updated_at timestamptz not null default now(),
 check (coach_notes is null or length(coach_notes)<=4000)
);
alter table public.trial_application_reviews enable row level security;
create policy "Assigned staff manage private trial evaluations" on public.trial_application_reviews for all to authenticated
 using (exists(select 1 from public.trial_applications a join public.recruitment_opportunities o on o.id=a.opportunity_id where a.id=application_id and private.can_manage_athlete(o.sport_id,o.team_id)))
 with check (exists(select 1 from public.trial_applications a join public.recruitment_opportunities o on o.id=a.opportunity_id where a.id=application_id and private.can_manage_athlete(o.sport_id,o.team_id)));
revoke all on public.trial_application_reviews from anon,authenticated;
grant select,insert,update on public.trial_application_reviews to authenticated;
alter table public.trial_applications drop column coach_notes;