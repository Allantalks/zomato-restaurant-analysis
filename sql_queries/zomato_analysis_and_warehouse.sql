-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zomato Restaurant Analysis
-- Analysts: Allan Jigi Mathew, Bevis Mathew Thomas, Sam Jacob Sajan
-- Tool: MySql 8.0
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- create database
create database zomato_analysis;
use zomato_analysis;

-- Create Table
create table zomato_restaurants(
restaurant_id int,
restaurant_name varchar(150),
country_code int,
city varchar(100), 
address varchar(255), 
locality varchar(150), 
locality_verbose varchar(200), 
longitude decimal(10,8), 
latitide decimal(10,8), 
cuisines varchar(200), 
average_cost_for_two int, 
currency varchar(150), 
has_table_booking varchar(10), 
has_online_delivery varchar(10), 
is_delivering_now varchar(10),
switch_to_order_menu varchar(10), 
price_range int,
aggregate_rating decimal(3,1),
rating_colour varchar(20),
rating_text varchar(100), 
votes int);

describe zomato_restaurants;

-- Importing the csv file into SQL
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/zomato.csv'

into table zomato_restaurants
character set latin1
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(restaurant_id, restaurant_name, country_code, city, address, locality, locality_verbose, longitude, latitude,
 cuisines, average_cost_for_two, currency, has_table_booking, has_online_delivery, is_delivering_now, switch_to_order_menu,
 price_range, aggregate_rating, rating_colour, rating_text, votes);
 
 show variables like 'secure_file_priv';
 
 -- Rename from latitide to latitude
alter table zomato_restaurants
change column latitide latitude decimal(10,6);

-- Change the decimal place of longitide
alter table zomato_restaurants
modify longitude decimal(10,6);

select * from zomato_restaurants where country_code=1;


-- Checking if for any incomplete missing values or rows
select count(*) from zomato_restaurants;
select * from zomato_restaurants limit 5;

-- where country code=1
select count(*) as total_rows from zomato_restaurants where country_code=1;

-- Delete dataset where country code is not equal to 1
set sql_safe_updates=0;
delete from zomato_restaurants where country_code!=1;
set sql_safe_updates=1;

-- Check the total rows containing only country code India
select count(*) as india_rows from zomato_restaurants;
select * from zomato_restaurants;

-- Delete rows having aggregate rating as 0.0
set sql_safe_updates=0;
delete from zomato_restaurants where aggregate_rating=0;
set sql_safe_updates=1;

-- Check the total rows after the aggragate rows have been deleted
select count(*) as india_rows from zomato_restaurants;
select * from zomato_restaurants;

-- Check for duplicates
select restaurant_id, count(*) from zomato_restaurants group by restaurant_id having count(*)>1;

-- Check for any Null values
select
sum(case when restaurant_name is NULL then 1 else 0 end) as name_null,
sum(case when city is NULL then 1 else 0 end) as city_null,
sum(case when cuisines is NULL then 1 else 0 end) as cuisines_null,
sum(case when average_cost_for_two is NULL then 1 else 0 end) as average_null,
sum(case when aggregate_rating is NULL then 1 else 0 end) as aggregate_null,
sum(case when votes is NULL then 1 else 0 end) as votes_null 
from zomato_restaurants;

-- Check rows consistency
select distinct rating_text from zomato_restaurants;
select distinct has_online_delivery from zomato_restaurants;
select distinct has_table_booking from zomato_restaurants;
select distinct price_range from zomato_restaurants;

-- remove votes <5
select votes from zomato_restaurants where votes<5;
select count(*) from zomato_restaurants where votes<5;
select max(votes), min(votes), round(avg(votes),0) from zomato_restaurants;

set sql_safe_updates=0;
delete from zomato_restaurants where votes<5;
set sql_safe_updates=1;

-- Overall KPI's
select count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
max(aggregate_rating) as max_rating,
min(aggregate_rating) as min_rating,
round(avg(average_cost_for_two),0) as avg_cost_for_two,
sum(votes) as total_votes,
count(distinct city) as total_cities,
count(distinct cuisines) as total_cuisines from zomato_restaurants;

-- Top cities by restaurants
select city,
count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
round(avg(average_cost_for_two),0) as avg_cost_for_two,
sum(votes) as total_votes from zomato_restaurants
group by city order by total_restaurants desc limit 15;

select * from zomato_restaurants;

-- Comparison by Price Range
select price_range,
case 
when price_range=1 then 'Budget'
when price_range=2 then 'Moderate'
when price_range=3 then 'Expensive'
when price_range=4 then 'Premium'
end as price_category,
count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
sum(votes) as total_votes,
round(avg(average_cost_for_two),0) as avg_cost_for_two
from zomato_restaurants group by price_range order by price_range;
/* Here we can see that as the cost of the restaurant increases the rating also increases.
Therefore higher quality corelates with higher prices.
Budget restaurants despite having the most number of restaurant has the lowest votes and lowest rating.
Expensive restaurant help to find the right balance with the most amount of votes, good average rating, cost less than premium and good quality also.*/

-- Comparison with Online delivery
select has_online_delivery,
count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
sum(votes) as total_votes,
round(avg(average_cost_for_two),0) as avg_cost_for_two
from zomato_restaurants group by has_online_delivery order by has_online_delivery desc;
/*Here we can see that online delivery has lesser number of restaurants as compared to restaurants with no online delivery
but the rating for both of them doesnt make much difference but surprisingly online delivery restaurants cost less as compared to 
restaurants with no online delivery*/

