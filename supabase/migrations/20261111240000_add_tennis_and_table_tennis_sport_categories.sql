-- Register inactive sport categories for archival/history only.
-- Tennis and Table Tennis are not currently offered by CUT Sport.
-- They remain in the database for historical continuity but are hidden
-- from public sport-code listings through is_active = false.

insert into public.sports (name, slug, description, is_active, display_order)
values
  (
    'Tennis',
    'tennis',
    'Archived category: CUT does not currently offer Tennis as an active sporting code.',
    false,
    12
  ),
  (
    'Table Tennis',
    'table-tennis',
    'Archived category: CUT does not currently offer Table Tennis as an active sporting code.',
    false,
    13
  )
on conflict (name) do update
set
  description = excluded.description,
  is_active = false,
  display_order = excluded.display_order;

-- The app's official sport-code label is Football.
update public.sports
set
  name = 'Football',
  slug = 'football',
  description = 'Association football. CUT teams compete in men’s and women’s football programmes and university competitions.',
  is_active = true
where slug = 'football' or name = 'Football';
