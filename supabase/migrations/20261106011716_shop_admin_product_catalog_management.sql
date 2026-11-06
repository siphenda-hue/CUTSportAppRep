grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;

drop policy if exists "Shop admins manage all products" on public.products;
create policy "Shop admins manage all products"
on public.products
for all
to authenticated
using (
  exists (
    select 1
    from public.user_roles ur
    where ur.user_id = (select auth.uid())
      and ur.role::text in ('shop_admin', 'super_admin')
  )
)
with check (
  exists (
    select 1
    from public.user_roles ur
    where ur.user_id = (select auth.uid())
      and ur.role::text in ('shop_admin', 'super_admin')
  )
);
