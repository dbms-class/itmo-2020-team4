-- https://github.com/blm768/pg-libphonenumber
-- CREATE EXTENSION pg_libphonenumber;

create table Sportsman
(
    card_number   serial primary key,  -- card_number < 10^6
    delegation_id int references Delegation,
    card_id       int references Delegation,  -- TODO
    volunteer_id  int references Volunteer,

    name          text,  -- TODO
    gender        bool,
    age           int,
    height        float,
    weight        float
);

create table Delegation
(
    id              serial primary key,
    director_id     int references Director,
    sport_object_id int references SportObject,

    county          text
);

create table Facility
(
    id serial primary key
);

-- руководитель
create table Director
(
    id              serial primary key,

    name            text,
    phone_number    text  -- packed_phone_number  -- TODO
    CHECK(phone_number ~ '^+\d{1,5}\d{10}$')
);

create table SportObject
(
    id              serial primary key,

    name            text,  -- ?
    street          text,
    house_number    int,  -- TODO
    function        text  -- TODO
);

create table CompetitionType
(
    id          serial primary key,
    sport_id    Sport
);

create table Competition
(
    id                  serial primary key,
    competition_type_id int references CompetitionType,

    name                text,
    date                date,
    time                time
);

create table Volunteer
(
    card_number serial primary key,  -- card_number >= 10^6

    name            text,
    phone_number    text,  -- TODO
    CHECK(phone_number ~ '^+\d{1,5}\d{10}$')
);

create table Transport
(
    serial_number   serial primary key,
    capacity        int,
    check (capacity>=0)  -- TODO
);

create table VolunteerTask
(
    id              serial primary key,
    volunteer_id    int references Volunteer,
    transport_id    int references Transport,

    text            text,
    date            date,
    time            time
);

create table Sportsman_Sport
(
    sportsman_id    int references Sportsman,
    sport_id        Sport,
    unique (sportsman_id, sport_id)
);

create table SportObject_Sport
(
    sport_object_id int references SportObject,
    sport_id        Sport,
    unique (sport_object_id, sport_id)
);

create table Sportsman_Competition
(
    sportsman_id    int references Sportsman,
    competition_id  int references Competition,

    medal           Medal
);

create type Medal as enum('gold', 'silver', 'bronze');

create type Sport as enum('basketball', 'tennis', 'football', 'swimming');  -- ??