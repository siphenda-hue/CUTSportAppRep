create policy "Shop admins read shop orders"
on public.orders
for select
to authenticated
using (
  order_kind = 'shop'
  and exists (
    select 1
    from public.user_roles ur
    where ur.user_id = (select auth.uid())
      and ur.role::text in ('shop_admin', 'super_admin')
  )
);

create policy "Shop admins read shop order items"
on public.order_items
for select
to authenticated
using (
  item_type = 'product'
  and exists (
    select 1
    from public.orders o
    join public.user_roles ur
      on ur.user_id = (select auth.uid())
     and ur.role::text in ('shop_admin', 'super_admin')
    where o.id = order_items.order_id
      and o.order_kind = 'shop'
  )
);
