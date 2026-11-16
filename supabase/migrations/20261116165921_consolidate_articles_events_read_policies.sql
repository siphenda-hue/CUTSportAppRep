drop policy if exists "Assigned sport admins read all articles" on public.articles;
drop policy if exists "Published articles public read" on public.articles;
create policy "Published articles public read"
on public.articles
for select
to anon
using (status = 'published'::text);
create policy "Authenticated users read published or assigned articles"
on public.articles
for select
to authenticated
using (
  status = 'published'::text
  or (select private.can_manage_sport(articles.sport_id))
);

drop policy if exists "Assigned sport admins read all events" on public.events;
drop policy if exists "Published events public read" on public.events;
create policy "Published events public read"
on public.events
for select
to anon
using (published = true);
create policy "Authenticated users read published or assigned events"
on public.events
for select
to authenticated
using (
  published = true
  or (select private.can_manage_sport(events.sport_id))
);
