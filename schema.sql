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


drop type if exists Medal;
drop type if exists Sport;
--end clean

create type Medal as enum('gold', 'silver', 'bronze');
-- Dict for Sports? Sports must have n > 0 competitions each
create type Sport as enum('basketball', 'tennis', 'football', 'swimming');

-- create sequence card_number;

-- у каждого объекта есть адрес (название улицы в деревнеи номер дома)
create table Address
(
    id              serial primary key,

    street_name     text not null,  -- ?
    house_number    int not null,

    unique (street_name, house_number)
);

-- у каждого объекта есть адрес, функци. предн. и опц. собственное имя
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

    county          text not null, -- must reference some country? countries dict?
    director_name   text not null,
    director_phone  text unique not null check(director_phone ~ E'^\\+\\d{11,15}')
);

-- у каждым спортсмена не уникальный волонтёр(имя,телефон,карточка как у спортсмена)
create table Volunteer
(
    -- card_number serial primary key default nextval('card_number'),
    card_number serial primary key check(card_number > 1e6),

    name            text not null,
    phone_number    text not null check(phone_number ~ E'^\\+\\d{11,15}') 
);

-- имя, пол, рост, вес, возраст, нац. делегация, где-то живёт
create table Sportsman
(
    card_number   serial primary key check(card_number < 1e6),

    delegation_id int references Delegation,
    residence     int references Facility,
    helper        int references Volunteer,

    name          text not null,  -- TODO
    gender        bool not null,
    height        float not null,
    weight        float not null,
    age           int not null check(age < 99 AND age > 14),
    sports_n      int check(sports_n > 0) -- smth like this, sportsman has to participate in smth
);

--Каждый спортсмен выступает в каком-то виде спорта, возможно даже не в одном
create table SportParticipation
(
    sportsman_card int references Sportsman,
    sport_id      Sport, 

    unique (sportsman_card, sport_id)
);

-- некоторые объекты могут быть проассоциированы с некоторым множеством видов спорта, которые в них проходят
create table SportFacility
(
    id              serial primary key,
    facility        int references Facility,
    sport_id        Sport,

    unique (facility, sport_id)
);

-- соревнование – событие, происходящее в дату и время, участвуют некоторые спортсмены,
-- в некотором объекте
create table Competition
(
    id                  serial primary key,
    -- competition_type_id int references CompetitionType, -- enum or smth for type?
    place               int references SportFacility,

    name                text,
    time_               timestamp,
    -- prizes              bool, -- state that medals can be won
    -- How to deal with participating sportsmen???

    unique (time_, place)
);

create table MedalHolder
(
    sportsman_card int references Sportsman,
    competition_id int references Competition,

    unique (sportsman_card, competition_id)
    -- check that medals were given for that competition???
);

-- транспортное средство (регистрационный номер и вместимость)
create table Transport
(
    -- serial_number   serial primary key, -- is it necessary if we have registration?
    registration    text primary key, -- check with regex?
    capacity        int check (capacity >= 0)
);

--Волонтёрам дают задания (дата, время, текстовое описание, может быть ТС)
create table VolunteerTask
(
    id              serial primary key,

    volunteer_id    int references Volunteer not null,
    transport_reg   text references Transport,

    time_           timestamp,
    description     text,

    unique (time_, volunteer_id)
);

-- Fill
INSERT INTO Transport (registration, capacity) VALUES ('A321TT179',3);