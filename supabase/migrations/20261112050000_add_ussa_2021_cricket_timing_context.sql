-- Add corroborating tournament timing context to CUT's 2021 USSA Cricket record.
-- CUT Annual Report categorises participation under December 2021.
-- UFH News (February 2022) says the event was held in the preceding month at NMU,
-- implying January 2022. Preserve the discrepancy and do not infer CUT match results.
UPDATE public.competitions
SET description = description || E'\n\nAdditional tournament context: A University of Fort Hare report published in February 2022 describes the USSA A Cricket tournament as having taken place at Nelson Mandela University in the preceding month, indicating the event was held in January 2022 despite the CUT annual report categorising its participation under December 2021. UFH reports that COVID-19 and injuries disrupted the planned week. This source does not report CUT results or player statistics. Source: UFH News, February 2022, pages 30–31: https://libdspace.ufh.ac.za/server/api/core/bitstreams/79d8575d-36ca-4e96-a24a-8bd9a97da0b0/content'
WHERE id = 'a43e3a9b-7c4e-4d7e-9f7c-2021c5a00001'
AND position('Additional tournament context: A University of Fort Hare report' IN description) = 0;
