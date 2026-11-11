-- Enrich 2022 CUT Ixias Varsity Cup match scorer metadata from published match reports.
update public.competition_matches
set statistics=coalesce(statistics,'{}'::jsonb)||jsonb_build_object(
 'scorers',jsonb_build_object(
  'NMU Madibaz',jsonb_build_array('Warwick Griffin','Kyle Cyster','Kyle Cyster','Kyle Cyster','Khakalethu Bophi'),
  'CUT Ixias',jsonb_build_array('Tiaan Drotske','Sisipho Nofuya','Christiaan Venter','Zinedine Booysen')
 ),
 'scoring_source','https://iol.co.za/sport/rugby/2022-03-07-hat-trick-hero-kyle-cyster-helps-madibaz-beat-ixias-36-26-in-varsity-cup/',
 'scoring_data_status','Published match report; try scorers identified'
)
where id='c003d2c3-7641-4d85-a860-8eeef769d610';

update public.competition_matches
set statistics=coalesce(statistics,'{}'::jsonb)||jsonb_build_object(
 'scorers',jsonb_build_object(
  'Maties',jsonb_build_array('Sean Swart','Sean Swart','Sibabalwe Xamalashe','Sibabalwe Xamalashe','Brendan Venter','Marcqiewn Titus','Nevaldo Fleurs'),
  'CUT Ixias',jsonb_build_array('Luvuyo Ndevu','Luvuyo Ndevu','Septimus Derkesen')
 ),
 'scoring_source','https://www.cut.ac.za/news/varsity-cup-fnb-ixias-left-with-everest-to-cl',
 'scoring_data_status','CUT official match report; try scorers identified'
)
where id='176337c0-b4ca-481f-9218-0b7173d938ce';

update public.competition_matches
set statistics=coalesce(statistics,'{}'::jsonb)||jsonb_build_object(
 'scorers',jsonb_build_object(
  'UP Tuks',jsonb_build_array('Ethan Burger','Divan Venter','Divan Venter','Kabelo Mokoena','Stephen Smit','Tharquinn Manuel','Werner Fourie','Orateng Koikanyang','Mihlali Stamper'),
  'CUT Ixias',jsonb_build_array('Jan Kotze','Matthew Sekele')
 ),
 'scoring_source','https://www.up.ac.za/high-performance-centre/news/post_3054681-tuksrugby-nine-tries-scored-by-tuks-for-a-bonus-point-win-against-cut-in-round-7-of-the-2022-fnb-varsity-cup-season',
 'scoring_data_status','University of Pretoria official match report; try scorers identified'
)
where id='faadbf8d-d91b-459c-aff3-16e395747153';