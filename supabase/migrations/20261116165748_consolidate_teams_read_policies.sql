drop policy if exists "Assigned sport admins read all teams" on public.teams;
drop policy if exists "Teams public read" on public.teams;
create policy "Teams public read"
on public.teams
for select
to anon
using (is_active = true);
create policy "Authenticated users read active or assigned teams"
on public.teams
for select
to authenticated
using (
  is_active = true
  or (select private.can_manage_sport(teams.sport_id))
);
