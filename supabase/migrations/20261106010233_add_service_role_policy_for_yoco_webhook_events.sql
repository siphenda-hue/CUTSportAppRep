create policy "Service role manages Yoco webhook events"
on public.yoco_webhook_events
for all to service_role
using (true)
with check (true);
