do $$
begin
  if not (select c.relrowsecurity from pg_class c where c.oid='public.event_ticket_types'::regclass) then raise exception 'Ticket types RLS is not enabled'; end if;
  if not (select c.relrowsecurity from pg_class c where c.oid='public.yoco_webhook_events'::regclass) then raise exception 'Webhook event RLS is not enabled'; end if;
  if has_table_privilege('anon','public.orders','insert') or has_table_privilege('authenticated','public.orders','insert') then raise exception 'Client roles must not create orders directly'; end if;
  if has_table_privilege('anon','public.tickets','insert') or has_table_privilege('authenticated','public.tickets','insert') then raise exception 'Client roles must not issue tickets directly'; end if;
  if has_table_privilege('anon','public.order_items','insert') or has_table_privilege('authenticated','public.order_items','insert') then raise exception 'Client roles must not create order items directly'; end if;
  if has_function_privilege('anon','public.create_yoco_order(uuid,text,jsonb,uuid)','execute') or has_function_privilege('authenticated','public.create_yoco_order(uuid,text,jsonb,uuid)','execute') then raise exception 'Client roles must not execute privileged order creation'; end if;
  if not has_function_privilege('service_role','public.create_yoco_order(uuid,text,jsonb,uuid)','execute') then raise exception 'Service role cannot create orders'; end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='event_ticket_types' and policyname='Published event ticket types are public') then raise exception 'Public ticket type read policy missing'; end if;
  if not exists (select 1 from pg_policies where schemaname='public' and tablename='yoco_webhook_events' and policyname='Service role manages Yoco webhook events') then raise exception 'Webhook receipt policy missing'; end if;
  if not exists (select 1 from pg_indexes where schemaname='public' and indexname='orders_user_checkout_request_key') then raise exception 'Checkout idempotency index missing'; end if;
end;
$$;
