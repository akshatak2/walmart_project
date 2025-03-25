SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

-- What are the payment methods used?

SELECT DISTINCT payment_method FROM walmart;

-- How many payments were done using this methods?

SELECT 
   payment_method,
   COUNT(*)
FROM walmart
GROUP BY payment_method;

-- Number of branches?

SELECT 
   COUNT(DISTINCT branch)
FROM walmart;

--Number of quantities
SELECT MAX(quantity) FROM walmart;


-- What are the different payment methods, and how many transactions and items were sold with each method?

SELECT 
   payment_method,
   COUNT(*) AS no_of_payments,
   SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Which category received the highest average rating in each branch?

SELECT *
FROM
(	SELECT 
	    branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as RANK
	FROM walmart
	GROUP BY 1, 2
)
WHERE RANK = 1


-- What is the busiest day of the week for each branch based on transaction volume?

SELECT *
FROM
	(SELECT 
			branch,
			TO_CHAR(TO_DATE(date,'DD/MM/YY'), 'Day') as day_name,
			COUNT(*) as no_transactions,
			RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC ) as rank
		FROM walmart
		GROUP BY 1, 2 
		)
WHERE rank = 1

-- How many items were sold through each payment method?

SELECT 
   payment_method,
   SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2

-- What is the total profit for each category, ranked from highest to lowest?

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1

-- What is the most frequently used payment method in each branch?

WITH abc
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_transaction,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2)
SELECT * FROM abc
WHERE RANK = 1

-- How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT
	branch,
CASE 
	    WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2 
ORDER BY 1, 3 DESC

--  Which 5 branches experienced the largest decrease in revenue compared to the previous year?

--rdr == last_rev - cr_rev/ls_rev*100


SELECT *,

EXTRACT( YEAR FROM TO_DATE(date,'DD/MM/YY')) as formatted_date

FROM walmart

--2022 sales
WITH revenue_2022
AS
	(SELECT 
		branch,
		SUM (total) as revenue
	FROM walmart
	WHERE EXTRACT( YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
	GROUP BY 1),

--2023 sales
	revenue_2023
AS
	(SELECT 
		branch,
		SUM (total) as revenue
	FROM walmart
	WHERE EXTRACT( YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
	GROUP BY 1)


SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND((ls.revenue - cs.revenue):: numeric/ ls.revenue :: numeric * 100, 2) as revenue_decrease_ratio
FROM revenue_2022 as ls
JOIN 
revenue_2023 as cs 
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5


