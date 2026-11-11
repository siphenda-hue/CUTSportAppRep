begin;

-- User-confirmed identity: Jacobus Cloete and Jakobus Cloete are the same person.
update public.competition_player_statistics
set player_name = 'Jacobus Cloete',
    total_goals = coalesce(nullif(statistics->>'total_tries','')::integer,
                           nullif(statistics->>'tries','')::integer,
                           total_goals),
    statistics = (statistics - 'identity_resolution_note')
      || jsonb_build_object(
           'identity_resolution_status', 'user_confirmed_same_person',
           'identity_resolution_note', 'Canonical identity confirmed by the user: source spellings Jacobus Cloete and Jakobus Cloete refer to the same player.',
           'source_name_variants',
             case
               when player_name = 'Jakobus Cloete' then jsonb_build_array('Jakobus Cloete')
               when player_name = 'Jacobus Cloete' and statistics ? 'source_name_variants'
                 then (statistics->'source_name_variants') || jsonb_build_array('Jacobus Cloete')
               else jsonb_build_array('Jacobus Johannes Cloete')
             end
         )
where id in (
  '0d424621-3270-42c2-a0e5-45d1a00e1860',
  'a188e152-9149-43a2-ba82-dc20ebdd6413',
  'bca51629-f5ae-405a-bf1d-63eec78fab13'
);

-- User-confirmed identity: Jan Bessenger, Jan-Hendrik Bessenger and Jan Hendrik Bessenger
-- are one player. Normalize display name while retaining report spellings.
update public.competition_player_statistics
set player_name = 'Jan Bessenger',
    total_goals = coalesce(nullif(statistics->>'total_tries','')::integer,
                           nullif(statistics->>'tries','')::integer,
                           total_goals),
    statistics = (statistics - 'identity_resolution_note')
      || jsonb_build_object(
           'identity_resolution_status', 'user_confirmed_same_person',
           'identity_resolution_note', 'Canonical identity confirmed by the user: Jan Bessenger, Jan-Hendrik Bessenger and Jan Hendrik Bessenger refer to the same player.',
           'source_name_variants',
             case
               when player_name = 'Jan Bessenger' then coalesce(statistics->'source_name_variants', '[]'::jsonb) || jsonb_build_array('Jan Hendrik Bessenger')
               when player_name = 'Jan-Hendrik Bessenger' then jsonb_build_array('Jan-Hendrik Bessenger')
               else jsonb_build_array('Jan Hendrik Bessenger')
             end
         )
where id in (
  'd7b3fa04-e356-420a-bed6-3649248a2962',
  '7661d211-3076-4815-85f7-09286a917b1d',
  '22b519ce-ea50-46e5-b971-cc0aa4b8b724'
);

commit;