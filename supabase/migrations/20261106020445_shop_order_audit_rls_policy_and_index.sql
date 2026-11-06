create policy shop_order_status_events_deny_client_access
on private.shop_order_status_events
for all
to anon, authenticated
using (false)
with check (false);

create index if not exists shop_order_status_events_order_id_idx
on private.shop_order_status_events(order_id, created_at desc);
