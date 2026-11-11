
create table if not exists public.competition_team_statistics (
 id uuid primary key default gen_random_uuid(),
 competition_id uuid not null references public.competitions(id) on delete cascade,
 team_name text not null,
 field_goals integer not null default 0,
 penalty_corner_goals integer not null default 0,
 penalty_stroke_goals integer not null default 0,
 total_goals integer not null default 0,
 source_url text not null,
 source_checked_at timestamptz not null default now(),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique (competition_id,team_name)
);
create index if not exists competition_team_statistics_idx on public.competition_team_statistics(competition_id,total_goals desc);
alter table public.competition_team_statistics enable row level security;
drop policy if exists "Competition team statistics public read" on public.competition_team_statistics;
drop policy if exists "Assigned sport admins manage competition team statistics" on public.competition_team_statistics;
create policy "Competition team statistics public read" on public.competition_team_statistics for select using (true);
create policy "Assigned sport admins manage competition team statistics" on public.competition_team_statistics for all using (exists (select 1 from public.competitions c where c.id=competition_team_statistics.competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id))) with check (exists (select 1 from public.competitions c where c.id=competition_team_statistics.competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id)));
