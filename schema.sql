-- Dict for Sports
create table Sport
(
    id              serial primary key,
    name            text unique not null check (char_length(name) > 0)
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

    unique (street_name, house_number)
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
    id              serial primary key,

    director_name   text unique not null check (char_length(director_name) > 0),
    director_phone  text unique not null check (director_phone ~ E'^\\+\\d{11,15}'), -- can be used as key?

    headquarters_id int references Facility not null,
    country         text references Country not null
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

    delegation_id int references Delegation not null,
    facility_id   int references Facility not null,
    volunteer_id  int references Volunteer not null,

    name          text not null check (char_length(name) > 0),
    gender        bool, -- null for those that have not decided yet
    height        float not null check (height > 0),
    weight        float not null check (weight > 0),
    age           int not null check (age < 99 and age > 14)
);

--Каждый спортсмен выступает в каком-то виде спорта, возможно даже не в одном
-- create table SportParticipation
-- (
--     sportsman_card  int references Sportsman not null,
--     sport           int references Sport not null, 

--     unique (sportsman_card, sport)
-- );
-- SportParticiptaion can be mined from CompetitionParticipation

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
    id          serial primary key,

    facility    int references Facility not null,
    sport_id    int references Sport not null,

    time_       timestamp not null,
    n_level     int not null check (n_level > 0),
    -- 1 for Final, 2 for Semi, 3 for 1/4, 4 for 1/2^(4-1) and so on
    n_group     int not null check (n_group > 0),
    -- 1 in Final, 2 groups in Semi, 4 groups in 1/4, 2^(5) in 1/8

    unique (time_, facility),
    unique (sport_id, n_level, n_group),

    constraint n_pairs_for_level check (n_group <= power(2, n_level-1)),
    constraint fk_sport_facility foreign key (facility, sport_id)
    references SportFacility(facility, sport_id)
);

create table CompetitionParticipation
(
    sportsman_card      int references Sportsman not null,
    competition_id      int references Competition not null,

    sport_id    int references Sport not null,
    n_level     int not null check (n_level > 0),
    n_group      int not null check (n_group > 0),

    position            int check (position > 0), -- not only medals matter... 
    -- null if comp has not finished yet or no position at all
    -- places 32-64 are all signed 33, so not unique

    unique (sportsman_card, competition_id),
    unique (sportsman_card, sport_id, n_level), -- only one participation in a leg
    constraint fk_one_leg foreign key (sport_id, n_level, n_group)
    references Competition(sport_id, n_level, n_group)
);

create table CompetitionWithMedals
(
    competition_id          int references Competition unique not null
);

create table MedalHolder
(
    competition_id          int references Competition not null,
    gold_holder             int references Sportsman not null,
    silver_holder           int references Sportsman not null,
    bronze_holder           int references Sportsman not null,
    s_bronze_holder         int references Sportsman, -- Say hello to Judo

    unique (competition_id),

    constraint fk_comp_has_medals foreign key (competition_id)
    references CompetitionWithMedals(competition_id),
    constraint fk_gold_participated foreign key (gold_holder, competition_id)
    references CompetitionParticipation(sportsman_card, competition_id),
    constraint fk_silver_participated foreign key (silver_holder, competition_id)
    references CompetitionParticipation(sportsman_card, competition_id),
    constraint fk_bronze_participated foreign key (bronze_holder, competition_id)
    references CompetitionParticipation(sportsman_card, competition_id),
    constraint fk_s_bronze_participated foreign key (s_bronze_holder, competition_id)
    references CompetitionParticipation(sportsman_card, competition_id)
);

alter table MedalHolder
add constraint chk_dif_holders 
check (gold_holder != silver_holder and 
       silver_holder != bronze_holder and 
       bronze_holder != gold_holder and
       s_bronze_holder != gold_holder and
       s_bronze_holder != silver_holder and
       s_bronze_holder != bronze_holder);

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
