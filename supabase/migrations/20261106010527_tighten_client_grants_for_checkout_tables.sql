revoke all on public.orders, public.order_items, public.tickets from anon, authenticated;
grant select on public.orders, public.order_items, public.tickets to authenticated;
revoke insert, update, delete, truncate, references, trigger
on public.products from anon, authenticated;
