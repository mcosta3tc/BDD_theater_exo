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
select region, count(*) as nb_location
from grounds
         left join addresses a on grounds.address_id = a.id
group by region;

# 7. Savoir combien de bénéfice nous avons fait pour une séance donnée sachant que chaque voiture paye 20€ sa place
set @grounds_sessions_id = 1;
select (capacity * 20) as benefice
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
where grounds_sessions.id = @grounds_sessions_id
group by grounds_sessions.id;

#8. Savoir combien de dépenses nous avons fait pour une séance donné (sachant que chaque employé nous coûte 300€ par séance)
set @grounds_sessions_id = 2;
select count(employee_id) * 300 as emlployees_costs
from grounds_sessions
         inner join grounds g on grounds_sessions.ground_id = g.id
         inner join employees e on grounds_sessions.employee_id = e.id
where grounds_sessions.id = @grounds_sessions_id
group by grounds_sessions.id;

#9. Affichers toutes les séances avec une colonne supplémentaire affichant le gain ou déficit de la séance (argent gagné par les places moins d'argent dépensé par les payes d’employés)
select *, ((capacity * 20) - (count(employee_id) * 300)) as benefice
from grounds_sessions
    inner join employees e on grounds_sessions.employee_id = e.id
    inner join grounds g on grounds_sessions.ground_id = g.id
group by grounds_sessions.date;

#10. Avoir la liste des séances où nous avons un déficit d'argent (<0€)
select *, ((capacity * 20) - (count(employee_id) * 300)) as benefice
from grounds_sessions
    inner join employees e on grounds_sessions.employee_id = e.id
    inner join grounds g on grounds_sessions.ground_id = g.id
group by grounds_sessions.date
having(benefice < 0);

#11. Savoir combien de séances nous faisons en moyenne par mois de l'année
select month(date) as month,year(date) as year, nbr_by_month, round(avg(nbr_by_month)) as avg_sessions_month
from (
         select *, count(*) as nbr_by_month
         from grounds_sessions
         group by month(date)
     ) as avg_by_m
group by id;

#12. Calculer le taux de remplissage moyen de nos séances (combien de places ont été achetés, divisé par le nombre total de places disponibles)
select *, capacity / max_capacity
from grounds_sessions
inner join grounds g on grounds_sessions.id = g.id
group by grounds_sessions.id;

#13. Calculer le taux de remplissage moyen de nos séances par genre de film
select genre, capacity / max_capacity
from grounds_sessions
inner join movies m on grounds_sessions.movie_id = m.id
inner join grounds g on g.id = grounds_sessions.ground_id
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
from grounds_sessions
inner join employees e on grounds_sessions.employee_id = e.id
group by  date
order by (nb_session_worked) desc;

#17. Savoir le nombre de séances sur lesquels chaque employé a travaillé le mois dernier

