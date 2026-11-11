-- Recruitment opportunities and secure athlete trial applications.
create unique index if not exists teams_id_sport_id_unique on public.teams(id,sport_id);
create table if not exists public.recruitment_opportunities (
 id uuid primary key default gen_random_uuid(),
 sport_id uuid not null references public.sports(id) on delete restrict,
 team_id uuid,
 title text not null check (length(btrim(title)) between 3 and 140),
 description text,
 venue text,
 starts_at timestamptz,
 closes_at timestamptz,
 status text not null default 'draft' check (status in ('draft','open','closed','cancelled')),
 created_by uuid not null references auth.users(id) on delete restrict,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check (closes_at is null or starts_at is null or closes_at <= starts_at),
 constraint recruitment_team_sport_fk foreign key(team_id,sport_id) references public.teams(id,sport_id) on delete restrict
);
create index if not exists recruitment_opportunities_public_idx on public.recruitment_opportunities(status,closes_at,starts_at) where status='open';
create index if not exists recruitment_opportunities_sport_idx on public.recruitment_opportunities(sport_id,created_at desc);
create table if not exists public.trial_applications (
 id uuid primary key default gen_random_uuid(),
 opportunity_id uuid not null references public.recruitment_opportunities(id) on delete restrict,
 applicant_user_id uuid not null references auth.users(id) on delete restrict,
 athlete_id uuid references public.athletes(id) on delete set null,
 full_name text not null check(length(btrim(full_name)) between 2 and 120),
 playing_position text,
 experience text,
 motivation text check(motivation is null or length(motivation)<=3000),
 status text not null default 'submitted' check(status in ('submitted','shortlisted','selected','not_selected')),
 coach_notes text,
 reviewed_by uuid references auth.users(id) on delete set null,
 reviewed_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(opportunity_id,applicant_user_id)
);
create index if not exists trial_applications_opportunity_status_idx on public.trial_applications(opportunity_id,status,created_at desc);
create index if not exists trial_applications_applicant_idx on public.trial_applications(applicant_user_id,created_at desc);
alter table public.recruitment_opportunities enable row level security;
alter table public.trial_applications enable row level security;
create policy "Open recruitment opportunities are public" on public.recruitment_opportunities for select to anon,authenticated using (status='open' and (closes_at is null or closes_at>=now()));
create policy "Assigned staff manage recruitment opportunities" on public.recruitment_opportunities for all to authenticated using (private.can_manage_athlete(sport_id,team_id)) with check (private.can_manage_athlete(sport_id,team_id) and created_by=(select auth.uid()));
create policy "Applicants and assigned staff read trial applications" on public.trial_applications for select to authenticated using (
 applicant_user_id=(select auth.uid()) or exists(select 1 from public.recruitment_opportunities o where o.id=opportunity_id and private.can_manage_athlete(o.sport_id,o.team_id))
);
create policy "Users apply to open opportunities" on public.trial_applications for insert to authenticated with check (
 applicant_user_id=(select auth.uid())
 and exists(select 1 from public.recruitment_opportunities o where o.id=opportunity_id and o.status='open' and (o.closes_at is null or o.closes_at>=now()))
 and (athlete_id is null or exists(select 1 from public.athletes a where a.id=athlete_id and a.profile_id=(select auth.uid())))
);
create policy "Assigned staff update trial applications" on public.trial_applications for update to authenticated using (
 exists(select 1 from public.recruitment_opportunities o where o.id=opportunity_id and private.can_manage_athlete(o.sport_id,o.team_id))
) with check (
 exists(select 1 from public.recruitment_opportunities o where o.id=opportunity_id and private.can_manage_athlete(o.sport_id,o.team_id))
);
revoke all on public.recruitment_opportunities from anon,authenticated;
grant select on public.recruitment_opportunities to anon,authenticated;
grant insert,update,delete on public.recruitment_opportunities to authenticated;
revoke all on public.trial_applications from anon,authenticated;
grant select,insert,update on public.trial_applications to authenticated;
