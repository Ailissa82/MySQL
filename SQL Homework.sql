use sakila;
-- 1a display first and last name of all actors from the actor table
SELECT 
    first_name, last_name
FROM
    actor;

-- 1b display frist and last name of actor in a single column in upper case and name 'Actor'
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Actor'
FROM
    actor;

-- 2a find ID#, first name, last name of actors of which you only know first name Joe
SELECT 
    *
FROM
    actor
WHERE
    first_name LIKE 'JOE';

-- 2b find all actors whose last names contain the letters GEN
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE '%GEN%';

-- 2c find all actors whose last name contains the letter LI, order by last name then frist name
SELECT 
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
GROUP BY last_name , first_name;

-- 2d using IN, display coutry_id and country columns of the following countries - Afghanistan, Bangladesh and China
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a keep a description of each actor by creating a column in the table actor named description and use data type blob (stors binary data as byte)
ALTER TABLE actor
ADD COLUMN description blob AFTER last_update;

-- 3b delete column
ALTER TABLE actor
DROP COLUMN description;

-- 4a list the last name of actors and count how many actors have that last name
SELECT 
    last_name, COUNT(last_name)
FROM
    actor
GROUP BY last_name;

-- 4b list the last name of actors and the number of actors who have that last name, but only for names that are shared by at least 2 actors
SELECT 
    last_name, COUNT(*)
FROM
    actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

-- 4c actor harpo williams was accidentially entered into actor table as groucho williams. fix the record
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE 'WIL%'
GROUP BY last_name , first_name;
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    actor_id = 172;
    
-- 4d change the name back to groucho
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    actor_id = 172;
    
-- 5a write query to re-create the adress table schema
SHOW CREATE TABLE address;

-- 6a use join to display the frist and last nams as well as the address of each staff member using staff and address tables
SELECT 
    address.address_id, last_name, first_name, address
FROM
    address
        JOIN
    staff ON address.address_id = staff.address_id;

-- 6b use join to display the total amount rung up by each staff member in aug 2005 (staff, pmt)
SELECT 
    p.staff_id,
    s.first_name,
    s.last_name,
    SUM(p.amount) AS 'total amount'
FROM
    payment AS p
        JOIN
    staff s ON p.staff_id = s.staff_id
WHERE
    p.payment_date BETWEEN CAST('2005-08-01' AS DATE) AND CAST('2005-08-31' AS DATE)
GROUP BY s.staff_id , s.first_name , s.last_name;

-- 6c list each film and the number of actors who are listed for that film (film_actor & film)
SELECT 
    f.film_id,
    f.title,
    COUNT(DISTINCT a.actor_id) AS 'num_of_actor'
FROM
    film AS f
        JOIN
    film_actor AS a ON f.film_id = a.film_id
GROUP BY f.film_id , f.title;

-- 6d how many copies of the film hunchback impossible exist in the inventory system
SELECT 
    f.film_id, COUNT(f.title)
FROM
    inventory AS i
        JOIN
    film AS f ON i.film_id = f.film_id
WHERE
    title = 'Hunchback Impossible';

-- 6e using payment and customer tables to list the total paid by each customer; list customer alphabetically
SELECT 
    p.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS 'total amount'
FROM
    payment AS p
        JOIN
    customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id , c.first_name , c.last_name
ORDER BY c.last_name;

-- 7a use subqueries to display the titles of movies starting with letters k and q whose language is english
SELECT 
    f.title
FROM
    film AS f
        JOIN
    (SELECT 
        language_id
    FROM
        language AS l
    WHERE
        name = 'English'
    GROUP BY language_id) AS l ON f.language_id = l.language_id
        JOIN
    (SELECT 
        title, LEFT(title, 1) AS first_letter
    FROM
        film) AS fl ON f.title = fl.title
WHERE
    first_letter IN ('K' , 'Q');

-- 7b use subqueries to display all actors who appear in the film Alone Trip
SELECT 
    a.actor_id, a.first_name, a.last_name, f.title
FROM
    actor AS a
        JOIN
    film_actor AS fa ON a.actor_id = fa.actor_id
        JOIN
    (SELECT 
        title, film_id
    FROM
        film
    WHERE
        title = 'Alone Trip') AS f ON fa.film_id = f.film_id;

-- 7c get names and emails addresses of all canadian customers
SELECT 
    c.first_name, c.last_name, c.email
FROM
    customer AS c
        JOIN
    address AS a ON c.address_id = a.address_id
        JOIN
    city ON a.city_id = city.city_id
        JOIN
    country ON city.country_id = country.country_id
WHERE
    country = 'Canada';

-- 7d get all movies cateorgized as family film
SELECT 
    title, c.name AS 'genre'
FROM
    category AS c
        JOIN
    film_category AS fc ON c.category_id = fc.category_id
        JOIN
    film AS f ON fc.film_id = f.film_id
WHERE
    c.name = 'Family';

-- 7e display most frequently rented movies in descending order
SELECT 
    f.title,
    COUNT(i.inventory_id) AS 'num_times_rented'
FROM
    film AS f
        JOIN
    inventory AS i ON f.film_id = i.film_id
        JOIN
    rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.title 
ORDER BY count(r.inventory_id) DESC;

-- 7f how much business in dollars did each store brought in
SELECT 
    p.staff_id, s.store_id, SUM(p.amount) AS 'total_business'
FROM
    payment AS p
        JOIN
    staff AS sid ON p.staff_id = sid.staff_id
        JOIN
    store AS s ON sid.store_id = s.store_id
GROUP BY s.store_id;

-- 7g for each store display store id, city, and country
SELECT 
    s.store_id, c.city, cntry.country
FROM
    address AS a
        JOIN
    city AS c ON a.city_id = c.city_id
        JOIN
    store AS s ON a.address_id = s.address_id
        JOIN
    country AS cntry ON c.country_id = cntry.country_id;

-- 7h list top 5 generes in gross revenue in desc order
-- 8a
CREATE VIEW Top_5_Genre AS
    SELECT 
        fc.category_id,
        c.name AS 'genre',
        SUM(p.amount) AS 'gross revenue'
    FROM
        category AS c
            JOIN
        film_category AS fc ON c.category_id = fc.category_id
            JOIN
        inventory AS i ON fc.film_id = i.film_id
            JOIN
        rental AS r ON i.inventory_id = r.inventory_id
            JOIN
        payment AS p ON p.rental_id = r.rental_id
    GROUP BY fc.category_id , c.name
    ORDER BY sum(p.amount) DESC
    LIMIT 5;
 
-- 8b display view created in 8a
SELECT 
    *
FROM
    Top_5_Genre;

-- 8c delete the above view
drop view Top_5_Genre;
