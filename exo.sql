SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

# 1. Avoir la liste des séances de cinéma plein air prévues pour le mois prochain avec les informations sur la séance, le terrain et le film
select date,
       time,
       capacity,
       street_number,
       street_name,
       city_name,
       city_zip,
       title,
       genre,
       duration,
       year,
       author
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
         inner join addresses a on g.address_id = a.id
         inner join movies m on grounds_sessions.movie_id = m.id
where (month(date) >= 10)
group by grounds_sessions.id;

# 2. Connaître le nombre de places restantes pour une séance de cinéma
set @seance_id = 3;
select grounds_sessions.id,
       date,
       time,
       capacity,
       street_number,
       street_name,
       city_name,
       city_zip
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
         inner join addresses a on g.address_id = a.id
where grounds_sessions.id = @seance_id
group by grounds_sessions.id;

#3. Savoir quelles séances de cinémas futures sont complètes
set @actual_date = '2020-10-25';
select date,
       time,
       capacity,
       max_capacity,
       street_number,
       street_name,
       city_name,
       city_zip
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
         inner join addresses a on g.address_id = a.id
         inner join movies m on grounds_sessions.movie_id = m.id
where (date(grounds_sessions.date) > date(@actual_date))
  and ((max_capacity - capacity) = 0);

#4. Avoir la liste des informations des employés travaillant à une certaine séance donnée
select date,
       time,
       f_name,
       l_name,
       role_title
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
         inner join employees e on grounds_sessions.employee_id = e.id
         inner join employees_roles er on e.employee_role_id = er.id
where (grounds_sessions.id = @seance_id)
group by employee_id;

#5. Savoir quels sont nos clients les plus fidèles (ayant déjà participé à 2 séances au moins)
select f_name, l_name, count(client_id) as nb_seance_total
from grounds_sessions_reservation
         inner join clients c on grounds_sessions_reservation.client_id = c.id
group by client_id
having (nb_seance_total >= 2);

#6. Savoir combien de locations de terrains nous avons par région de france
select *
from grounds
         left join addresses a on grounds.address_id = a.id;