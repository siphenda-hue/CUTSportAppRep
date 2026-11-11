-- Add the CUT Tennis and Table Tennis sport categories.
-- Descriptions reflect CUT's published sport participation information.
-- No competition results or athlete statistics are created by this migration.

insert into public.sports (name, slug, description, is_active, display_order)
values
  (
    'Tennis',
    'tennis',
    'CUT students compete in the Free State 2nd League, with a selected team participating in the USSA Tennis Tournament. CUT also runs a weekly tennis development coaching programme.',
    true,
    12
  ),
  (
    'Table Tennis',
    'table-tennis',
    'CUT men and women compete in the Free State Table Tennis League.',
    true,
    13
  )
on conflict (name) do update
set
  description = excluded.description,
  is_active = true,
  display_order = excluded.display_order;
