create index if not exists athlete_messages_parent_message_idx on public.athlete_messages (parent_message_id) where parent_message_id is not null;
