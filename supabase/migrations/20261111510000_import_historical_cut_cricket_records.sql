-- Add verified historical CUT Cricket competition achievements.
-- Sources: CUT annual reports (2017, 2021 and 2022); Varsity Sport's
-- 2022 tournament recap. Only published team-level facts are recorded.

insert into public.competitions (id,sport_id,name,season,start_date,end_date,venue,description,status)
values
('a43e3a9b-7c4e-4d7e-9f7c-2017c5a00001','481726ef-be80-4f8e-a0c4-c5f8c41a0f74','USSA Cricket Tournament','2017','2017-10-30','2017-10-30','Pretoria, Gauteng, South Africa','CUT Cricket won the USSA Cricket B Section tournament in Pretoria on 30 October 2017 and earned promotion to the A Section for 2018. No match scores or individual player statistics are asserted.','completed'),
('a43e3a9b-7c4e-4d7e-9f7c-2021c5a00001','481726ef-be80-4f8e-a0c4-c5f8c41a0f74','USSA Cricket Tournament','2021',null,null,'Gqeberha, Eastern Cape, South Africa','CUT Cricket participated in the USSA Cricket Tournament held in Gqeberha in December 2021. The available CUT annual report confirms participation but does not state final placing, match results or player statistics.','completed'),
('a43e3a9b-7c4e-4d7e-9f7c-2022c5a00001','481726ef-be80-4f8e-a0c4-c5f8c41a0f74','Mangaung Cricket Association League','2021/22',null,'2022-03-31','Mangaung, Free State, South Africa','The CUT annual report records CUT 1 finishing first overall and CUT 2 finishing fourth overall in the Mangaung Cricket Association League, which concluded at the end of March 2022. No match results or player statistics are asserted.','completed'),
('a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001','481726ef-be80-4f8e-a0c4-c5f8c41a0f74','Varsity Sport Cricket Tournament','2022','2022-10-03','2022-10-05','University of Pretoria (UP-Tuks), Pretoria, Gauteng, South Africa','CUT Cricket participated in the 2022 Varsity Sport Cricket Tournament at UP-Tuks and reached the semi-finals. The available CUT annual report confirms the semi-final achievement; no match scores or player statistics are asserted.','completed')
on conflict (id) do update set
 sport_id=excluded.sport_id,name=excluded.name,season=excluded.season,
 start_date=excluded.start_date,end_date=excluded.end_date,venue=excluded.venue,
 description=excluded.description,status=excluded.status;
