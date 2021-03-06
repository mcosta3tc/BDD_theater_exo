SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

# 1. Avoir la liste des séances de cinéma plein air prévues pour le mois prochain avec les informations sur la séance, le terrain et le film
select date,
       time,
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
where (month(date) = (month(curdate()) + 1))
group by grounds_sessions.id;

# 2. Connaître le nombre de places restantes pour une séance de cinéma
set @seance_id = 2;
select grounds_sessions.id,
       date,
       time,
       street_number,
       street_name,
       city_name,
       city_zip,
       max_capacity - count(ground_session_id) as free_capacity
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
         inner join addresses a on g.address_id = a.id
         inner join grounds_sessions_reservation gsr on grounds_sessions.id = gsr.ground_session_id
where grounds_sessions.id = @seance_id;

#3. Savoir quelles séances de cinémas futures sont complètes
set @actual_date = current_date();
select *
from (
         select date,
                time,
                street_number,
                street_name,
                city_name,
                city_zip,
                max_capacity - count(gsr.ground_session_id) as free_capacity
         from grounds_sessions
                  inner join grounds g on grounds_sessions.ground_id = g.id
                  inner join addresses a on g.address_id = a.id
                  inner join movies m on grounds_sessions.movie_id = m.id
                  inner join grounds_sessions_reservation gsr on grounds_sessions.id = gsr.ground_session_id
         where (date(grounds_sessions.date) > date(@actual_date))
         group by ground_session_id
     ) t
where (free_capacity > 0);

#4. Avoir la liste des informations des employés travaillant à une certaine séance donnée
set @seance_id = 3;
select f_name, l_name, employee_role_id, phone
from employees_ground_session
         inner join grounds_sessions gs on employees_ground_session.ground_session_id = gs.id
         inner join employees e on employees_ground_session.employee_id = e.id
where (ground_session_id = @seance_id);

#5. Savoir quels sont nos clients les plus fidèles (ayant déjà participé à 2 séances au moins)
select f_name, l_name, count(client_id) as nb_seance_total
from grounds_sessions_reservation
         inner join clients c on grounds_sessions_reservation.client_id = c.id
group by client_id
having (nb_seance_total >= 2);

#6. Savoir combien de locations de terrains nous avons par région de france
select region, count(*) as nb_location
from grounds
         left join addresses a on grounds.address_id = a.id
group by region;

# 7. Savoir combien de bénéfice nous avons fait pour une séance donnée sachant que chaque voiture paye 20€ sa place
set @grounds_sessions_id = 1;
select (count(gsr.ground_session_id) * 20) as benefice
from grounds_sessions
         inner join grounds_sessions_reservation gsr on grounds_sessions.id = gsr.ground_session_id
where grounds_sessions.id = @grounds_sessions_id
group by grounds_sessions.id;

#8. Savoir combien de dépenses nous avons fait pour une séance donné (sachant que chaque employé nous coûte 300€ par séance)
set @grounds_sessions_id = 1;
select (count(egs.employee_id) * 300) as employees_costs
from grounds_sessions
         inner join employees_ground_session egs on grounds_sessions.id = egs.ground_session_id
where grounds_sessions.id = @grounds_sessions_id;

#9. Affichers toutes les séances avec une colonne supplémentaire affichant le gain ou déficit de la séance (argent gagné par les places moins d'argent dépensé par les payes d’employés)
select gains.benefice - couts.employees_costs as gains
from (select grounds_sessions.id as id, (count(gsr.ground_session_id) * 20) as benefice
      from grounds_sessions
               left join grounds_sessions_reservation gsr on grounds_sessions.id = gsr.ground_session_id
      group by grounds_sessions.id) as gains
         inner join (
    select grounds_sessions.id, (count(egs.employee_id) * 300) as employees_costs
    from grounds_sessions
             left join employees_ground_session egs on grounds_sessions.id = egs.ground_session_id
    group by grounds_sessions.id
) as couts on gains.id = couts.id;


