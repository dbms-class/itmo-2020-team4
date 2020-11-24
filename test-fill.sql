INSERT INTO Sport (name)
SELECT unnest(ARRAY['swimming', 'running', 'football', 'basketball', 'tennis', 'poker', 'chess']);

INSERT INTO Country (name)
SELECT unnest(ARRAY['Russia', 'Ukraine', 'Brazil', 'Peru', 'Honduras', 'Chile', 'Kazakhstan']);

INSERT INTO FacilityFunction (name)
SELECT unnest(ARRAY['restaurant', 'household', 'pool', 'track', 'stadium', 'pitch']);

WITH Names AS (
  SELECT unnest(ARRAY[
      'Pooshkina', 'Kolotooshkina', 'Lenina', 'Uncanny'
  ]) AS name
)
INSERT INTO Address(street_name, house_number)
SELECT name, (3+random()*20)::INT
FROM Names;

INSERT INTO Facility(address_id, function_id) VALUES (1,3);
INSERT INTO Facility(address_id, function_id) VALUES (1,2);
INSERT INTO Facility(address_id, function_id) VALUES (2,2);

INSERT INTO Delegation(director_name, director_phone, headquarters_id, country) 
VALUES ('Bond', '+79996664223', 2, 2);
INSERT INTO Delegation(director_name, director_phone, headquarters_id, country)
VALUES ('Jane', '+79996662342', 2, 3);

INSERT INTO Volunteer (name, phone_number) VALUES ('SomeVolunteer','+4546667772288');

INSERT INTO 
Sportsman(delegation_id, facility_id, volunteer_id, name, gender, height, weight, age)
VALUES (1, 1, 1000000, 'Phelps', true, 175, 80, 30);

INSERT INTO 
Sportsman(delegation_id, facility_id, volunteer_id, name, gender, height, weight, age)
VALUES (1, 1, 1000000, 'Phelps Brother', true, 175, 80, 30);

INSERT INTO 
Sportsman(delegation_id, facility_id, volunteer_id, name, gender, height, weight, age)
VALUES (1, 1, 1000000, 'Phelps Father', true, 175, 80, 30);

INSERT INTO SportFacility(facility, sport_id) VALUES (1, 1);

INSERT INTO Competition(facility, sport_id, time_, n_level, n_group) 
VALUES (1, 1, '2020-12-30 14:00:00', 1, 1);

INSERT INTO CompetitionWithMedals(competition_id) VALUES (1);


-- All three in final heh
INSERT INTO 
CompetitionParticipation(sportsman_card, competition_id, final_pos)
VALUES (1, 1, 2);
INSERT INTO 
CompetitionParticipation(sportsman_card, competition_id, final_pos)
VALUES (2, 1, 3);
INSERT INTO 
CompetitionParticipation(sportsman_card, competition_id, final_pos)
VALUES (3, 1, 1);

INSERT INTO Transport (registration, capacity) VALUES ('A321TT179',3);
