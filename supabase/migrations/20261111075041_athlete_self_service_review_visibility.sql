-- Allow an authenticated athlete to read only their own profile and review records.
-- Ownership is anchored to athletes.profile_id = auth.uid(); staff policies remain unchanged.

drop policy if exists "Athletes can view own profile and review" on public.athletes;
create policy "Athletes can view own profile and review"
on public.athletes
for select
to authenticated
using ((select auth.uid()) = profile_id);

drop policy if exists "Athletes can view own statistics review" on public.athlete_statistics;
create policy "Athletes can view own statistics review"
on public.athlete_statistics
for select
to authenticated
using (
  exists (
    select 1 from public.athletes a
    where a.id = athlete_statistics.athlete_id
      and a.profile_id = (select auth.uid())
  )
);

drop policy if exists "Athletes can view own achievements review" on public.athlete_achievements;
create policy "Athletes can view own achievements review"
on public.athlete_achievements
for select
to authenticated
using (
  exists (
    select 1 from public.athletes a
    where a.id = athlete_achievements.athlete_id
      and a.profile_id = (select auth.uid())
  )
);

drop policy if exists "Athletes can view own media review" on public.athlete_media;
create policy "Athletes can view own media review"
on public.athlete_media
for select
to authenticated
using (
  exists (
    select 1 from public.athletes a
    where a.id = athlete_media.athlete_id
      and a.profile_id = (select auth.uid())
  )
);