-- Comparison with table booking
select has_table_booking,
count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
sum(votes) as total_votes,
round(avg(average_cost_for_two),0) as avg_cost_for_two
from zomato_restaurants group by has_table_booking order by has_table_booking desc;
/*Here we can see that restaurants with reservations has a higher rating and also has higher cost despite having lesser
number of restaurants
table booking = fine dining = higher quality = better ratings*/

/* from both the table we can see that how serving customers has better rewards and ratings than deliverying food to the customers*/

-- Cuisines rating analysis by aggregate_rating
select cuisines,
count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
round(avg(average_cost_for_two),0) as avg_cost_for_two,
sum(votes) as total_votes from zomato_restaurants
where cuisines is not NULL
group by cuisines
having count(*)>=10 order by avg_rating desc limit 15; 
/*From the analysis we can understand that Modern Indian even tho it only has a total of 11 restaurants has the highest rating
highest average cost and the highest total votes, you can also see that Italian restaurants,
cafe, continental have a good rating with very low competition. 
This shows that customers experience and rarity matters than the quantity of resturants. */ 

-- Cusines rating by restaurant count
select cuisines,
count(*) as total_restaurants,
round(avg(aggregate_rating),2) as avg_rating,
round(avg(average_cost_for_two),0) as avg_cost_for_two,
sum(votes) as total_votes from zomato_restaurants
where cuisines is not NULL 
group by cuisines having count(*)>=10
order by total_restaurants desc limit 15;
/* From the analysis we can see that North Indian ratings are lower than Modern Indian despite having
more number of restaurants and at reduced cost, here the customer engagment for North Indian is lower as compared to Modern Indian.
This tells us that oversaturated and crowded restaurants can often result in mediocre performance.
In Indian delivery food market scarcity combined with quality consistently outperforms volume*/

-- Analyse rating from each city
select city, 
count(*) as total_restaurant,
round(avg(aggregate_rating),2) as avg_rating,
round(avg(average_cost_for_two),0) as avg_cost_for_two,
max(average_cost_for_two) as max_cost,
min(average_cost_for_two) as min_cost,
sum(votes) as total_votes from zomato_restaurants
group by city having count(*)>=20
order by avg_cost_for_two desc limit 10;
/*From the analysis we can see that Bangalore has the highest avg rating and has the strongest customer engagement
despite being only the 4th most expensive city. Chennai has the second highest rating with only 7th highest average cost providing 
best value proposition outperforming cities that charge significantly more.
Ludhiana is underperforming with low average rating despite having cost higher than Chennai, 
Agra shows 0 minimum cost and has the highest maximum cost*/

/*DataWarehousing and ETL*/
show tables;
create table DIM_City(city_id int primary key auto_increment, city_name varchar(100));
create table DIM_Cuisine(cuisine_id int primary key auto_increment, cuisine_name varchar(200));
create table DIM_PriceRange(price_range_id int primary key, price_category varchar(20), price_label varchar(10));
create table DIM_Features(feature_id int primary key auto_increment, has_online_delivery varchar(5), has_table_booking varchar(5));

insert into DIM_City(city_name) select distinct city from zomato_restaurants order by city;
insert into DIM_Cuisine(cuisine_name) select distinct cuisines from zomato_restaurants where cuisines is not null order by cuisines;
insert into DIM_PriceRange (price_range_id, price_category, price_label)
values(1, 'Budget', '₹'),
    (2, 'Moderate', '₹₹'),
    (3, 'Expensive', '₹₹₹'),
    (4, 'Premium', '₹₹₹₹');
insert into DIM_Features (has_online_delivery, has_table_booking) select distinct has_online_delivery, has_table_booking from zomato_restaurants;

CREATE TABLE FACT_Restaurants (
    fact_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    city_id INT,
    cuisine_id INT,
    price_range_id INT,
    feature_id INT,
    aggregate_rating DECIMAL(3,1),
    average_cost_for_two INT,
    votes INT,
    FOREIGN KEY (city_id) REFERENCES DIM_City(city_id),
    FOREIGN KEY (cuisine_id) REFERENCES DIM_Cuisine(cuisine_id),
    FOREIGN KEY (price_range_id) REFERENCES DIM_PriceRange(price_range_id),
    FOREIGN KEY (feature_id) REFERENCES DIM_Features(feature_id)
);
INSERT INTO FACT_Restaurants (
    restaurant_id,
    city_id,
    cuisine_id,
    price_range_id,
    feature_id,
    aggregate_rating,
    average_cost_for_two,
    votes
)
SELECT 
    r.restaurant_id,
    c.city_id,
    cu.cuisine_id,
    p.price_range_id,
    f.feature_id,
    r.aggregate_rating,
    r.average_cost_for_two,
    r.votes
FROM zomato_restaurants r
JOIN DIM_City c ON r.city = c.city_name
JOIN DIM_Cuisine cu ON r.cuisines = cu.cuisine_name
JOIN DIM_PriceRange p ON r.price_range = p.price_range_id
JOIN DIM_Features f ON r.has_online_delivery = f.has_online_delivery AND r.has_table_booking = f.has_table_booking;

select count(*) from fact_restaurants;
select count(*) from zomato_restaurants;
select count(*) from DIM_City;
select count(*) from DIM_Cuisine;
select count(*) from DIM_PriceRange;
select count(*) from DIM_Features;

SELECT c.city_name,COUNT(*) AS total_restaurants,ROUND(AVG(f.aggregate_rating), 2) AS avg_rating,ROUND(AVG(f.average_cost_for_two), 0) AS avg_cost
FROM FACT_Restaurants f JOIN DIM_City c ON f.city_id = c.city_id GROUP BY c.city_name ORDER BY avg_rating DESC LIMIT 10;
