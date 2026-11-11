do $$
declare r2025 uuid; f2025 uuid;
begin
  select id into r2025 from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2025' limit 1;
  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
  values
  (r2025,'Maties','League Table',1,7,6,0,1,248,131,117,6,30,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'UP Tuks','League Table',2,7,5,0,2,254,183,71,6,27,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'UCT Ikey Tigers','League Table',3,7,5,0,2,273,180,93,6,26,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'UFS Shimlas','League Table',4,7,4,0,3,249,258,-9,6,22,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'NWU Eagles','League Table',5,7,4,0,3,324,161,163,5,21,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'CUT Ixias','League Table',6,7,3,0,4,140,300,-160,3,11,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'UJ','League Table',7,7,1,0,6,164,265,-101,5,9,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now()),
  (r2025,'Wits','League Table',8,7,0,0,7,147,321,-174,3,5,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now())
  on conflict (competition_id,team_name,group_name) do update set
   position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
   scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
   bonus_points=excluded.bonus_points,points=excluded.points,source_url=excluded.source_url,
   source_checked_at=now(),updated_at=now();

  update public.competition_team_statistics
  set statistics='{"matches_played":7,"on_field_wins":3,"on_field_losses":4,"points_for":140,"points_against":300,"points_difference_calculated_from_results":-160,"published_points_difference":-170,"published_bonus_points":3,"final_log_position":6,"final_log_points":11,"log_points_deducted":5,"sanction":"Ineligible player in Round 1","source_note":"The published 2025 log has a points-difference arithmetic inconsistency for CUT: 140 points for minus 300 against calculates to -160, while the table prints -170. The displayed standings use the calculated -160; the published -170 is retained here."}'::jsonb
  where competition_id=r2025 and team_name='CUT Ixias';

  select id into f2025 from public.competitions where sport_id='4c1ccd6f-3965-422a-ad25-19aaa2797f23' and name='Varsity Football Men' and season='2025' limit 1;
  update public.competition_standings
  set group_name='League Table',position=7,source_url='https://www.soccermag.com/varsity-football/everything-that-happened-in-varsity-football-2025/',source_checked_at=now()
  where competition_id=f2025 and team_name='CUT';
end $$;