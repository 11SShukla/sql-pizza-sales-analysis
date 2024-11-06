-- I analyzed pizza sales data to uncover key trends and insights, identifying patterns in customer preferences, peak sales periods, and high-performing pizza varieties. These findings can inform targeted marketing strategies and optimize inventory management for increased profitability.

create database pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

-- Retrieve the total number of orders placed.
select count(order_id) from orders;
-- 21350

-- Calculate the total revenue generated from pizza sales.
select
 sum(order_details.quantity * pizzas.price) as total_sales
 from order_details join pizzas 
 on pizzas.pizza_id = order_details.pizza_id;
 -- 817860.049999993
 
--  Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by  pizzas.price desc limit 1;
-- The Greek Pizza = 35.95

-- Identify the most common pizza size ordered.
select quantity, count(order_details_id)
from order_details group by quantity;
select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count
desc limit 4;
-- most commonly ordered onces are L>M>S>SX

-- List the top 5 most ordered pizza types
--  along with their quantities.
select pizza_types.name,
sum(order_details.quantity) as total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by total_quantity
desc limit 5;
-- 1.The Classic Deluxe Pizza = 2453
-- 2.The Barbecue Chicken Pizza =2432
-- 3.The Hawaiian Pizza = 2422
-- 4.The Pepperoni Pizza = 2418
-- 5.The Thai Chicken Pizza = 2371

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as hour , count(order_id) as order_count from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as distribution from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) as average_order from 
(select orders.order_date, count(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity; 
-- 135.8101 
-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, 
sum(order_details.quantity*pizzas.price) as revenu
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenu  desc limit 3;
 
-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.name, 
(sum(order_details.quantity*pizzas.price)/ (select
round(sum(order_details.quantity*pizzas.price),2) as total_sale
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id) )*100 as revenu
 from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenu  desc limit 3;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from
(select category, name , revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;