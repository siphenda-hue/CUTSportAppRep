-- Reconcile the 2025 USSA Cricket A Week CUT campaign with published match reporting.
-- CUT finished fourth in Group B after losing the third-place play-off to Madibaz B.
-- This is a Group B placing, not an asserted overall tournament ranking.
update public.competitions
set description = 'CUT Cricket participated in the USSA A Week hosted in Stellenbosch from 1–5 December 2025. Published results record four Group B matches: a 17-run loss to ETA, 64-run wins over Varsity College and TUT, and a four-wicket loss to UCT. CUT then lost the Group B third-place play-off to Madibaz B by 186 runs, finishing fourth in Group B. This is not presented as an overall tournament placing. Full innings totals and individual player scorecard figures remain unavailable from the accessible published report.'
where id = 'b6bdca69-c0bf-445b-9089-a467b6f357dd';
