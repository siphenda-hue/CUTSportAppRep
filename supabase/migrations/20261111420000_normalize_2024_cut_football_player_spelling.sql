update public.competition_player_statistics
set player_name = 'Nkosingiphile Lubisi',
    statistics = (statistics - 'identity_resolution_note')
      || jsonb_build_object(
           'source_name_variants', jsonb_build_array('Nkosingiphile Libubisi'),
           'identity_resolution_status', 'source_confirmed_spelling_variant',
           'identity_resolution_note', 'The 2024 Varsity Football Round 3 report uses Libubisi in its scorer line but lists the CUT player as Nkosingiphile Lubisi in the same match squad. Canonical spelling retained as Lubisi; source spelling preserved as an alias.'
         )
where id = '9e941554-a538-4005-a115-1ba28f0eb9a6'
  and player_name = 'Nkosingiphile Libubisi';