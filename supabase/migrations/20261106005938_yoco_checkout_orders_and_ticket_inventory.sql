create table public.event_ticket_types (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  name text not null,
  description text,
  price_cents integer not null check (price_cents >= 0),
  quantity_available integer not null default 0 check (quantity_available >= 0),
  max_per_order integer not null default 6 check (max_per_order between 1 and 20),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint event_ticket_types_event_name_key unique(event_id,name)
);
create index event_ticket_types_event_active_idx on public.event_ticket_types(event_id,is_active);

alter table public.orders
  add column if not exists order_kind text not null default 'shop' check (order_kind in ('shop','event')),
  add column if not exists payment_provider text,
  add column if not exists payment_status text not null default 'unpaid' check (payment_status in ('unpaid','pending','succeeded','failed','refunded')),
  add column if not exists yoco_checkout_id text,
  add column if not exists yoco_payment_id text,
  add column if not exists paid_at timestamptz,
  add column if not exists checkout_expires_at timestamptz;
create unique index if not exists orders_yoco_checkout_id_key on public.orders(yoco_checkout_id) where yoco_checkout_id is not null;
create unique index if not exists orders_yoco_payment_id_key on public.orders(yoco_payment_id) where yoco_payment_id is not null;

alter table public.order_items
  add column if not exists item_type text not null default 'product' check (item_type in ('product','event_ticket')),
  add column if not exists event_id uuid references public.events(id),
  add column if not exists ticket_type_id uuid references public.event_ticket_types(id);
alter table public.tickets
  add column if not exists order_id uuid references public.orders(id),
  add column if not exists ticket_type_id uuid references public.event_ticket_types(id);
create index if not exists tickets_order_id_idx on public.tickets(order_id);

create table public.yoco_webhook_events (
  id text primary key,
  event_type text not null,
  checkout_id text,
  processed_at timestamptz not null default now()
);
alter table public.yoco_webhook_events enable row level security;
revoke all on public.yoco_webhook_events from anon, authenticated;
grant all on public.yoco_webhook_events to service_role;

alter table public.event_ticket_types enable row level security;
revoke all on public.event_ticket_types from anon, authenticated;
grant select on public.event_ticket_types to anon, authenticated;
grant all on public.event_ticket_types to service_role;
create policy "Published event ticket types are public" on public.event_ticket_types
for select to anon, authenticated using (
  is_active and exists (select 1 from public.events e where e.id=event_id and e.published=true and e.ticketed=true)
);
create policy "Assigned sport admins manage event ticket types" on public.event_ticket_types
for all to authenticated using (
  exists (select 1 from public.events e where e.id=event_id and private.can_manage_sport(e.sport_id))
) with check (
  exists (select 1 from public.events e where e.id=event_id and private.can_manage_sport(e.sport_id))
);

revoke insert, update, delete, truncate, references, trigger on public.orders, public.order_items, public.tickets from anon, authenticated;
grant select on public.orders, public.order_items, public.tickets to authenticated;

create or replace function public.create_yoco_order(p_user_id uuid,p_order_kind text,p_lines jsonb)
returns jsonb language plpgsql security invoker set search_path = ''
as $function$
declare
  v_order_id uuid := gen_random_uuid();
  v_order_number text := 'CUT-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  v_line jsonb; v_qty integer; v_product record; v_ticket record;
  v_total integer := 0; v_name text; v_price integer; v_item_type text;
