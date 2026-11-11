update public.competition_player_statistics
set statistics = jsonb_set(
  statistics,
  '{source_name_variants}',
  '["Jan Hendrik Bessenger"]'::jsonb,
  true
)
where id = 'd7b3fa04-e356-420a-bed6-3649248a2962'
  and player_name = 'Jan Bessenger'
  and competition_id = '6c5ed0f1-9c0f4bbf-910e-e40ccc3772ac';