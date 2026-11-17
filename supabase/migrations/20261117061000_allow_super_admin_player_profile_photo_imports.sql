-- Allow the existing CUT Sport super-admin workflow to create canonical player profiles.
-- Photo objects are uploaded to the existing public player-profile-photos bucket.
-- Existing storage RLS already restricts profile-photo uploads to super admins.

grant select, insert, update on table public.player_profiles to authenticated;

create policy "Super admins insert player profiles"
on public.player_profiles
for insert
to authenticated
with check (has_role('super_admin'::app_role));
