alter table public.orders
  add column if not exists checkout_request_id uuid,
  add column if not exists yoco_redirect_url text;
create unique index if not exists orders_user_checkout_request_key
  on public.orders(user_id,checkout_request_id) where checkout_request_id is not null;

grant insert, update, delete on public.event_ticket_types to authenticated;
grant select on public.event_ticket_types to anon, authenticated;
revoke all on function public.create_yoco_order(uuid,text,jsonb) from public,anon,authenticated;
drop function public.create_yoco_order(uuid,text,jsonb);

create function public.create_yoco_order(p_user_id uuid,p_order_kind text,p_lines jsonb,p_request_id uuid)
returns jsonb language plpgsql security invoker set search_path = ''
as $function$
declare
  v_order_id uuid:=gen_random_uuid();
  v_order_number text:='CUT-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  v_existing public.orders%rowtype; v_line jsonb; v_qty integer; v_product record; v_ticket record;
  v_total integer:=0; v_name text; v_price integer; v_item_type text;
begin
  if p_user_id is null or p_request_id is null or p_order_kind not in ('shop','event')
     or jsonb_typeof(p_lines)<>'array' or jsonb_array_length(p_lines)=0 or jsonb_array_length(p_lines)>20 then
    raise exception 'Invalid checkout request' using errcode='22023';
  end if;
  perform pg_advisory_xact_lock(hashtextextended(p_user_id::text||p_request_id::text,0));
  select * into v_existing from public.orders where user_id=p_user_id and checkout_request_id=p_request_id for update;
  if found then
    if v_existing.status='cancelled' or v_existing.payment_status in ('failed','refunded') then
      raise exception 'This checkout request has already expired; start a new checkout' using errcode='55000';
    end if;
    return jsonb_build_object('order_id',v_existing.id,'order_number',v_existing.order_number,
      'amount',v_existing.total_cents,'currency',v_existing.currency,
      'checkout_id',v_existing.yoco_checkout_id,'redirect_url',v_existing.yoco_redirect_url);
  end if;
  insert into public.orders(user_id,order_number,status,subtotal_cents,total_cents,currency,order_kind,payment_provider,payment_status,checkout_request_id)
  values(p_user_id,v_order_number,'pending',0,0,'ZAR',p_order_kind,'yoco','unpaid',p_request_id);
  for v_line in select value from jsonb_array_elements(p_lines) loop
    v_qty:=(v_line->>'quantity')::integer;
    if v_qty<1 or v_qty>10 then raise exception 'Quantity must be between 1 and 10' using errcode='22023'; end if;
    if p_order_kind='shop' then
      select id,name,price_cents,stock_quantity,is_active into v_product from public.products where id=(v_line->>'product_id')::uuid for update;
      if not found or not v_product.is_active then raise exception 'A selected product is unavailable' using errcode='P0002'; end if;
      if v_product.stock_quantity<v_qty then raise exception 'Insufficient stock for %',v_product.name using errcode='23514'; end if;
      update public.products set stock_quantity=stock_quantity-v_qty where id=v_product.id;
      v_name:=v_product.name;v_price:=v_product.price_cents;v_item_type:='product';
      insert into public.order_items(order_id,product_id,product_name,quantity,unit_price_cents,item_type)
      values(v_order_id,v_product.id,v_name,v_qty,v_price,v_item_type);
    else
      select tt.id,tt.event_id,tt.name,tt.price_cents,tt.quantity_available,tt.max_per_order,tt.is_active,e.title,e.published,e.ticketed
      into v_ticket from public.event_ticket_types tt join public.events e on e.id=tt.event_id
      where tt.id=(v_line->>'ticket_type_id')::uuid for update of tt;
      if not found or not v_ticket.is_active or not v_ticket.published or not v_ticket.ticketed then raise exception 'A selected ticket type is unavailable' using errcode='P0002'; end if;
      if v_qty>v_ticket.max_per_order or v_ticket.quantity_available<v_qty then raise exception 'Ticket quantity exceeds availability or per-order limit' using errcode='23514'; end if;
      update public.event_ticket_types set quantity_available=quantity_available-v_qty,updated_at=now() where id=v_ticket.id;
      v_name:=v_ticket.name||' — '||v_ticket.title;v_price:=v_ticket.price_cents;v_item_type:='event_ticket';
      insert into public.order_items(order_id,product_name,quantity,unit_price_cents,item_type,event_id,ticket_type_id)
      values(v_order_id,v_name,v_qty,v_price,v_item_type,v_ticket.event_id,v_ticket.id);
    end if;
    v_total:=v_total+(v_price*v_qty);
  end loop;
  if v_total<200 then raise exception 'Yoco card checkout minimum is R2.00' using errcode='22023'; end if;
  update public.orders set subtotal_cents=v_total,total_cents=v_total where id=v_order_id;
  return jsonb_build_object('order_id',v_order_id,'order_number',v_order_number,'amount',v_total,'currency','ZAR');
end;
$function$;
revoke all on function public.create_yoco_order(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function public.create_yoco_order(uuid,text,jsonb,uuid) to service_role;
