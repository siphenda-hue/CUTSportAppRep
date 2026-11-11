create table if not exists public.competition_standings (
 id uuid primary key default gen_random_uuid(),
 competition_id uuid not null references public.competitions(id) on delete cascade,
 team_name text not null,
 team_logo_url text,
 group_name text,
 position integer,
 played integer not null default 0 check (played>=0),
 won integer not null default 0 check (won>=0),
 drawn integer not null default 0 check (drawn>=0),
 lost integer not null default 0 check (lost>=0),
 scored integer not null default 0 check (scored>=0),
 conceded integer not null default 0 check (conceded>=0),
 points_difference integer,
 bonus_points integer not null default 0 check (bonus_points>=0),
 points integer not null default 0 check (points>=0),
 source_url text,
 source_checked_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(competition_id,team_name,group_name)
);
alter table public.competition_standings enable row level security;
create policy "Competition standings public read" on public.competition_standings for select to anon,authenticated using (true);
create policy "Assigned sport admins manage competition standings" on public.competition_standings for all to authenticated
using (exists(select 1 from public.competitions c where c.id=competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id)))
with check (exists(select 1 from public.competitions c where c.id=competition_id and c.sport_id is not null and private.can_manage_sport(c.sport_id)));
create index if not exists competition_standings_log_idx on public.competition_standings(competition_id,group_name,position);

insert into public.competitions(sport_id,name,season,start_date,end_date,description,status)
select s.id,v.name,v.season,v.start_date::date,v.end_date::date,v.description,'published'
from (values
 ('Football','Hollywoodbets Super League','2026',null,null,'Women’s senior football league. Track the applicable 2026 streams and official results.'),
 ('Rugby','FNB Varsity Cup','2026','2026-02-16','2026-04-13','Men’s university rugby competition. 2026 season completed; preserve results and log as historical.'),
 ('Rugby','FNB Varsity Cup Women','2026',null,null,'Women’s university rugby competition. 2026 season; dates to be confirmed from official records.'),
 ('Netball','Varsity Netball','2026','2026-08-23','2026-09-28','2026 university netball competition; CUT debut season.')
) as v(sport_name,name,season,start_date,end_date,description)
join public.sports s on s.name=v.sport_name
where not exists(select 1 from public.competitions c where c.sport_id=s.id and c.name=v.name and c.season=v.season);
