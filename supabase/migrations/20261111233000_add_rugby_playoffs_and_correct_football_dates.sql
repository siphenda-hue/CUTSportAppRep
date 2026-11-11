do $$
declare c2023 uuid; c2024 uuid;
begin
  select id into c2023 from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2023' limit 1;
  select id into c2024 from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2024' limit 1;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2023,'2023-vc-promotion-relegation-cut-nmu','2023-04-17 15:00:00+02','CUT Ixias','NMU Madibaz',91,10,'completed','Promotion/Relegation Play-off','Fanie du Toit Sports Ground, Potchefstroom','https://www.news24.com/sport/rugby/varsitycup/ixias-hold-onto-varsity-cup-spot-after-dominating-madibaz-in-promotionrelegation-play-off-20230417','{"result":"CUT retained Varsity Cup status for 2024","tries_scored":13}'),
  (c2024,'2024-vc-promotion-relegation-cut-nmu','2024-04-22 00:00:00+02','CUT Ixias','NMU Madibaz',64,16,'completed','Promotion/Relegation Play-off','South Africa','https://www.varsitycup.co.za/news/promotion-relegation-shake-up-in-the-2025-fnb-varsity-cup-and-varsity-shield','{"result":"CUT retained Varsity Cup status for 2025"}')
  on conflict (competition_id,source_match_id) do update set
   starts_at=excluded.starts_at,home_team=excluded.home_team,away_team=excluded.away_team,
   home_score=excluded.home_score,away_score=excluded.away_score,match_status=excluded.match_status,
   match_round=excluded.match_round,venue=excluded.venue,source_url=excluded.source_url,
   statistics=excluded.statistics,source_checked_at=now(),updated_at=now();

  update public.competition_matches
  set starts_at='2025-11-16 00:00:00+02',venue='Clive Solomon Stadium',
      source_url='https://novanews.co.za/bloemnewsexpress/team-hoping-to-have-lady-luck-on-their-side-in-an-ambitious-bid-for-promotion/'
  where source_match_id='2025-fs-sasol-provincial-final-ixias-napoli';

  update public.competition_matches
  set starts_at='2024-09-08 00:00:00+02',venue='Bloemfontein'
  where source_match_id='2024-fs-sasol-provincial-final-ixias-kovsies';

  update public.competitions
  set description=description||' The team was relegated to the FNB Varsity Shield for 2027 after finishing last in 2026.'
  where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2026';
end $$;