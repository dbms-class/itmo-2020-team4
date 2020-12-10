INSERT INTO Sport (name)
SELECT unnest(ARRAY['Running 1500m women', 'Running 1500m men', 'Running 800m men', 'Running 800m women',
    'discus throw men', 'discus throw women',
    'Team Artistic Swimming', 'sabre team men', 'sabre team women', 'sabre individual women',
    'sabre individual men', 'Cycling Road race men', 'Cycling Road race women', 'Judo half-heavyweight women',
    'Swimming 400m freestyle men', 'Swimming 200m butterfly men', 'Swimming 100m butterfly women']);

INSERT INTO FacilityFunction (name)
SELECT unnest(ARRAY['pool', 'gym', 'household', 'track', 'stadium', 'pitch', 'restaurant']);

WITH Names AS (
  SELECT unnest(ARRAY[
      'Pooshkina', 'Kolotooshkina', 'Lenina', 'Stalina', 'Pobedy', 'Bonch-Bruevicha', 'Soni Krivoi',
      'Engelsa', 'Pavlika Morozova', 'Gagarina', 'Rozhdestvenskaja', 'Sovetskaja', 'Gorkogo'
  ]) AS name
)

INSERT INTO Address(street_name, house_number)
SELECT name, (3+random()*20)::INT
FROM Names;

INSERT INTO Facility(address_id, function_id) VALUES (1,1);
INSERT INTO Facility(address_id, function_id) VALUES (2,2);
INSERT INTO Facility(address_id, function_id) VALUES (3,3);
INSERT INTO Facility(address_id, function_id) VALUES (4,6);
INSERT INTO Facility(address_id, function_id) VALUES (5,5);
INSERT INTO Facility(address_id, function_id) VALUES (6,4);
INSERT INTO Facility(address_id, function_id) VALUES (7,1);
INSERT INTO Facility(address_id, function_id) VALUES (7,2);
INSERT INTO Facility(address_id, function_id) VALUES (7,3);

INSERT INTO Delegation(director_name, director_phone, country_name)
VALUES ('James Joyce', '+79996661337', 'Ireland');
INSERT INTO Delegation(director_name, director_phone, country_name)
VALUES ('John Cena', '+79997771337', 'USA');
INSERT INTO Delegation(director_name, director_phone, country_name)
VALUES ('Jorge Francisco Isidoro Luis Borges Acevedo', '+79995551337', 'Argentina');
INSERT INTO Delegation(director_name, director_phone, country_name)
VALUES ('Vladimir Georgiyevich Sorokin', '+79994441337', 'Russia');
INSERT INTO Delegation(director_name, director_phone, country_name)
VALUES ('Bono', '+79993331337', 'Australia');

INSERT INTO Volunteer (name, phone_number) VALUES ('Volunteer 4','+4546667772288');
INSERT INTO Volunteer (name, phone_number) VALUES ('Volunteer 8','+4546667773388');
INSERT INTO Volunteer (name, phone_number) VALUES ('Volunteer 16','+4546667752288');
INSERT INTO Volunteer (name, phone_number) VALUES ('Volunteer 23','+4514667772288');
INSERT INTO Volunteer (name, phone_number) VALUES ('Volunteer 42','+4546623772288');

INSERT INTO Sportsman(country_name, volunteer_id, name) VALUES ('USA', 1000001, 'Michael Fred Phelps II');
INSERT INTO Sportsman(country_name, volunteer_id, name) VALUES ('USA', 1000002, 'Michael Fred Phelps III');
INSERT INTO Sportsman(country_name, volunteer_id, name) VALUES ('Ireland', 1000002, 'Michael Fassbender');
INSERT INTO Sportsman(country_name, volunteer_id, name) VALUES ('Russia', 1000002, 'Khabib');
INSERT INTO Sportsman(country_name, volunteer_id, name) VALUES ('Russia', 1000003, 'Another Khabib');

INSERT INTO SportFacility(facility, sport_id) VALUES (1, 15);
INSERT INTO SportFacility(facility, sport_id) VALUES (1, 16); -- 1 for pool, 16 for butterfly swimming
INSERT INTO SportFacility(facility, sport_id) VALUES (1, 7);
INSERT INTO SportFacility(facility, sport_id) VALUES (7, 16); -- 7 for pool

INSERT INTO Competition(facility, sport_id, time_, n_level, n_group)
VALUES (1, 16, '2021-06-30 14:00:00', 1, 1);
INSERT INTO Competition(facility, sport_id, time_, n_level, n_group)
VALUES (1, 16, '2021-05-30 14:00:00', 2, 1);
INSERT INTO Competition(facility, sport_id, time_, n_level, n_group)
VALUES (7, 16, '2021-05-30 14:00:00', 2, 2);

INSERT INTO 
CompetitionParticipation(sportsman_card, competition_id, final_pos)
VALUES (1, 1, 1); -- winner winner chicken dinner
INSERT INTO 
CompetitionParticipation(sportsman_card, competition_id, final_pos)
VALUES (2, 1, 2); -- silver
INSERT INTO 
CompetitionParticipation(sportsman_card, competition_id, final_pos)
VALUES (3, 1, 3);

INSERT INTO Transport (registration, capacity) VALUES ('A321TT179',3);
