create or replace function public.transition_shop_order(
  p_order_id uuid,
  p_expected_status text,
  p_new_status text,
  p_actor_id uuid,
  p_note text default null
)
returns table(order_id uuid, new_status public.order_status, changed_at timestamptz)
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_old_status public.order_status;
  v_new_status public.order_status;
  v_changed_at timestamptz;
begin
  if p_actor_id is null or p_order_id is null then
    raise exception 'Order and actor are required' using errcode = '22023';
  end if;
  if p_note is not null and char_length(p_note) > 500 then
    raise exception 'Note must be 500 characters or fewer' using errcode = '22023';
  end if;
  begin
    v_new_status := p_new_status::public.order_status;
  exception when invalid_text_representation then
    raise exception 'Invalid target order status' using errcode = '22023';
  end;
  if not ((p_expected_status = 'paid' and v_new_status = 'processing')
       or (p_expected_status = 'processing' and v_new_status = 'fulfilled')) then
    raise exception 'Only paid-to-processing and processing-to-fulfilled transitions are allowed' using errcode = '22023';
  end if;

  select o.status into v_old_status
    from public.orders o
   where o.id = p_order_id
     and o.order_kind = 'shop'
     and o.status::text = p_expected_status
     and o.payment_status = 'succeeded'
   for update;
  if not found then
    raise exception 'Order not found, not paid, or status has changed. Refresh and try again.' using errcode = 'P0002';
  end if;

  update public.orders
     set status = v_new_status
   where id = p_order_id and status = v_old_status;
  if not found then
    raise exception 'Order status changed concurrently. Refresh and try again.' using errcode = '40001';
  end if;

  v_changed_at := now();
  insert into private.shop_order_status_events(order_id, actor_id, from_status, to_status, note, created_at)
  values (p_order_id, p_actor_id, v_old_status, v_new_status, nullif(trim(p_note), ''), v_changed_at);
  return query select p_order_id, v_new_status, v_changed_at;
end;
$$;

revoke all on function public.transition_shop_order(uuid,text,text,uuid,text) from public, anon, authenticated;
grant execute on function public.transition_shop_order(uuid,text,text,uuid,text) to service_role;
