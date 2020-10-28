--clean
drop table if exists VolunteerTask;
drop table if exists Transport;
drop table if exists MedalHolder;
drop table if exists Competition;
drop table if exists SportFacility;
drop table if exists SportParticipation;
drop table if exists Sportsman;
drop table if exists Volunteer;
drop table if exists Delegation;
drop table if exists Facility;
drop table if exists Address;
drop table if exists Sport;

drop type if exists Medal;
drop type if exists FacilityFunction;
--end clean

create type Medal as enum('gold', 'silver', 'bronze');
create type FacilityFunction as enum('restaurant', 'household', 'pool', 'track',
'stadium', 'pitch');

-- Dict for Sports
create table Sport
(
    id              serial primary key,
    name            text unique not null
);

-- Dict for Countries that are coming to the event
create table Country
(
    id              serial primary key,
    name            text unique not null
);

-- у каждого объекта есть адрес (название улицы в деревнеи номер дома)
create table Address
(
    id              serial primary key,

    street_name     text not null,  -- ?
    house_number    int not null,
    additional      text, -- if there are corps and so on

    unique (street_name, house_number, additional)
);

-- у каждого объекта есть адрес, функц. предн. и опц. собственное имя
create table Facility
(
    id              serial primary key,

    address_id      int references Address not null,

    function        text not null, -- dict of possible functions?
    name            text
);

-- у каждой национальной делегации есть руководитель (имя и телефон),
-- в одном из объектов должен быть штаб делегации
create table Delegation
(
    id              serial primary key,

    headquarters    int references Facility not null,
    country_id      int references Country not null,

    director_name   text not null,
    director_phone  text unique not null check(director_phone ~ E'^\\+\\d{11,15}') -- can be used as key?
);

-- у каждым спортсмена не уникальный волонтёр(имя,телефон,карточка как у спортсмена)
create table Volunteer
(
    -- card_number serial primary key default nextval('card_number'),
    card_number     serial primary key check(card_number >= 1e6),

    name            text not null,
    phone_number    text not null check(phone_number ~ E'^\\+\\d{11,15}') 
);
-- У спортсменов карточки до миллиона, у волонтёров после
alter sequence volunteer_card_number_seq restart with 1000000;

-- имя, пол, рост, вес, возраст, нац. делегация, где-то живёт
create table Sportsman
(
    card_number   serial primary key check(card_number < 1e6),

    delegation_id int references Delegation not null,
    facility_id   int references Facility not null,
    volunteer_id  int references Volunteer not null,

    name          text not null,  -- TODO
    gender        bool not null,
    height        float not null,
    weight        float not null,
    age           int not null check(age < 99 and age > 14)
);

--Каждый спортсмен выступает в каком-то виде спорта, возможно даже не в одном
create table SportParticipation
(
    sportsman_card int references Sportsman not null,
    sport_id       int references Sport not null, 

    unique (sportsman_card, sport_id)
);

-- некоторые объекты могут быть проассоциированы с некоторым множеством видов спорта, которые в них проходят
create table SportFacility -- sport - facility relation
(
    id              serial primary key,
    facility        int references Facility not null,
    sport_id        int references Sport not null, 

    unique (facility, sport_id)
);

-- соревнование – событие, происходящее в дату и время, участвуют некоторые спортсмены,
-- в некотором объекте
create table Competition
(
    id                  serial primary key,
    place               int references SportFacility not null,

    name                text not null, -- Competition type like swim 200m or run 100 m
    time_               timestamp not null,
    description         text not null, -- Women/Men Final, Semi, Quarters, top-100
    -- medals              bool not null, -- state that medals can be won

    unique (time_, place),
    unique (name, description)
);

create table MedalHolders
(
    competition_id      int references Competition not null,
    gold_holder         int references Sportsman not null,
    silver_holder       int references Sportsman not null,
    bronze_holder       int references Sportsman not null,

    unique (competition_id)
);

alter table MedalHolders
add constraint chk_dif_holders 
check (gold_card != silver_card and silver_card != bronze_card and bronze_card != gold_card);

create table CompetitionParticipation
(
    sportsman_card      int references Sportsman not null,
    competition_id      int references Competition not null,

    time_               timestamp not null, -- we leave time here so
    -- How to deal with participating sportsmen???

    unique (sportsman_card, competition_id),
    unique (sportsman_card, time_)
);

-- транспортное средство (регистрационный номер и вместимость)
create table Transport
(
    -- serial_number   serial primary key, -- is it necessary if we have registration?
    registration    text primary key, -- check with regex?
    capacity        int not null check (capacity >= 0)
);

--Волонтёрам дают задания (дата, время, текстовое описание, может быть ТС)
create table VolunteerTask
(
    id              serial primary key,

    volunteer_id    int references Volunteer not null,
    transport_reg   text references Transport,

    time_           timestamp not null,
    description     text not null,

    unique (time_, volunteer_id)
);

-- Fill
INSERT INTO Sport (name)
SELECT unnest(ARRAY['swimming', 'running', 'football', 'basketball', 'tennis', 'poker', 'chess']);

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
