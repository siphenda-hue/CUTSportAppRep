create table if not exists public.competition_honours (
  id uuid primary key default gen_random_uuid(),
  competition_id uuid not null references public.competitions(id) on delete cascade,
  winning_team text not null check (length(btrim(winning_team)) > 0),
  achievement_type text not null default 'champion' check (achievement_type in ('champion','runner_up','third_place','promotion','other')),
  season text,
  source_url text not null check (source_url ~* '^https?://'),
  approval_status text not null default 'pending' check (approval_status in ('pending','approved','rejected')),
  recorded_by uuid references auth.users(id) on delete set null,
  approved_by uuid references auth.users(id) on delete set null,
  approved_at timestamptz,
  review_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint competition_honours_approval_state_check check (
    (approval_status = 'approved' and approved_by is not null and approved_at is not null)
    or (approval_status <> 'approved' and approved_by is null and approved_at is null)
  )
);

create index if not exists competition_honours_competition_status_idx
  on public.competition_honours (competition_id, approval_status, season);

alter table public.competition_honours enable row level security;
revoke all on public.competition_honours from anon, authenticated;
grant select on public.competition_honours to anon, authenticated;
grant insert, update on public.competition_honours to authenticated;

drop policy if exists "Public read approved competition honours" on public.competition_honours;
create policy "Public read approved competition honours"
on public.competition_honours for select to anon, authenticated
using (
  approval_status = 'approved'
  and exists (
    select 1 from public.competitions c
    where c.id = competition_honours.competition_id
  )
);

drop policy if exists "Assigned sport admins submit competition honours" on public.competition_honours;
create policy "Assigned sport admins submit competition honours"
on public.competition_honours for insert to authenticated
with check (
  approval_status = 'pending'
  and recorded_by = (select auth.uid())
  and approved_by is null
  and approved_at is null
  and exists (
    select 1 from public.competitions c
    where c.id = competition_honours.competition_id
      and c.sport_id is not null
      and private.can_manage_sport(c.sport_id)
  )
);

drop policy if exists "Super admins review competition honours" on public.competition_honours;
create policy "Super admins review competition honours"
on public.competition_honours for update to authenticated
using ((select has_role('super_admin'::app_role)))
with check ((select has_role('super_admin'::app_role)));

drop policy if exists "Submitters and super admins read competition honours" on public.competition_honours;
create policy "Submitters and super admins read competition honours"
on public.competition_honours for select to authenticated
using (
  recorded_by = (select auth.uid())
  or (select has_role('super_admin'::app_role))
);
