
drop table df_orders


CREATE TABLE df_orders(
       [order_id] int primary key 
	  ,[order_date] date
	  ,[ship_mode] varchar(20)
	  ,[segment]   varchar(20)
	  ,[country]   varchar(20)
	  ,[city]   varchar(20)
	  ,[state]   varchar(20)
	  ,[postal_code]   varchar(20)
	  ,[region]   varchar(20)
	  ,[category]   varchar(20)
	  ,[sub_category]   varchar(20)
	  ,[product_id]   varchar(20)
	  ,[quantity]   int
	  ,[discount]   decimal(7,2)
	  ,[sale_price] decimal(7,2)
	  ,[profit] decimal(7,2))


select * from df_orders



-------find top 10 highest revenue generating products

select top 10 product_id,SUM(sale_price) as sales
from df_orders
group by product_id
order by sales desc


--------find top 5 highest selling products in each region

WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT *
FROM (
    SELECT region, product_id, sales,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;


--------find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023

with cte as (
select year (order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year (order_date),month(order_date)
--order by year (order_date),month(order_date)
)

select  order_month 
, sum(case when order_year=2022 then sales else 0 end )as sales_2022
, sum(case when order_year=2023 then sales else 0 end )as sales_2023
from cte
group by order_month
order by order_month


--------- for each catagory which month had highest sales

with cte as(
select category,format(order_date , 'yyyy-MM') as order_year_month
, sum(sale_price) as sales
from df_orders
group by category , format(order_date , 'yyyy-MM') 
--order by category , format(order_date , 'yyyy-MM') 
)
select * from (
select *,
row_number() over (partition by category  order by sales desc) as rn
from cte
) a
where rn=1


------ which sub category had highest growth by profit in 2023  compare to 2022

select * from df_orders

with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc
