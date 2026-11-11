-- Add primary-source corroboration for CUT's 2019 Varsity Sport Cricket participation.
-- The direct database update was applied and verified separately.
update public.competitions
set description = 'CUT Cricket participated in the 2019 Varsity Sport Cricket Competition hosted at North-West University in Potchefstroom from 1–7 September 2019. CUT’s 2019 Annual Report independently confirms the team’s participation. A University of Pretoria report confirms UP-Tuks defeated CUT by six wickets in a group-stage match; the accessible report does not provide CUT’s scorecard or exact match date. No final placing or individual player statistics are asserted. Sources: https://www.cut.ac.za/publications (Annual Report 2019, section 6.9.4, printed page 110); https://www.up.ac.za/cricket/news/post_2837442-assupol-tukscricket-assupol-tuks-on-track-to-defend-their-varsity-cricket-title'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2019f5a00001';
