create extension if not exists pg_cron with schema pg_catalog;

grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

create index if not exists orders_yoco_unlinked_pending_created_idx
on public.orders(created_at)
where payment_provider='yoco'
  and yoco_checkout_id is null
  and status='pending'
  and payment_status in ('unpaid','pending');

create or replace function private.release_unlinked_stale_yoco_orders()
returns integer
language plpgsql
security invoker
set search_path = ''
as $function$
declare
  v_order record;
  v_released integer := 0;
begin
  for v_order in
    select id
    from public.orders
    where payment_provider='yoco'
      and yoco_checkout_id is null
      and status='pending'
      and payment_status in ('unpaid','pending')
      and created_at < now() - interval '20 minutes'
    order by created_at
    limit 100
    for update skip locked
  loop
    perform public.cancel_yoco_order(v_order.id);
    v_released := v_released + 1;
  end loop;
  return v_released;
end;
$function$;

revoke all on function private.release_unlinked_stale_yoco_orders() from public, anon, authenticated, service_role;

select cron.schedule(
  'cut-sport-release-unlinked-yoco-orders',
  '*/5 * * * *',
  $$select private.release_unlinked_stale_yoco_orders();$$
);
