drop policy if exists "Assigned sport staff read team memberships" on public.athlete_team_memberships;
drop policy if exists "Assigned sport staff add athlete to team" on public.athlete_team_memberships;
drop policy if exists "Assigned sport staff update team membership" on public.athlete_team_memberships;
drop policy if exists "Assigned sport staff remove team membership" on public.athlete_team_memberships;

create policy "Assigned team staff read team memberships"
on public.athlete_team_memberships for select to authenticated
using (private.can_manage_athlete(sport_id,team_id));

create policy "Assigned team staff add athlete to team"
on public.athlete_team_memberships for insert to authenticated
with check (
  created_by=(select auth.uid())
  and private.can_manage_athlete(sport_id,team_id)
  and exists (select 1 from public.athletes a where a.id=athlete_team_memberships.athlete_id)
);

create policy "Assigned team staff update team membership"
on public.athlete_team_memberships for update to authenticated
using (private.can_manage_athlete(sport_id,team_id))
with check (private.can_manage_athlete(sport_id,team_id));

create policy "Assigned team staff remove team membership"
on public.athlete_team_memberships for delete to authenticated
using (private.can_manage_athlete(sport_id,team_id));