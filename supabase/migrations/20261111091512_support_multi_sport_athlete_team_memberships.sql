alter table public.athletes drop constraint if exists athletes_team_sport_fk;

create table public.athlete_team_memberships (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  sport_id uuid not null references public.sports(id) on delete restrict,
  position text,
  squad_number integer,
  is_active boolean not null default true,
  joined_at date not null default current_date,
  left_at date,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint athlete_team_memberships_team_sport_fk
    foreign key (team_id,sport_id) references public.teams(id,sport_id) on update cascade on delete cascade,
  constraint athlete_team_memberships_unique unique (athlete_id,team_id),
  constraint athlete_team_memberships_squad_number_check check (squad_number is null or squad_number between 0 and 999),
  constraint athlete_team_memberships_position_check check (position is null or length(position)<=120),
  constraint athlete_team_memberships_dates_check check (left_at is null or left_at>=joined_at)
);

create index athlete_team_memberships_athlete_active_idx on public.athlete_team_memberships(athlete_id,is_active);
create index athlete_team_memberships_team_active_idx on public.athlete_team_memberships(team_id,is_active);
create index athlete_team_memberships_sport_active_idx on public.athlete_team_memberships(sport_id,is_active);

insert into public.athlete_team_memberships
  (athlete_id,team_id,sport_id,position,squad_number,is_active,created_by)
select a.id,t.id,t.sport_id,a.position,a.squad_number,true,coalesce(a.profile_id,a.verified_by)
from public.athletes a
join public.teams t on t.id=a.team_id
where a.team_id is not null and coalesce(a.profile_id,a.verified_by) is not null
on conflict (athlete_id,team_id) do nothing;

alter table public.athlete_team_memberships enable row level security;
grant select on public.athlete_team_memberships to anon,authenticated;
grant insert (athlete_id,team_id,sport_id,position,squad_number,is_active,joined_at,left_at,created_by)
  on public.athlete_team_memberships to authenticated;
grant update (position,squad_number,is_active,left_at,updated_at)
  on public.athlete_team_memberships to authenticated;
grant delete on public.athlete_team_memberships to authenticated;

create policy "Public read visible athlete team memberships"
on public.athlete_team_memberships for select to anon,authenticated
using (
  exists (
    select 1 from public.athletes a
    join public.teams t on t.id=athlete_team_memberships.team_id
    where a.id=athlete_team_memberships.athlete_id
      and a.approval_status='approved'
      and a.profile_visibility='public'
      and t.is_active=true
  )
);

create policy "Athletes read own team memberships"
on public.athlete_team_memberships for select to authenticated
using (
  exists (select 1 from public.athletes a where a.id=athlete_team_memberships.athlete_id and a.profile_id=(select auth.uid()))
);

create policy "Assigned sport staff read team memberships"
on public.athlete_team_memberships for select to authenticated
using (private.can_manage_sport(sport_id));

create policy "Assigned sport staff add athlete to team"
on public.athlete_team_memberships for insert to authenticated
with check (
  created_by=(select auth.uid())
  and private.can_manage_sport(sport_id)
  and exists (select 1 from public.athletes a where a.id=athlete_team_memberships.athlete_id)
);

create policy "Assigned sport staff update team membership"
on public.athlete_team_memberships for update to authenticated
using (private.can_manage_sport(sport_id))
with check (private.can_manage_sport(sport_id));

create policy "Assigned sport staff remove team membership"
on public.athlete_team_memberships for delete to authenticated
using (private.can_manage_sport(sport_id));

create or replace function private.guard_athlete_team_membership()
returns trigger language plpgsql set search_path=''
as $$
declare v_team_sport uuid;
begin
  select t.sport_id into v_team_sport from public.teams t where t.id=new.team_id;
  if v_team_sport is null or v_team_sport is distinct from new.sport_id then
    raise exception 'Selected team and sport do not match';
  end if;
  if tg_op='UPDATE' and (
    new.athlete_id is distinct from old.athlete_id
    or new.team_id is distinct from old.team_id
    or new.sport_id is distinct from old.sport_id
    or new.created_by is distinct from old.created_by
  ) then raise exception 'Team membership identity fields cannot be changed'; end if;
  new.updated_at=now();
  return new;
end;
$$;
revoke all on function private.guard_athlete_team_membership() from public,anon,authenticated;
create trigger guard_athlete_team_membership before insert or update on public.athlete_team_memberships
for each row execute function private.guard_athlete_team_membership();