-- Add the official CUT Annual Report 2018 as a corroborating participation source.
-- The report confirms that CUT Cricket played in Varsity Cricket 2018 and the USSA Cricket Tournament.
-- It does not establish additional scores, player statistics, or tournament placing.
UPDATE public.competitions
SET description = description || E'\n\nCUT Annual Report 2018 independently confirms that the Cricket Team played in the Varsity Cricket 2018 competition and the USSA Cricket Tournament. This official institutional source confirms participation only and does not add unreported scorecards or player statistics. Source: https://cms.cut.ac.za/Files/Froala/130dfb81-99ad-46c6-8c67-b9d947f8ac58.pdf'
WHERE id IN (
  'a43e3a9b-7c4e-4d7e-9f7c-2018f5a00001',
  'a43e3a9b-7c4e-4d7e-9f7c-2018c5a00001'
)
AND position('CUT Annual Report 2018 independently confirms' IN description) = 0;
