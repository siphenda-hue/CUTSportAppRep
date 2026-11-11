-- User-confirmed identity alias: Pule Thekiso and Pule Macdonald Thekiso
-- are the same CUT Varsity Football player. Preserve season rows and goals.
update public.competition_player_statistics
set
  player_name = 'Pule Macdonald Thekiso',
  statistics = coalesce(statistics, '{}'::jsonb)
    || jsonb_build_object(
      'source_name_variants', jsonb_build_array('Pule Thekiso'),
      'identity_resolution_status', 'user_confirmed_same_person',
      'identity_resolution_note', 'User confirmed Pule Thekiso and Pule Macdonald Thekiso are the same player; canonical name is Pule Macdonald Thekiso.'
    )
where id = 'db311a1a-a539-4d4c-b56a-59661ffaf432'
  and competition_id = 'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'
  and player_name = 'Pule Thekiso';