begin
  if p_user_id is null or p_order_kind not in ('shop','event') or jsonb_typeof(p_lines)<>'array'
     or jsonb_array_length(p_lines)=0 or jsonb_array_length(p_lines)>20 then
    raise exception 'Invalid checkout request' using errcode='22023';
  end if;
  insert into public.orders(user_id,order_number,status,subtotal_cents,total_cents,currency,order_kind,payment_provider,payment_status)
  values(p_user_id,v_order_number,'pending',0,0,'ZAR',p_order_kind,'yoco','unpaid');
  for v_line in select value from jsonb_array_elements(p_lines) loop
    v_qty := (v_line->>'quantity')::integer;
    if v_qty<1 or v_qty>10 then raise exception 'Quantity must be between 1 and 10' using errcode='22023'; end if;
    if p_order_kind='shop' then
      select id,name,price_cents,stock_quantity,is_active into v_product from public.products where id=(v_line->>'product_id')::uuid for update;
      if not found or not v_product.is_active then raise exception 'A selected product is unavailable' using errcode='P0002'; end if;
      if v_product.stock_quantity<v_qty then raise exception 'Insufficient stock for %',v_product.name using errcode='23514'; end if;
      update public.products set stock_quantity=stock_quantity-v_qty where id=v_product.id;
      v_name:=v_product.name; v_price:=v_product.price_cents; v_item_type:='product';
      insert into public.order_items(order_id,product_id,product_name,quantity,unit_price_cents,item_type)
      values(v_order_id,v_product.id,v_name,v_qty,v_price,v_item_type);
    else
      select tt.id,tt.event_id,tt.name,tt.price_cents,tt.quantity_available,tt.max_per_order,tt.is_active,e.title,e.published,e.ticketed
      into v_ticket from public.event_ticket_types tt join public.events e on e.id=tt.event_id
      where tt.id=(v_line->>'ticket_type_id')::uuid for update of tt;
      if not found or not v_ticket.is_active or not v_ticket.published or not v_ticket.ticketed then
        raise exception 'A selected ticket type is unavailable' using errcode='P0002';
      end if;
      if v_qty>v_ticket.max_per_order or v_ticket.quantity_available<v_qty then
        raise exception 'Ticket quantity exceeds availability or per-order limit' using errcode='23514';
      end if;
      update public.event_ticket_types set quantity_available=quantity_available-v_qty,updated_at=now() where id=v_ticket.id;
      v_name:=v_ticket.name || ' — ' || v_ticket.title; v_price:=v_ticket.price_cents; v_item_type:='event_ticket';
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
revoke all on function public.create_yoco_order(uuid,text,jsonb) from public,anon,authenticated;
grant execute on function public.create_yoco_order(uuid,text,jsonb) to service_role;

create or replace function public.cancel_yoco_order(p_order_id uuid)
returns void language plpgsql security invoker set search_path = ''
as $function$
declare v_order public.orders%rowtype; v_item record;
begin
  select * into v_order from public.orders where id=p_order_id for update;
  if not found or v_order.payment_status in ('succeeded','refunded') then return; end if;
  if v_order.status<>'cancelled' then
    for v_item in select * from public.order_items where order_id=p_order_id loop
      if v_item.item_type='product' and v_item.product_id is not null then
        update public.products set stock_quantity=stock_quantity+v_item.quantity where id=v_item.product_id;
      elsif v_item.item_type='event_ticket' and v_item.ticket_type_id is not null then
        update public.event_ticket_types set quantity_available=quantity_available+v_item.quantity,updated_at=now() where id=v_item.ticket_type_id;
      end if;
    end loop;
    update public.orders set status='cancelled',payment_status='failed' where id=p_order_id;
  end if;
end;
$function$;
revoke all on function public.cancel_yoco_order(uuid) from public,anon,authenticated;
grant execute on function public.cancel_yoco_order(uuid) to service_role;

create or replace function public.complete_yoco_order(p_checkout_id text,p_payment_id text,p_amount integer,p_currency text)
returns jsonb language plpgsql security invoker set search_path = ''
as $function$
declare v_order public.orders%rowtype; v_item record; v_ticket_id uuid; v_issued integer:=0;
begin
  select * into v_order from public.orders where yoco_checkout_id=p_checkout_id for update;
  if not found then raise exception 'Order not found for checkout' using errcode='P0002'; end if;
  if v_order.total_cents<>p_amount or v_order.currency<>p_currency then raise exception 'Payment amount or currency does not match the order' using errcode='22023'; end if;
  if v_order.payment_status='succeeded' then return jsonb_build_object('order_id',v_order.id,'status','already_paid'); end if;
  if v_order.payment_status not in ('pending','unpaid') then raise exception 'Order is not payable' using errcode='55000'; end if;
  update public.orders set status='paid',payment_status='succeeded',yoco_payment_id=p_payment_id,paid_at=now() where id=v_order.id;
  if v_order.order_kind='event' then
    for v_item in select * from public.order_items where order_id=v_order.id and item_type='event_ticket' loop
      for i in 1..v_item.quantity loop
        v_ticket_id:=gen_random_uuid();
        insert into public.tickets(id,event_id,user_id,ticket_code_hash,order_id,ticket_type_id)
        values(v_ticket_id,v_item.event_id,v_order.user_id,'pending:'||v_ticket_id::text,v_order.id,v_item.ticket_type_id);
        v_issued:=v_issued+1;
      end loop;
    end loop;
  end if;
  return jsonb_build_object('order_id',v_order.id,'status','paid','tickets_issued',v_issued);
end;
$function$;
revoke all on function public.complete_yoco_order(text,text,integer,text) from public,anon,authenticated;
grant execute on function public.complete_yoco_order(text,text,integer,text) to service_role;
