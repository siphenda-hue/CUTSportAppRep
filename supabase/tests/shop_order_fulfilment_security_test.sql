-- CUT Sport shop-order fulfilment security checks.
-- Read-only assertions; does not create or modify order data.

do $$
begin
  if has_function_privilege('anon', 'public.transition_shop_order(uuid,text,text,uuid,text)', 'execute') then
    raise exception 'anon must not execute the order transition function';
  end if;
  if has_function_privilege('authenticated', 'public.transition_shop_order(uuid,text,text,uuid,text)', 'execute') then
    raise exception 'authenticated must not execute the order transition function directly';
  end if;
  if not has_function_privilege('service_role', 'public.transition_shop_order(uuid,text,text,uuid,text)', 'execute') then
    raise exception 'service_role must execute the order transition function';
  end if;
  if (select prosecdef from pg_proc where oid = 'public.transition_shop_order(uuid,text,text,uuid,text)'::regprocedure) then
    raise exception 'order transition function must remain SECURITY INVOKER';
  end if;
  if not (select relrowsecurity from pg_class where oid = 'private.shop_order_status_events'::regclass) then
    raise exception 'order audit table must have RLS enabled';
  end if;
  if has_table_privilege('authenticated', 'private.shop_order_status_events', 'select') then
    raise exception 'authenticated users must not read internal fulfilment audit records';
  end if;
  if not has_table_privilege('service_role', 'private.shop_order_status_events', 'insert') then
    raise exception 'service_role must be able to write fulfilment audit records';
  end if;
  if not exists (select 1 from pg_policies where schemaname = 'private' and tablename = 'shop_order_status_events' and policyname = 'shop_order_status_events_deny_client_access') then
    raise exception 'explicit client-deny audit policy is missing';
  end if;
  if not exists (select 1 from pg_indexes where schemaname = 'private' and tablename = 'shop_order_status_events' and indexname = 'shop_order_status_events_order_id_idx') then
    raise exception 'audit order index is missing';
  end if;
  if position('for update' in lower(pg_get_functiondef('public.transition_shop_order(uuid,text,text,uuid,text)'::regprocedure))) = 0 then
    raise exception 'order transition must lock the row';
  end if;
end;
$$;
