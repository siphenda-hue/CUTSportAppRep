-- Add the official CUT Annual Report 2022 source to the 2021/22 MCA Cricket record.
-- The report states the league concluded at the end of March 2022:
-- CUT 1 finished first overall and CUT 2 finished fourth overall.
UPDATE public.competitions
SET description = description || E'\n\nOfficial source: CUT Annual Report 2022, which states that the Mangaung Cricket Association League concluded at the end of March 2022, with CUT 1 first overall and CUT 2 fourth overall. Source: https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf'
WHERE id = 'a43e3a9b-7c4e-4d7e-9f7c-2022c5a00001'
AND position('Official source: CUT Annual Report 2022' IN description) = 0;
