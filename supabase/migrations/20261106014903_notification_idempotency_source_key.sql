alter table public.notifications add column if not exists source_key text;

create unique index if not exists notifications_source_key_unique_idx
on public.notifications(source_key)
where source_key is not null;
