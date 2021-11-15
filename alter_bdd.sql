use bdd_cinema;

insert into addresses (street_number, street_name, city_name, city_zip, region)
values (10, 'street un', ' city un', 11111, 'region1'),
       (102, 'street deux', 'city deux', 22222, 'region1'),
       (103, 'street trois', 'city trois', 33333, 'region2');

insert into grounds (address_id, capacity, max_capacity)
values (1, 20, 40),
       (2, 25, 25),
       (3, 30, 100);

insert into movies (title, genre, duration, year, author)
values ('film un', 'genre un', '01:20', '2012-12-24', 'author un'),
       ('film deux', 'genre deux', '01:10', '2018-11-08', 'author deux'),
       ('film trois', 'genre trois', '01:30', '2010-09-12', 'author trois'),
       ('film quatre', 'genre trois', '01:05', '2010-06-12', 'author trois'),
       ('film cinq', 'genre deux', '01:30', '2010-09-12', 'author trois');

insert into employees_roles (role_title)
values ('role 1'),
       ('role 2'),
       ('role 3');

insert into employees (f_name, l_name, employee_role_id)
values ('first un', 'last un', 1),
       ('first deux', 'last deux', 2),
       ('first trois', 'last trois', 3);

insert into grounds_sessions(date, time, ground_id, employee_id, movie_id)
values ('2020-10-25', '20:30', 1, 2, 1),
       ('2020-10-26', '20:00', 2, 1, 2),
       ('2020-10-26', '20:00', 2, 2, 2),
       ('2020-12-24', '21:30', 1, 3, 3),
       ('2021-9-24', '21:30', 1, 3, 3),
       ('2021-12-20', '21:30', 1, 3, 3),
       ('2020-12-25', '21:30', 1, 2, 3);

insert into clients (f_name, l_name, email, password)
values ('first client un', 'last client un', 'un@un.com', 'un'),
       ('first client deux', 'last client deux', 'deux@deux.com', 'deux'),
       ('first client trois', 'last client trois', 'trois@trois.com', 'trois'),
       ('first client quatre', 'last client quatre', 'quatre@quatre.com', 'quatre'),
       ('first client cinq', 'last client cinq', 'cinq@cinq.com', 'cinq');

insert into grounds_sessions_reservation(ground_session_id, client_id)
values (1, 1),
       (1, 2),
       (2, 3),
       (2, 1),
       (3, 3),
       (4, 1),
       (5, 1);