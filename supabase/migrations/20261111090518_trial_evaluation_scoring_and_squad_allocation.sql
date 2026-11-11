create table public.trial_evaluation_criteria (
  id uuid primary key default gen_random_uuid(),
  opportunity_id uuid not null references public.recruitment_opportunities(id) on delete cascade,
  title text not null,
  description text,
  max_score numeric(7,2) not null default 10,
  display_order integer not null default 0,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint trial_evaluation_criteria_title_check check (length(btrim(title)) between 2 and 120),
  constraint trial_evaluation_criteria_description_check check (description is null or length(description) <= 1000),
  constraint trial_evaluation_criteria_max_score_check check (max_score > 0 and max_score <= 1000),
  constraint trial_evaluation_criteria_id_opportunity_key unique (id, opportunity_id)
);

alter table public.trial_applications
  add constraint trial_applications_id_opportunity_key unique (id, opportunity_id);

create table public.trial_application_scores (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null,
  opportunity_id uuid not null,
  criterion_id uuid not null,
  reviewer_id uuid not null references auth.users(id) on delete restrict,
  score numeric(7,2) not null,
  comments text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint trial_application_scores_application_opportunity_fk
    foreign key (application_id, opportunity_id)
    references public.trial_applications(id, opportunity_id) on delete cascade,
  constraint trial_application_scores_criterion_opportunity_fk
    foreign key (criterion_id, opportunity_id)
    references public.trial_evaluation_criteria(id, opportunity_id) on delete cascade,
  constraint trial_application_scores_score_check check (score >= 0 and score <= 1000),
  constraint trial_application_scores_comments_check check (comments is null or length(comments) <= 2000),
  constraint trial_application_scores_reviewer_unique unique (application_id, criterion_id, reviewer_id)
);

create index trial_evaluation_criteria_opportunity_order_idx
  on public.trial_evaluation_criteria(opportunity_id, display_order, created_at);
create index trial_application_scores_application_idx
  on public.trial_application_scores(application_id, criterion_id);
create index trial_application_scores_opportunity_idx
  on public.trial_application_scores(opportunity_id, reviewer_id);

alter table public.trial_evaluation_criteria enable row level security;
alter table public.trial_application_scores enable row level security;

grant select, insert, update, delete on public.trial_evaluation_criteria to authenticated;
grant select, insert, update on public.trial_application_scores to authenticated;

create policy "Assigned staff read trial evaluation criteria"
on public.trial_evaluation_criteria for select to authenticated
using (
  exists (
    select 1 from public.recruitment_opportunities o
    where o.id = trial_evaluation_criteria.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create policy "Assigned staff create trial evaluation criteria"
on public.trial_evaluation_criteria for insert to authenticated
with check (
  created_by = (select auth.uid())
  and exists (
    select 1 from public.recruitment_opportunities o
    where o.id = trial_evaluation_criteria.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create policy "Assigned staff update trial evaluation criteria"
on public.trial_evaluation_criteria for update to authenticated
using (
  exists (
    select 1 from public.recruitment_opportunities o
    where o.id = trial_evaluation_criteria.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
)
with check (
  exists (
    select 1 from public.recruitment_opportunities o
    where o.id = trial_evaluation_criteria.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create policy "Assigned staff delete trial evaluation criteria"
on public.trial_evaluation_criteria for delete to authenticated
using (
  exists (
    select 1 from public.recruitment_opportunities o
    where o.id = trial_evaluation_criteria.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create policy "Assigned staff read trial application scores"
on public.trial_application_scores for select to authenticated
using (
  exists (
    select 1
    from public.recruitment_opportunities o
    where o.id = trial_application_scores.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create policy "Assigned staff record own trial application scores"
on public.trial_application_scores for insert to authenticated
with check (
  reviewer_id = (select auth.uid())
  and exists (
    select 1
    from public.recruitment_opportunities o
    where o.id = trial_application_scores.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create policy "Assigned staff update own trial application scores"
on public.trial_application_scores for update to authenticated
using (
  reviewer_id = (select auth.uid())
  and exists (
    select 1
    from public.recruitment_opportunities o
    where o.id = trial_application_scores.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
)
with check (
  reviewer_id = (select auth.uid())
  and exists (
    select 1
    from public.recruitment_opportunities o
    where o.id = trial_application_scores.opportunity_id
      and private.can_manage_athlete(o.sport_id, o.team_id)
  )
);

create or replace function private.guard_trial_application_score()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_max_score numeric(7,2);
begin
  select c.max_score into v_max_score
  from public.trial_evaluation_criteria c
  where c.id = new.criterion_id
    and c.opportunity_id = new.opportunity_id;

  if v_max_score is null then
    raise exception 'Evaluation criterion not found for this opportunity';
  end if;

  if new.score < 0 or new.score > v_max_score then
    raise exception 'Score must be between 0 and %', v_max_score;
  end if;

  if tg_op = 'UPDATE' and (
    new.application_id is distinct from old.application_id
    or new.opportunity_id is distinct from old.opportunity_id
    or new.criterion_id is distinct from old.criterion_id
    or new.reviewer_id is distinct from old.reviewer_id
  ) then
    raise exception 'Score ownership and relationship fields cannot be changed';
  end if;

  new.updated_at = now();
  return new;
end;
$$;

revoke all on function private.guard_trial_application_score() from public, anon, authenticated;

create trigger guard_trial_application_score
before insert or update on public.trial_application_scores
for each row execute function private.guard_trial_application_score();

alter table public.athletes
  add constraint athletes_team_sport_fk
  foreign key (team_id, sport_id)
  references public.teams(id, sport_id)
  on update cascade
  on delete no action;
