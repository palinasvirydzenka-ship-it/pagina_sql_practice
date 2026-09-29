--1. Output the number of movies in each category, sorted descending.
select count(f.film_id) as number_of_movies, c.name as name_of_category
from film f
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id
group by c.name
order by count(f.film_id) desc;

--2. Output the 10 actors whose movies rented the most, sorted in descending order.
select a.actor_id, 
concat(a.first_name, ' ', a.last_name) AS actor_full_name,
count(r.rental_id) as the_most_rented_movies 
from actor a
join film_actor fa on a.actor_id = fa.actor_id 
join film f on fa.film_id = f.film_id 
join inventory i on f.film_id = i.film_id 
join rental r on i.inventory_id = r.inventory_id 
group by a.actor_id , actor_full_name 
order by the_most_rented_movies desc
limit 10;

--3. Output the category of movies on which the most money was spent.
select c.name, sum(p.amount) as the_most_money_spent
from category c
join film_category fc on c.category_id = fc.category_id
join inventory i on fc.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id
group by c.name
order by the_most_money_spent desc
limit 1;

--4. Print the names of movies that are not in the inventory. Write a query without using the IN operator.
select f.title
from film f
left join inventory i on f.film_id = i.film_id
where i.film_id is null;

--5. Output the top 3 actors who have appeared the most in movies in the “Children” category. 
--If several actors have the same number of movies, output all of them.
with actors as (
    select 
        a.actor_id,
        concat(a.first_name, ' ', a.last_name) as actor_full_name,
        count(fc.film_id) as total_children_movies,
        dense_rank() over (order by count(fc.film_id) desc) as rnk
    from actor a
    join film_actor fa on a.actor_id = fa.actor_id
    join film_category fc on fa.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    where c.name = 'Children'
    group by a.actor_id, a.first_name, a.last_name
)
select 
    actor_id,
    actor_full_name,
    total_children_movies
from actors ac
where rnk <= 3
order by total_children_movies desc;

--6. Output cities with the number of active and inactive customers (active - customer.active = 1). 
--Sort by the number of inactive customers in descending order.
select 
	ci.city,
    sum(case when cs.active = 1 then 1 else 0 end) as active_customers,
    sum(case when cs.active = 0 then 1 else 0 end) as inactive_customers
from city ci
join address a on ci.city_id = a.city_id 
join customer cs on a.address_id = cs.address_id 
group by ci.city_id, ci.city
order by inactive_customers desc;

--7. Output the category of movies that have the highest number of total rental hours in the city (customer.address_id in this city) 
--and that start with the letter “a”. Do the same for cities that have a “-” in them. Write everything in one query.
(
    select 
        'cities_starting_with_a' as city,
        c.name as category_name,
        sum(f.rental_duration * 24) as total_rental_hours
    from customer cs
    join address a on cs.address_id = a.address_id
    join city ci on a.city_id = ci.city_id
    join rental r on cs.customer_id = r.customer_id
    join inventory i on r.inventory_id = i.inventory_id
    join film f on i.film_id = f.film_id
    join film_category fc on f.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    where ci.city ilike 'a%'
    group by c.name
    order by total_rental_hours desc
    limit 1
)
union all
(
    select 
        'cities_with_hyphen' as city,
        c.name as category_name,
        sum(f.rental_duration * 24) as total_rental_hours
    from customer cs
    join address a on cs.address_id = a.address_id
    join city ci on a.city_id = ci.city_id
    join rental r on cs.customer_id = r.customer_id
    join inventory i on r.inventory_id = i.inventory_id
    join film f on i.film_id = f.film_id
    join film_category fc on f.film_id = fc.film_id
    join category c on fc.category_id = c.category_id
    where ci.city like '%-%'
    group by c.name
    order by total_rental_hours desc
    limit 1
);
