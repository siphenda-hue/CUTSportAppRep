create table if not exists public.competition_matches (
  id uuid primary key default gen_random_uuid(),
  competition_id uuid not null references public.competitions(id) on delete cascade,
  source_match_id text not null,
  starts_at timestamptz,
  home_team text not null,
  away_team text not null,
  home_score integer,
  away_score integer,
  match_status text not null default 'scheduled',
  match_round text,
  group_name text,
  venue text,
  source_url text not null,
  source_checked_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (competition_id, source_match_id)
);
create index if not exists competition_matches_schedule_idx on public.competition_matches (competition_id, starts_at);
create table if not exists public.competition_player_statistics (
  id uuid primary key default gen_random_uuid(),
  competition_id uuid not null references public.competitions(id) on delete cascade,
  player_name text not null,
  team_name text not null,
  squad_number integer,
  field_goals integer not null default 0,
  penalty_corner_goals integer not null default 0,
  penalty_stroke_goals integer not null default 0,
  total_goals integer not null default 0,
  source_url text not null,
  source_checked_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (competition_id, player_name, team_name)
);
create index if not exists competition_player_statistics_rank_idx on public.competition_player_statistics (competition_id, total_goals desc, player_name);
alter table public.competition_matches enable row level security;
alter table public.competition_player_statistics enable row level security;
create policy "Competition matches public read" on public.competition_matches for select using (true);
create policy "Assigned sport admins manage competition matches" on public.competition_matches for all using (exists (select 1 from public.competitions c where c.id=competition_matches.competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id))) with check (exists (select 1 from public.competitions c where c.id=competition_matches.competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id)));
create policy "Competition player statistics public read" on public.competition_player_statistics for select using (true);
create policy "Assigned sport admins manage competition player statistics" on public.competition_player_statistics for all using (exists (select 1 from public.competitions c where c.id=competition_player_statistics.competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id))) with check (exists (select 1 from public.competitions c where c.id=competition_player_statistics.competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id)));
