-- Sport catalogue administration with least-privilege grants and scoped RLS.
-- Super administrators create sports. Super administrators and active full-sport
-- administrators may update/archive only sports they are authorised to manage.

begin;

revoke all privileges on table public.sports from anon, authenticated;
grant select on table public.sports to anon;
grant select, insert, update on table public.sports to authenticated;

create policy "Assigned sport admins read managed sports" on public.sports
for select to authenticated
using ((select private.can_manage_sport(id)));

create policy "Super admins create sports" on public.sports
for insert to authenticated
with check (
  exists (
    select 1
    from public.user_roles ur
    where ur.user_id = (select auth.uid())
      and ur.role::text = 'super_admin'
  )
);

create policy "Assigned sport admins update sports" on public.sports
for update to authenticated
using ((select private.can_manage_sport(id)))
with check ((select private.can_manage_sport(id)));

commit;
