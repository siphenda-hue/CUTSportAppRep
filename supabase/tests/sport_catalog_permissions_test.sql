-- Static security regression checks for sport catalogue administration.
-- Run with psql against a test project after applying the migration.
-- Role/assignment behavior still requires dedicated authenticated test users.

do $$
begin
  if not (select c.relrowsecurity from pg_class c where c.oid='public.sports'::regclass) then
    raise exception 'RLS is not enabled on sports';
  end if;
  if not has_table_privilege('anon','public.sports','select') then
    raise exception 'Anonymous public sport directory reads were removed';
  end if;
  if has_table_privilege('anon','public.sports','insert')
    or has_table_privilege('anon','public.sports','update')
    or has_table_privilege('anon','public.sports','delete') then
    raise exception 'anon unexpectedly has sport catalogue write privileges';
  end if;
  if not has_table_privilege('authenticated','public.sports','insert')
    or not has_table_privilege('authenticated','public.sports','update') then
    raise exception 'Authenticated sport administrators lack required DML grants';
  end if;
  if has_table_privilege('authenticated','public.sports','delete')
    or has_table_privilege('authenticated','public.sports','truncate')
    or has_table_privilege('authenticated','public.sports','references')
    or has_table_privilege('authenticated','public.sports','trigger') then
    raise exception 'Authenticated role has excessive sport catalogue privileges';
  end if;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='sports' and policyname='Sports public read' and cmd='SELECT') then
    raise exception 'Public sport read policy is missing';
  end if;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='sports' and policyname='Assigned sport admins read managed sports'
    and cmd='SELECT') then
    raise exception 'Assigned sport administrator read policy is missing';
  end if;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='sports' and policyname='Super admins create sports'
    and cmd='INSERT') then
    raise exception 'Super administrator sport create policy is missing';
  end if;
  if not exists (select 1 from pg_policies where schemaname='public'
    and tablename='sports' and policyname='Assigned sport admins update sports'
    and cmd='UPDATE') then
    raise exception 'Assigned sport administrator update policy is missing';
  end if;
  if exists (select 1 from pg_policies where schemaname='public'
    and tablename='sports' and cmd='DELETE') then
    raise exception 'A sport DELETE policy exists; catalogue retirement must use is_active';
  end if;
end;
$$;