#10. Avoir la liste des séances où nous avons un déficit d'argent (<0€)
select gains.benefice - couts.employees_costs as gains
from (select grounds_sessions.id as id, (count(gsr.ground_session_id) * 20) as benefice
      from grounds_sessions
               left join grounds_sessions_reservation gsr on grounds_sessions.id = gsr.ground_session_id
      group by grounds_sessions.id) as gains
         inner join (
    select grounds_sessions.id, (count(egs.employee_id) * 300) as employees_costs
    from grounds_sessions
             left join employees_ground_session egs on grounds_sessions.id = egs.ground_session_id
    group by grounds_sessions.id
) as couts on gains.id = couts.id
having (gains < 0);

#11. Savoir combien de séances nous faisons en moyenne par mois de l'année ///
select month(date) as month, year(date) as year, nbr_by_month, round(avg(nbr_by_month)) as avg_sessions_month
from (
         select *, count(*) as nbr_by_month
         from grounds_sessions
         group by month(date)
     ) as avg_by_m
group by id;

select *
from (select year(date) as year, count(year(date)) as count_year
      from grounds_sessions
      group by year(date)) as year
         inner join (
    select month(date) as month, count(month(date)) as count_month
    from grounds_sessions
    group by month(date)) as month;

#12. Calculer le taux de remplissage moyen de nos séances (combien de places ont été achetés, divisé par le nombre total de places disponibles)
select *, (count(grounds_sessions_reservation.ground_session_id) / grounds.max_capacity)
from grounds_sessions
         inner join grounds on grounds_sessions.id = grounds.id
         inner join grounds_sessions_reservation on grounds_sessions.id = grounds_sessions_reservation.ground_session_id
group by grounds_sessions.id;


#13. Calculer le taux de remplissage moyen de nos séances par genre de film
select *, (count(grounds_sessions_reservation.ground_session_id) / grounds.max_capacity)
from grounds_sessions
         inner join grounds on grounds_sessions.id = grounds.id
         inner join grounds_sessions_reservation on grounds_sessions.id = grounds_sessions_reservation.ground_session_id
         inner join movies m on grounds_sessions.movie_id = m.id
group by genre;

#14. Avoir tous les mails clients pour une séance donnée
set @session = 1;
select ground_session_id, email
from clients
         inner join grounds_sessions_reservation gsr on clients.id = gsr.client_id
where ground_session_id = @session
group by client_id;

#15. Savoir quels sont les films les plus utilisés parmi toutes nos séances
select *, count(*) as nb
from movies
         inner join grounds_sessions gs on movies.id = gs.movie_id
group by movies.id
order by nb desc;

#16. Savoirs quels employés ont travaillé sur le plus de séances, affiché par ordre décroissant du nombre de séances
select f_name, l_name, count(e.id) as nb_session_worked
from employees_ground_session
         inner join employees e on employees_ground_session.employee_id = e.id
         inner join grounds_sessions gs on employees_ground_session.ground_session_id = gs.id
group by date
order by (nb_session_worked) desc;

#17. Savoir le nombre de séances sur lesquels chaque employé a travaillé le mois dernier
set @actual_date = '2022-12-24';
select f_name, l_name, count(e.id) as nb_session_worked, date
from employees_ground_session
         inner join employees e on employees_ground_session.employee_id = e.id
         inner join grounds_sessions gs on employees_ground_session.ground_session_id = gs.id
where (month(date) = (month(@actual_date) - 1))
group by e.id
order by (nb_session_worked) desc;

#18 Savoir quels clients ont été à au moins 2 séances au même terrain et avec le même film, affichés par ordre alphabétique
select *
from grounds_sessions_reservation
         inner join clients c on grounds_sessions_reservation.client_id = c.id
         inner join grounds_sessions gs on grounds_sessions_reservation.ground_session_id = gs.id;


#19 Avoir la liste des films plus récents qu’une certaine date
set @film_date = '2010-11-25';
select *
from movies
where (year(year) > year(@film_date));

#20 Avoir la liste des clients n’ayant été présents à aucune séance
select *
from clients
         left join grounds_sessions_reservation gsr on clients.id = gsr.client_id
where gsr.id is null;

#21. Obtenir la durée moyenne de nos films par genre, classée par ordre décroissant
select genre, (round(avg(film_min))) as avg_movie_time_minutes
from (
         select *, ((hour(duration) * 60) + minute(duration)) as film_min
         from movies
     ) t
group by genre
order by film_min desc;
