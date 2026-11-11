-- Enrich the 2018 Varsity Cricket record with verified tournament context.
-- Source: UP-TuksCricket 2017/2018 Season Report, Issue 1.
-- The source confirms the CUT group-stage loss with a bonus point but does
-- not publish CUT's scorecard, player statistics, or final tournament placing.

update public.competitions
set description = 'CUT Cricket made its Varsity Cricket debut in Potchefstroom in early February 2018 after qualifying through the 2017 USSA B Section title and promotion. UP-Tuks defeated CUT in the group stage with a bonus point. UP-Tuks finished second on the group-stage log after winning five matches (including against CUT) and losing to NWU-Pukke and Maties, then won the tournament final against NWU-Pukke by five wickets with two balls remaining. The available contemporary Tuks season report does not publish CUT’s scorecard, individual match score, player statistics or final placing; none are asserted here. Source: https://www.up.ac.za/media/shared/277/ZP_Files/2018/newsletters/2018-newsletter-issue-1.zp148184.pdf'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2018f5a00001';
