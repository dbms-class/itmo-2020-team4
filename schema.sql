-- Dict for Sports
create table Sport
(
    name            text primary key check (char_length(name) > 0)
);

-- Dict for Countries that are coming to the event
create table Country
(
    name            text primary key check (char_length(name) > 0)
);

create table FacilityFunction
(
    name            text primary key check (char_length(name) > 0)
);

-- у каждого объекта есть адрес (название улицы в деревнеи номер дома)
create table Address
(
    id              serial primary key,

    street_name     text not null check (char_length(street_name) > 0),
    house_number    int not null check (house_number > 0),
    additional      text, -- if there are corps and so on

    unique (street_name, house_number, additional)
);

-- у каждого объекта есть адрес, функц. предн. и опц. собственное имя
create table Facility
(
    id              serial primary key,

    address_id      int references Address not null,

    function        text references FacilityFunction not null,
    name            text
);

-- у каждой национальной делегации есть руководитель (имя и телефон),
-- в одном из объектов должен быть штаб делегации
create table Delegation
(
    director_name   text primary key check (char_length(director_name) > 0),

    headquarters_id int references Facility not null,
    country         text references Country not null,

    director_phone  text unique not null check(director_phone ~ E'^\\+\\d{11,15}') -- can be used as key?
);

-- у каждым спортсмена не уникальный волонтёр(имя,телефон,карточка как у спортсмена)
create table Volunteer
(
    card_number     serial primary key check(card_number >= 1e6),

    name            text not null check (char_length(name) > 0),
    phone_number    text not null check (phone_number ~ E'^\\+\\d{11,15}') 
);
-- У спортсменов карточки до миллиона, у волонтёров после
alter sequence volunteer_card_number_seq restart with 1000000;

-- имя, пол, рост, вес, возраст, нац. делегация, где-то живёт
create table Sportsman
(
    card_number   serial primary key check(card_number < 1e6),

    director      text references Delegation not null,
    facility_id   int references Facility not null,
    volunteer_id  int references Volunteer not null,

    name          text not null check (char_length(name) > 0),
    gender        bool, -- null for those that have not decided yet
    height        float not null check (height > 0),
    weight        float not null check (weight > 0),
    age           int not null check (age < 99 and age > 14)
);

--Каждый спортсмен выступает в каком-то виде спорта, возможно даже не в одном
create table SportParticipation
(
    sportsman_card  int references Sportsman not null,
    sport           text references Sport not null, 

    unique (sportsman_card, sport)
);

-- некоторые объекты могут быть проассоциированы с некоторым множеством видов спорта, которые в них проходят
create table SportFacility -- sport - facility relation
(
    id              serial primary key,
    facility        int references Facility not null,
    sport           text references Sport not null, 

    unique (facility, sport)
);

-- Swim 200m/400m, Run with/wo obstacles and so on
create table CompetitionType
(
    type          text primary key,
    sport         text references Sport not null
);

-- соревнование – событие, происходящее в дату и время, участвуют некоторые спортсмены,
-- в некотором объекте
create table Competition
(
    id                  serial primary key,

    place               int references SportFacility not null,
    type                text references CompetitionType not null,

    time_               timestamp not null,
    description         text not null check (char_length(description) > 0), -- Women/Men Final, Semi, Quarters, top-100

    unique (time_, place),
    unique (description, type) 
    -- only one Women 200m swim lower bracket semi final, etc.
);

create table MedalHolder
(
    competition_id          int references Competition not null,
    gold_holder             int references Sportsman not null,
    silver_holder           int references Sportsman not null,
    bronze_holder           int references Sportsman not null,
    second_bronze_holder    int references Sportsman, -- Say hello to Judo

    unique (competition_id)
);

alter table MedalHolder
add constraint chk_dif_holders 
check (gold_holder != silver_holder and 
       silver_holder != bronze_holder and 
       bronze_holder != gold_holder and
       second_bronze_holder != gold_holder and
       second_bronze_holder != silver_holder and
       second_bronze_holder != bronze_holder);

create table CompetitionParticipation
(
    sportsman_card      int references Sportsman not null,
    competition_id      int references Competition not null,

    time_               timestamp not null, -- we leave time here so
    -- How to deal with participating sportsmen???
    position            int check (position > 0), -- not only medals matter... 
    -- null if comp has not finished yet or no position at all
    -- places 32-64 are all signed 33, so not unique

    unique (sportsman_card, competition_id),
    unique (sportsman_card, time_)
);

-- транспортное средство (регистрационный номер и вместимость)
create table Transport
(
    -- serial_number   serial primary key, -- is it necessary if we have registration?
    registration    text primary key check (char_length(registration) > 0), -- check with regex?
    capacity        int not null check (capacity >= 0)
);

--Волонтёрам дают задания (дата, время, текстовое описание, может быть ТС)
create table VolunteerTask
(
    id              serial primary key,

    volunteer_id    int references Volunteer not null,
    transport_reg   text references Transport,

    time_           timestamp not null,
    description     text not null check (char_length(description) > 0),

    unique (time_, volunteer_id)
);

-- Fill
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


INSERT INTO Transport (registration, capacity) VALUES ('A321TT179',3);

INSERT INTO Volunteer (name, phone_number) VALUES ('SomeVolunteer','+4546667772288');
