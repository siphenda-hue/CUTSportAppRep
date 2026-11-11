drop policy if exists "Athletes and assigned staff can send messages" on public.athlete_messages;
create policy "Athletes and assigned staff can send messages"
on public.athlete_messages for insert to authenticated
with check (
  sender_id = (select auth.uid())
  and exists (
    select 1 from public.athletes a
    where a.id = athlete_messages.athlete_id
      and a.profile_id is not null
      and (
        (a.profile_id = (select auth.uid())
          and athlete_messages.recipient_id <> (select auth.uid())
          and private.is_message_admin_for_sport(athlete_messages.recipient_id, a.sport_id))
        or (athlete_messages.recipient_id = a.profile_id
          and private.can_manage_sport(a.sport_id))
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
