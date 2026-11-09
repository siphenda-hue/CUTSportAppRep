-- Add reversible event archiving and permit super administrators to edit
-- editorial records created by other staff while preserving sport-scoped access.

alter table public.events
  add column if not exists archived_at timestamptz;

create index if not exists events_active_published_starts_at_idx
  on public.events (starts_at)
  where published = true and archived_at is null;

drop policy if exists "Assigned sport admins update articles" on public.articles;

create policy "Assigned sport admins update articles"
on public.articles
for update
to authenticated
using (private.can_manage_sport(sport_id))
with check (
  private.can_manage_sport(sport_id)
  and (
    public.has_role('super_admin'::public.app_role)
    or author_id is null
    or author_id = (select auth.uid())
  )
);
