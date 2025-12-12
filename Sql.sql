create database coffee_shop_sales_db;

describe coffee_shop_sales;

update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%e/%c/%Y'); -- '%d/%m/%Y pattern is for 01/02/2023'

alter table coffee_shop_sales
modify column transaction_date date; -- future inserts must be valid dates

-- same doing for transaction_time as well
update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

-- calculate the total sale for each respective month
select month(transaction_date), round(sum(transaction_qty*unit_price)) as sale_per_month
from coffee_shop_sales
group by month(transaction_date) WITH ROLLUP;

-- m-o-m increase or descrease in sale
select month(transaction_date), 
lag(month(transaction_date)) over (order by month(transaction_date)) 
from coffee_shop_sales
group by month(transaction_date);

select month(transaction_date), 
round((sum(transaction_qty*unit_price))) as total_sales,
round(((sum(transaction_qty*unit_price) - lag(sum(transaction_qty*unit_price)) over (order by month(transaction_date)))
/ lag(sum(transaction_qty*unit_price)) over (order by month(transaction_date))) * 100) as mom_percent
from coffee_shop_sales
group by month(transaction_date)
order by month(transaction_date);


-- total number of orders month wise
select month(transaction_date), count(transaction_id)
from coffee_shop_sales
group by month(transaction_date);


-- calculate mom increase or decrease in the order
select month(transaction_date), 
count(transaction_id) as currect_month_orders, 
round((count(transaction_id) - lag(count(transaction_id)) over (order by month(transaction_date))/
lag(count(transaction_id)) over (order by month(transaction_date))) * 100) as order_percent
from coffee_shop_sales
group by month(transaction_date)
order by month(transaction_date);


-- heat map requirement check
select 
concat(round(count(transaction_id)/1000,1), 'k') AS Total_order, 
(sum(transaction_qty)) as total_quantity,
sum(unit_price*transaction_qty) as total_sale
from coffee_shop_sales
where transaction_date = '2023-03-27';

-- off day and on day questions
select 
case when dayofweek(transaction_date) in (1,7) then 'Weekend'
else 'Weekdays'
end as day_type,
round(sum(unit_price*transaction_qty)) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by case when dayofweek(transaction_date) in (1,7) then 'Weekend'
else 'Weekdays'
end;


-- sales location wise
select store_location, 
round(sum(unit_price*transaction_qty)) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5 -- may month
group by store_location
order by sum(unit_price*transaction_qty) desc;


-- average sales per day
SELECT AVG(total_sales) AS Avg_Sales
FROM (
    SELECT SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY transaction_date
) AS Internal_query;


-- avergae sales per transaction
SELECT AVG(unit_price * transaction_qty) AS Avg_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;


-- total sales per day of may month
select day(transaction_date) as day_of_month,
sum(unit_price*transaction_qty) as total_sales
from coffee_shop_sales
group by day(transaction_date);


-- comparison of day sales with the average sale
select sale_day,
case when sale_avg > sale_total then 'Less than Avg'
     when sale_avg < sale_total then 'More than Avg'
     else 'equal'
     end as sales_status
from (select day(transaction_date) sale_day, 
			sum(unit_price*transaction_qty) as sale_total,
            avg(sum(unit_price*transaction_qty)) over () as sale_avg 
            from coffee_shop_sales
            where month(transaction_date) = 5
            group by day(transaction_date)) as internal_query;


-- sales by product category
select * from coffee_shop_sales;
select product_category, 
round(sum(unit_price*transaction_qty)) as total_sale
from coffee_shop_sales
where month(transaction_date) = 5 -- for may month
group by product_category
order by sum(unit_price*transaction_qty) desc
limit 10;

-- sale by product type
select product_type, 
round(sum(unit_price*transaction_qty)) as total_sale
from coffee_shop_sales
where month(transaction_date) = 5 -- for may month
group by product_type
order by sum(unit_price*transaction_qty) desc
limit 10;

-- quantity, sale and total_orders per hour of per day
select 
round(sum(unit_price*transaction_qty)) as total_sale,
round(sum(transaction_qty)) as total_quantity,
count(*) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5 -- may month
and dayofweek(transaction_date) = 2 -- monday
and hour(transaction_time) = 8; -- hour number is 8

-- peak hours of the coffee shop 
select hour(transaction_time),
round(sum(unit_price*transaction_qty)) as total_sale,
round(sum(transaction_qty)) as total_quantity,
count(*) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5 -- may month
group by hour(transaction_time)
order by round(sum(unit_price*transaction_qty)) desc;

-- week wise peak sale of the coffee shop
select week(transaction_date),
round(sum(unit_price*transaction_qty)) as total_sale,
round(sum(transaction_qty)) as total_quantity,
count(*) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5 -- may month
group by week(transaction_date)
order by round(sum(unit_price*transaction_qty)) desc;

-- sale by day of the week
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- may month
GROUP BY Day_of_Week;










