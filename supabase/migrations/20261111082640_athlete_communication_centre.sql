create table if not exists public.athlete_messages (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.athletes(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  parent_message_id uuid references public.athlete_messages(id) on delete set null,
  subject text not null,
  body text not null,
  message_type text not null default 'general',
  read_at timestamptz,
  created_at timestamptz not null default now(),
  constraint athlete_messages_not_self check (sender_id <> recipient_id),
  constraint athlete_messages_subject_length check (char_length(btrim(subject)) between 1 and 160),
  constraint athlete_messages_body_length check (char_length(btrim(body)) between 1 and 5000),
  constraint athlete_messages_type_check check (message_type in ('general','correction','announcement'))
);

create index if not exists athlete_messages_athlete_created_idx on public.athlete_messages (athlete_id, created_at desc);
create index if not exists athlete_messages_recipient_unread_idx on public.athlete_messages (recipient_id, created_at desc) where read_at is null;
create index if not exists athlete_messages_sender_created_idx on public.athlete_messages (sender_id, created_at desc);

alter table public.athlete_messages enable row level security;

drop policy if exists "Message participants can read" on public.athlete_messages;
create policy "Message participants can read" on public.athlete_messages for select to authenticated
using ((select auth.uid()) in (sender_id, recipient_id));

drop policy if exists "Message recipients can mark read" on public.athlete_messages;
create policy "Message recipients can mark read" on public.athlete_messages for update to authenticated
using (recipient_id = (select auth.uid())) with check (recipient_id = (select auth.uid()));

drop policy if exists "Athletes and assigned staff can send messages" on public.athlete_messages;
create policy "Athletes and assigned staff can send messages" on public.athlete_messages for insert to authenticated
with check (
 sender_id = (select auth.uid())
 and exists (
  select 1 from public.athletes a
  where a.id = athlete_messages.athlete_id and a.profile_id is not null
  and (
   (a.profile_id = (select auth.uid()) and athlete_messages.recipient_id <> (select auth.uid())
    and private.is_message_admin_for_sport(athlete_messages.recipient_id,a.sport_id))
   or (athlete_messages.recipient_id = a.profile_id and private.can_manage_sport(a.sport_id))
  )
 )
 and (
  athlete_messages.parent_message_id is null
  or exists (
   select 1 from public.athlete_messages parent
   where parent.id = athlete_messages.parent_message_id
    and parent.athlete_id = athlete_messages.athlete_id
    and (
     (parent.sender_id = (select auth.uid()) and parent.recipient_id = athlete_messages.recipient_id)
     or (parent.recipient_id = (select auth.uid()) and parent.sender_id = athlete_messages.recipient_id)
    )
  )
 )
);

revoke all on table public.athlete_messages from public, anon, authenticated;
grant select on table public.athlete_messages to authenticated;
grant insert (athlete_id,sender_id,recipient_id,parent_message_id,subject,body,message_type) on public.athlete_messages to authenticated;
grant update (read_at) on public.athlete_messages to authenticated;
grant all on table public.athlete_messages to service_role;

create or replace function private.notify_athlete_message()
returns trigger language plpgsql security definer set search_path = ''
as $function$
declare
 v_recipient_is_athlete boolean;
 v_title text;
 v_action_url text;
begin
 select exists(select 1 from public.athletes a where a.id=new.athlete_id and a.profile_id=new.recipient_id)
 into v_recipient_is_athlete;
 v_title := case when new.message_type='correction' then 'New athlete correction guidance'
   when new.message_type='announcement' then 'New CUT Sport message'
   else 'New message from CUT Sport' end;
 if not v_recipient_is_athlete then v_title := 'New message from an athlete'; end if;
 v_action_url := case when v_recipient_is_athlete then '/messages' else '/admin/messages' end;
 insert into public.notifications(user_id,title,body,source_key,category,action_url,related_record_type,related_record_id)
 values(new.recipient_id,v_title,new.subject || ': ' || left(new.body,500),
   'athlete-message:' || new.id::text,'athlete_message',v_action_url,'message',new.id)
 on conflict (source_key) where source_key is not null do nothing;
 return new;
end;
$function$;
revoke all on function private.notify_athlete_message() from public, anon, authenticated;
drop trigger if exists athlete_messages_notify_recipient on public.athlete_messages;
create trigger athlete_messages_notify_recipient after insert on public.athlete_messages
for each row execute function private.notify_athlete_message();
