select *
from customers

select * 
from sales



/*                  1)  Sales Overview:

- What is the total revenue generated over the entire dataset?
- How does the average unit price vary across different product categories? */

select product_category, unit_price, quantity, (unit_price * Quantity) as Revenue
from Sales
order by revenue desc;


-- Total Rev
select round(sum(unit_price * quantity),2)
from sales;

select product_category, (sum( Unit_Price * quantity)) as rev_category
from sales
where product_category is not null
group by Product_Category;


--Average unit price
select Product_Category, avg(unit_price) as average_unit_price
from sales
where Product_Category is not null
group by Product_Category

select product_category, sub_category, avg(unit_price) as average_unit_price
from sales
where product_category is not null 
group by sub_category, product_category



/*
                     2)  Geographic Analysis:

- Which country has the highest total sales, and how does it compare to others?
- Can you identify states with the highest and lowest sales?

*/

select country, format(sum(Quantity * Unit_price), 'C') as sales
from sales
join customers as cus
on sales.id = cus.id
where country is not null
group by country
order by sum(Quantity * Unit_price) desc;

-- Using subqueries to accomplish the above
SELECT
    country,
    total_sales
FROM
    (
        SELECT
            country,
            SUM(quantity * unit_price) AS total_sales
        FROM
            Sales
        JOIN
            Customers ON Sales.id = Customers.id
        GROUP BY
            country
    ) AS country_sales
ORDER BY
    total_sales DESC

-- Finding country with highest sales

select top 1 country, format(sum(Quantity * Unit_price), 'C') as sales
from sales
join customers as cus
on sales.id = cus.id
where country is not null
group by country
order by sum(Quantity * Unit_price) desc;

--Total sales 

select  format(sum(Quantity * Unit_price), 'C') as sales
from sales
join customers as cus
on sales.id = cus.id
where country is not null



-- Can you identify states with the highest and lowest sales?

--highest sales
select  top 1 state, country, sum(quantity*unit_price) as highest_sales_per_state
from customers
join sales
on customers.id = sales.id
group by country,state
order by sum(quantity*unit_price) desc;

-- lowest sales
select  top 3 state, country, format(sum(quantity*unit_price),'N') as lowest_sales_per_state
from customers
join sales
on customers.id = sales.id
where state is not null
group by country,state
order by sum(quantity*unit_price)




-- verified which state had the amount of sales
select country, state, sum(quantity*unit_price) as sales_per_state
from customers
join sales
on customers.id = sales.id
group by country,state
order by sum(quantity*unit_price)  -- desc




/*                          3) Customer Insights:
 
What is the average age and gender distribution of the customer base?
Who are the top-spending customers, and what is their contribution to total revenue?
*/

select customer_gender, format(avg(customer_age),'N') as average_age
from Customers
where customer_gender is not null
group by customer_gender

select customer_gender, count(customer_gender)
from customers
group by customer_gender;


/*           4) Product Analysis:

Which product categories and subcategories are the best-selling and least-selling?
How does the unit cost and unit price vary across different products?
*/
		-- finding total revenue for each sub category
select product_category, sub_category, format(sum(unit_price * quantity), 'C') as total_rev_per_sub_category
from sales 
group by product_category, sub_category
order by sum(unit_price * quantity) desc

		-- figuring out total amount sold in each subcategory 
select product_category, sub_category, sum(quantity) as amount_sold
from sales 
where sub_category is not null
group by  sub_category, Product_Category
order by amount_sold desc

		-- Average unit cost and average unit price
select product_category, avg(unit_cost) as average_unit_cost, avg(unit_price) as average_unit_price
from sales
where product_category is not null
group by product_category


SELECT s1.product_category, s1.sub_category,
    AVG(s1.unit_cost) AS avg_unit_cost,
    AVG(s1.unit_price) AS avg_unit_price
	FROM Sales s1
GROUP BY s1.product_category, s1.sub_category;



/* 5. Temporal Analysis:
What are the monthly and yearly trends in sales quantity and revenue?
Is there any seasonality in product sales?   
*/

-- finding out which two months had the highest sales in both years

