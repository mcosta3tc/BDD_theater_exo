DROP DATABASE IF EXISTS bdd_cinema;
CREATE DATABASE bdd_cinema;

use bdd_cinema;

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses
(
    id            int          not null auto_increment,
    street_number int          not null,
    street_name   varchar(255) not null,
    city_name     varchar(255) not null,
    city_zip      varchar(255) not null,
    region        varchar(255) not null,
    primary key (id)
);

drop table if exists grounds;
create table grounds
(
    id           int not null auto_increment,
    address_id   int not null,
    max_capacity int not null default 0,
    primary key (id),
    foreign key (address_id) references addresses (id) on delete cascade
);

drop table if exists movies;
create table movies
(
    id       int          not null auto_increment,
    title    varchar(255) not null,
    genre    varchar(255) not null,
    duration time         not null,
    year     date         not null,
    author   varchar(255),
    primary key (id)
);


drop table if exists employees_roles;
create table employees_roles
(
    id         int auto_increment not null,
    role_title varchar(255)       not null,
    primary key (id)
);
drop table if exists employees;
create table employees
(
    id               int auto_increment not null,
    f_name           varchar(255)       not null,
    l_name           varchar(255)       not null,
    employee_role_id int                not null,
    phone            varchar(20)        not null,
    primary key (id),
    foreign key (employee_role_id) references employees_roles (id) on delete cascade
);

drop table if exists grounds_sessions;
create table grounds_sessions
(
    id        int  not null auto_increment,
    date      date not null,
    time      time not null,
    ground_id int  not null,
    movie_id  int  not null,
    primary key (id),
    foreign key (ground_id) references grounds (id) on delete cascade on update cascade,
    foreign key (movie_id) references movies (id) on delete cascade
);

drop table if exists employees_ground_session;
create table employees_ground_session
(
    id                int not null auto_increment,
    ground_session_id int not null,
    employee_id       int not null,
    primary key (id),
    foreign key (ground_session_id) references grounds_sessions (id) on delete cascade on update cascade,
    foreign key (employee_id) references employees (id) on delete cascade on update cascade
);

drop table if exists clients;
create table clients
(
    id       int auto_increment not null,
    f_name   varchar(255)       not null,
    l_name   varchar(255)       not null,
    email    varchar(255)       not null,
    password varchar(255)       not null,
    primary key (id)
);

drop table if exists grounds_sessions_reservation;
create table grounds_sessions_reservation
(
    id                int auto_increment not null,
    ground_session_id int                not null,
    client_id         int                not null,
    primary key (id),
    foreign key (ground_session_id) references grounds_sessions (id) on delete cascade on update cascade,
    foreign key (client_id) references clients (id) on delete cascade
);
