-- CUT Sport orphaned Yoco reservation cleanup regression checks.
do $$
begin
  if not exists (select 1 from pg_extension where extname='pg_cron') then
    raise exception 'pg_cron extension is not enabled';
  end if;
  if not exists (
    select 1 from cron.job
    where jobname='cut-sport-release-unlinked-yoco-orders'
      and schedule='*/5 * * * *'
      and active=true
      and username='postgres'
  ) then
    raise exception 'Expected active orphan cleanup cron job is missing';
  end if;
  if has_function_privilege('anon','private.release_unlinked_stale_yoco_orders()','EXECUTE') then
    raise exception 'anon must not execute orphan cleanup';
  end if;
  if has_function_privilege('authenticated','private.release_unlinked_stale_yoco_orders()','EXECUTE') then
    raise exception 'authenticated must not execute orphan cleanup';
  end if;
  if has_function_privilege('service_role','private.release_unlinked_stale_yoco_orders()','EXECUTE') then
    raise exception 'service_role must not execute orphan cleanup directly';
  end if;
end $$;

-- Safe to run: only old Yoco orders without a persisted checkout ID are eligible.
select private.release_unlinked_stale_yoco_orders() as orphaned_orders_released;