select c.Year, c.month, format(sum(Unit_price * Quantity), 'C') as total_sales
from customers as c
join sales as s
on c.id = s.id
where c.year is not null 
group by c.year, c.month
having sum(Unit_price * Quantity) = 
	(select 
	    MAX(total_monthly_sales)
        FROM
            (
                SELECT
                    c1.Year,
                    c1.Month,
                    SUM(s1.Unit_price * s1.Quantity) AS total_monthly_sales
                FROM
                    customers AS c1
                JOIN
                    sales AS s1 
					ON c1.id = s1.id
                WHERE
                    c1.Year IS NOT NULL
                GROUP BY
                    c1.Year, c1.Month
            ) AS Top_Monthly_Sales
		where Top_Monthly_Sales.year = c.year)
order by c.year, sum(Unit_price * Quantity) desc
;
-- Sales for each month by year

select c.Year, c.month, format(sum(Unit_price * Quantity), 'C') as total_sales
from customers as c
join sales as s
on c.id = s.id
where c.year is not null 
group by c.year, c.month
order by c.year, sum(Unit_price * Quantity) desc;

-- 

select c.Year, c.month, format(sum(Unit_price * Quantity), 'C') as total_sales
from customers as c
join sales as s
on c.id = s.id
where c.year is not null 
group by c.year, c.month
order by c.month


select case
	when sales.month in ('December', 'January', 'February') then 'Winter'
	when sales.month in ('March', 'April', 'May') then 'Spring'
	when sales.month in ('June', 'July', 'August') then 'Summer'
	when sales.month in ('September', 'October', 'November') then 'Fall'
end as sales_seasons,
    format(SUM(unit_price * quantity),'C') AS total_sales_amount,
	sales.year
from sales
where sales.year is not null
group by sales.year, case
	when sales.month in ('December', 'January', 'February') then 'Winter'
	when sales.month in ('March', 'April', 'May') then 'Spring'
	when sales.month in ('June', 'July', 'August') then 'Summer'
	when sales.month in ('September', 'October', 'November') then 'Fall'
end
order by sales.year, sales_seasons



/*             6. Price Analysis:
Can you identify products with the highest and lowest profit margins?
How does the unit price correlate with the quantity sold?
*/
-- looking at profits and revenues to help calculate gross profit margins
select product_category, sub_category,  sales.year
	,format(sum((Quantity * unit_price) - (quantity * unit_cost)),'C') as profit_per_sub_category
	--,(sum((Quantity * unit_price) - (quantity * unit_cost)) / sum(Unit_price * Quantity)) as Gross_Profit_Margins
	,format(sum(Quantity * unit_price), 'C') as revenue
from Sales
join customers
on sales.id = customers.id
where Product_Category is not null 
group by sub_category, Product_Category, sales.year
order by sales.year, sum((Quantity * unit_price) - (quantity * unit_cost)) desc
;

-- Gross profit margin for each subcategory by year
with cte as (
	select product_category, sub_category,  sales.year
	,sum((Quantity * unit_price) - (quantity * unit_cost)) as profit_per_sub_category
	,sum(quantity*unit_price) as revenue
from Sales
join customers
on sales.id = customers.id
where Product_Category is not null 
group by sub_category, Product_Category, sales.year
--order by sales.year, sum((Quantity * unit_price) - (quantity * unit_cost)) desc
	)
Select Product_category, sub_category, year
		, format((profit_per_sub_category/revenue),'P') as Gross_profit_margin	
from cte
group by year, Product_Category, Sub_Category, profit_per_sub_category, revenue
order by year, (profit_per_sub_category/revenue) desc




-- The average profit each sub category earns
with cte as (
	select product_category, sub_category,  sales.year
	,((Quantity * unit_price) - (quantity * unit_cost)) as profit_per_sub_category
	,(quantity*unit_price) as revenue
from Sales
join customers
on sales.id = customers.id
where Product_Category is not null 
--group by sub_category, Product_Category, sales.year
	--, quantity, Unit_Price, Unit_Cost
--order by sales.year, sum((Quantity * unit_price) - (quantity * unit_cost)) desc
	)
select product_category, sub_category, year, format(avg(revenue),'C3') as average_rev_earned_per_purchase
	, format(avg(profit_per_sub_category),'C3') as as_average_profit_per_purchase
from cte
group by Product_Category, Sub_Category, year
order by year


select max(unit_price), min(Unit_Price)
from sales


-- Price Correlation: Less sales as product is above 1500 dollars
select product_category,
	sum(case 
	when unit_price between 1 and 1500 then quantity
	end) as count_product
from sales
where product_category is not null
group by  Product_Category



select product_category,
	sum(case 
	when unit_price between 1500 and 3000 then quantity
	end) as count_product
from sales
where product_category is not null
group by  Product_Category