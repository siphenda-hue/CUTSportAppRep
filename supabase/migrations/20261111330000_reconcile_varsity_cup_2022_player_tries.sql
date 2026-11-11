-- Reconcile 2022 CUT Varsity Cup player try counts with seven published match reports.
-- Counts remain partial-season figures, not final season totals.
update public.competition_player_statistics
set statistics = statistics || jsonb_build_object(
 'tries', case player_name
  when 'Jan Kotze' then 3
  when 'Luvuyo Ndevu' then 4
  when 'Matthew Sekele' then 4
  when 'Septimus Derkesen' then 3
  when 'Tiaan Drotske' then 2
  else (statistics->>'tries')::int end,
 'verified_tries_in_available_match_reports', case player_name
  when 'Jan Kotze' then 3
  when 'Luvuyo Ndevu' then 4
  when 'Matthew Sekele' then 4
  when 'Septimus Derkesen' then 3
  when 'Tiaan Drotske' then 2
  else (statistics->>'tries')::int end,
 'match_report_scope','CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT; NMU v CUT; CUT v Maties; UP Tuks v CUT',
 'season_total_complete',false
),
source_checked_at=now(),updated_at=now()
where competition_id='ecfa7e4b-cc49-4e78-8ada-280701fa3ff6'
and team_name='CUT Ixias'
and player_name in ('Jan Kotze','Luvuyo Ndevu','Matthew Sekele','Septimus Derkesen','Tiaan Drotske');

insert into public.competition_player_statistics
(competition_id,player_name,team_name,total_goals,source_url,statistics)
select 'ecfa7e4b-cc49-4e78-8ada-280701fa3ff6',v.player_name,'CUT Ixias',0,v.source_url,
 jsonb_build_object('tries',v.tries,'verified_tries_in_available_match_reports',v.tries,
 'match_report_scope',v.scope,'season_total_complete',false)
from (values
 ('Sisipho Nofuya',1,'https://iol.co.za/sport/rugby/2022-03-07-hat-trick-hero-kyle-cyster-helps-madibaz-beat-ixias-36-26-in-varsity-cup/','NMU v CUT'),
 ('Christiaan Venter',1,'https://iol.co.za/sport/rugby/2022-03-07-hat-trick-hero-kyle-cyster-helps-madibaz-beat-ixias-36-26-in-varsity-cup/','NMU v CUT'),
 ('Zinedine Booysen',1,'https://iol.co.za/sport/rugby/2022-03-07-hat-trick-hero-kyle-cyster-helps-madibaz-beat-ixias-36-26-in-varsity-cup/','NMU v CUT')
) as v(player_name,tries,source_url,scope)
where not exists (
 select 1 from public.competition_player_statistics p
 where p.competition_id='ecfa7e4b-cc49-4e78-8ada-280701fa3ff6'
 and p.team_name='CUT Ixias' and p.player_name=v.player_name
);