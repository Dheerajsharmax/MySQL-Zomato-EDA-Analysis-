/*
============================================================
 ZOMATO SQL BUSINESS ANALYSIS
============================================================

Project:
    Zomato End-to-End Business Analysis using MySQL

Purpose:
    Answer real-world business questions using:
        - Customer data
        - Restaurant data
        - Order transaction data

Tables:
    1. customer
    2. restaurants
    3. orders

Relationship:
    customer.customer_id
          |
          | 1 : Many
          v
    orders.customer_id

    restaurants.restaurant_id
          |
          | 1 : Many
          v
    orders.restaurant_id

SQL Dialect:
    MySQL 8+

Skills Covered:
    SELECT, WHERE, GROUP BY, HAVING, ORDER BY
    JOINs, CASE, CTEs, Subqueries
    Window Functions
    RANK, DENSE_RANK, NTILE, LAG
    Business KPIs and Analytics

============================================================
 TABLE STRUCTURE
============================================================

customer
---------
customer_id
customer_name
city
signup_time
acquisition_channel

restaurants
-----------
restaurant_id
restaurant_name
cuisine
city
avg_rating

orders
------
order_id
customer_id
restaurant_id
order_timestamp
order_amount
discount_amount
delivery_fee
payment_mode
order_status

============================================================
*/

-- ==========================================================
-- 01. TOTAL NUMBER OF CUSTOMERS
-- Business Question:
-- What is the total number of customers?
-- ==========================================================

SELECT
    COUNT(*) AS total_customers
FROM customer;


-- ==========================================================
-- 02. TOTAL NUMBER OF RESTAURANTS
-- Business Question:
-- How many restaurants are available?
-- ==========================================================

SELECT
    COUNT(*) AS total_restaurants
FROM restaurants;


-- ==========================================================
-- 03. TOTAL NUMBER OF ORDERS
-- Business Question:
-- What is the total number of orders?
-- ==========================================================

SELECT
    COUNT(*) AS total_orders
FROM orders;


-- ==========================================================
-- 04. TOTAL REVENUE
-- Business Question:
-- What is the total revenue generated from orders?
-- ==========================================================

SELECT
    ROUND(SUM(order_amount), 2) AS total_revenue
FROM orders;


-- ==========================================================
-- 05. AVERAGE ORDER VALUE
-- Business Question:
-- What is the Average Order Value (AOV)?
-- Formula:
-- AOV = Total Revenue / Total Orders
-- ==========================================================

SELECT
    ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders;


-- ==========================================================
-- 06. TOTAL DISCOUNT
-- Business Question:
-- What is the total discount given to customers?
-- ==========================================================

SELECT
    ROUND(SUM(discount_amount), 2) AS total_discount
FROM orders;


-- ==========================================================
-- 07. TOTAL DELIVERY FEE
-- Business Question:
-- What is the total delivery fee collected?
-- ==========================================================

SELECT
    ROUND(SUM(delivery_fee), 2) AS total_delivery_fee
FROM orders;


-- ==========================================================
-- 08. ORDER STATUS DISTRIBUTION
-- Business Question:
-- How many orders were delivered, cancelled, refunded, etc.?
-- ==========================================================

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- ==========================================================
-- 09. DELIVERY SUCCESS RATE
-- Business Question:
-- What percentage of orders were successfully delivered?
-- ==========================================================

SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'Delivered' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delivery_success_rate_percentage
FROM orders;


-- ==========================================================
-- 10. REVENUE BY CITY
-- Business Question:
-- Which cities generate the highest revenue?
-- ==========================================================

SELECT
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_revenue
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;


-- ==========================================================
-- 11. ORDERS BY CITY
-- Business Question:
-- Which city has the highest number of orders?
-- ==========================================================

SELECT
    c.city,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_orders DESC;


-- ==========================================================
-- 12. AOV BY CITY
-- Business Question:
-- What is the Average Order Value by city?
-- ==========================================================

SELECT
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY average_order_value DESC;


-- ==========================================================
-- 13. TOP RESTAURANTS BY REVENUE
-- Business Question:
-- Which restaurants generate the highest revenue?
-- ==========================================================

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS revenue
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine
ORDER BY revenue DESC
LIMIT 10;


-- ==========================================================
-- 14. TOP RESTAURANTS BY ORDER VOLUME
-- Business Question:
-- Which restaurants have the highest number of orders?
-- ==========================================================

SELECT
    r.restaurant_name,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC
LIMIT 10;


-- ==========================================================
-- 15. REVENUE BY CUISINE
-- Business Question:
-- Which cuisines generate the highest revenue?
-- ==========================================================

SELECT
    r.cuisine,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_revenue,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine
ORDER BY total_revenue DESC;


-- ==========================================================
-- 16. CUISINE RATING ANALYSIS
-- Business Question:
-- Which cuisines have the highest average restaurant rating?
-- ==========================================================

SELECT
    cuisine,
    ROUND(AVG(avg_rating), 2) AS average_rating,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY cuisine
HAVING COUNT(*) >= 3
ORDER BY average_rating DESC;


-- ==========================================================
-- 17. HIGH-RATED RESTAURANTS
-- Business Question:
-- Which restaurants have a rating above 4.0?
-- ==========================================================

SELECT
    restaurant_id,
    restaurant_name,
    cuisine,
    city,
    avg_rating
FROM restaurants
WHERE avg_rating > 4.0
ORDER BY avg_rating DESC;


-- ==========================================================
-- 18. HIGH-DEMAND / LOW-RATED RESTAURANTS
-- Business Question:
-- Which restaurants have high demand but low ratings?
-- ==========================================================

SELECT
    r.restaurant_name,
    r.avg_rating,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS revenue
FROM restaurants r
JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.avg_rating
HAVING
    COUNT(o.order_id) >= 200
    AND r.avg_rating < 4.0
ORDER BY total_orders DESC;


-- ==========================================================
-- 19. CUSTOMERS WITH MOST ORDERS
-- Business Question:
-- Which customers have placed the most orders?
-- ==========================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city
ORDER BY total_orders DESC
LIMIT 20;


-- ==========================================================
-- 20. HIGHEST-VALUE CUSTOMERS
-- Business Question:
-- Who are the highest-value customers?
-- ==========================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_spent,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city
ORDER BY total_spent DESC
LIMIT 20;


-- ==========================================================
-- 21. REPEAT CUSTOMER RATE
-- Business Question:
-- What percentage of customers are repeat customers?
-- Definition:
-- Repeat customer = customer with more than one order.
-- ==========================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate_percentage
FROM customer_orders;


-- ==========================================================
-- 22. REVENUE: ONE-TIME VS REPEAT CUSTOMERS
-- Business Question:
-- How much revenue comes from repeat customers vs one-time customers?
-- ==========================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN co.order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.order_amount), 2) AS revenue
FROM orders o
JOIN customer_orders co
    ON o.customer_id = co.customer_id
GROUP BY
    CASE
        WHEN co.order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END;


-- ==========================================================
-- 23. CUSTOMERS BY ACQUISITION CHANNEL
-- Business Question:
-- Which acquisition channel brings the most customers?
-- ==========================================================

SELECT
    acquisition_channel,
    COUNT(*) AS total_customers
FROM customer
GROUP BY acquisition_channel
ORDER BY total_customers DESC;


-- ==========================================================
-- 24. REVENUE BY ACQUISITION CHANNEL
-- Business Question:
-- Which acquisition channel generates the highest revenue?
-- ==========================================================

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    ROUND(SUM(o.order_amount), 2) AS revenue
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;


-- ==========================================================
-- 25. REVENUE PER CUSTOMER BY ACQUISITION CHANNEL
-- Business Question:
-- Which acquisition channel has the highest revenue per customer?
-- ==========================================================

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_amount), 2) AS revenue,
    ROUND(
        SUM(o.order_amount)
        / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;


-- ==========================================================
-- 26. PAYMENT MODE USAGE
-- Business Question:
-- Which payment mode is most popular?
-- ==========================================================

SELECT
    payment_mode,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS order_percentage
FROM orders
GROUP BY payment_mode
ORDER BY total_orders DESC;


-- ==========================================================
-- 27. REVENUE BY PAYMENT MODE
-- Business Question:
-- Which payment mode generates the highest revenue?
-- ==========================================================

SELECT
    payment_mode,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_amount), 2) AS revenue,
    ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders
GROUP BY payment_mode
ORDER BY revenue DESC;


-- ==========================================================
-- 28. MONTHLY REVENUE TREND
-- Business Question:
-- How does revenue change month by month?
-- ==========================================================

SELECT
    DATE_FORMAT(order_timestamp, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_amount), 2) AS revenue
FROM orders
GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
ORDER BY order_month;


-- ==========================================================
-- 29. HIGHEST-REVENUE MONTH
-- Business Question:
-- Which month generated the highest revenue?
-- ==========================================================

SELECT
    DATE_FORMAT(order_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(order_amount), 2) AS revenue
FROM orders
GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
ORDER BY revenue DESC
LIMIT 1;


-- ==========================================================
-- 30. MONTH-OVER-MONTH REVENUE GROWTH
-- Business Question:
-- What is the MoM revenue growth?
-- Uses LAG() window function.
-- ==========================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_timestamp, '%Y-%m') AS order_month,
        SUM(order_amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
),
revenue_with_previous AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage
FROM revenue_with_previous
ORDER BY order_month;


-- ==========================================================
-- 31. ORDERS BY DAY OF WEEK
-- Business Question:
-- Which day receives the most orders?
-- ==========================================================

SELECT
    DAYNAME(order_timestamp) AS order_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DAYNAME(order_timestamp)
ORDER BY total_orders DESC;


-- ==========================================================
-- 32. AVERAGE DISCOUNT PERCENTAGE
-- Business Question:
-- What is the average discount percentage?
-- ==========================================================

SELECT
    ROUND(
        AVG(
            discount_amount
            / NULLIF(order_amount, 0)
            * 100
        ),
        2
    ) AS average_discount_percentage
FROM orders;


-- ==========================================================
-- 33. RESTAURANTS WITH HIGHEST TOTAL DISCOUNTS
-- Business Question:
-- Which restaurants give the highest total discounts?
-- ==========================================================

SELECT
    r.restaurant_name,
    r.cuisine,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.discount_amount), 2) AS total_discount
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine
ORDER BY total_discount DESC
LIMIT 10;


-- ==========================================================
-- 34. DISCOUNT VS ORDER VALUE
-- Business Question:
-- Do higher-value orders receive larger discounts?
-- ==========================================================

SELECT
    CASE
        WHEN order_amount < 500 THEN 'Below 500'
        WHEN order_amount < 1000 THEN '500-999'
        WHEN order_amount < 1500 THEN '1000-1499'
        ELSE '1500+'
    END AS order_value_segment,

    COUNT(*) AS orders,

    ROUND(AVG(order_amount), 2) AS avg_order_value,

    ROUND(AVG(discount_amount), 2) AS avg_discount

FROM orders

GROUP BY
    CASE
        WHEN order_amount < 500 THEN 'Below 500'
        WHEN order_amount < 1000 THEN '500-999'
        WHEN order_amount < 1500 THEN '1000-1499'
        ELSE '1500+'
    END

ORDER BY avg_order_value;


-- ==========================================================
-- 35. RESTAURANTS WITH HIGHEST AOV
-- Business Question:
-- Which restaurants have the highest Average Order Value?
-- Minimum 20 orders avoids very small samples.
-- ==========================================================

SELECT
    r.restaurant_name,
    r.cuisine,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM restaurants r
JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine
HAVING COUNT(o.order_id) >= 20
ORDER BY average_order_value DESC
LIMIT 10;


-- ==========================================================
-- 36. TOP 3 RESTAURANTS IN EACH CITY BY REVENUE
-- Business Question:
-- Find the top 3 restaurants in every city.
-- Uses DENSE_RANK().
-- ==========================================================

WITH restaurant_revenue AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.restaurant_name,
        SUM(o.order_amount) AS revenue
    FROM restaurants r
    JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.restaurant_name
),
ranked_restaurants AS (
    SELECT
        city,
        restaurant_name,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM restaurant_revenue
)
SELECT
    city,
    restaurant_name,
    ROUND(revenue, 2) AS revenue,
    revenue_rank
FROM ranked_restaurants
WHERE revenue_rank <= 3
ORDER BY city, revenue_rank;


-- ==========================================================
-- 37. CUSTOMER RANKING BY SPENDING
-- Business Question:
-- Rank customers based on total spending.
-- ==========================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.order_amount) AS total_spent
    FROM customer c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spent, 2) AS total_spent,
    DENSE_RANK() OVER (
        ORDER BY total_spent DESC
    ) AS customer_rank
FROM customer_revenue
ORDER BY customer_rank;


-- ==========================================================
-- 38. CUSTOMERS SPENDING ABOVE AVERAGE
-- Business Question:
-- Find customers whose total spending is above the average customer.
-- Uses a subquery.
-- ==========================================================

SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.order_amount), 2) AS total_spent
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING SUM(o.order_amount) >
(
    SELECT AVG(customer_total)
    FROM (
        SELECT
            customer_id,
            SUM(order_amount) AS customer_total
        FROM orders
        GROUP BY customer_id
    ) x
)
ORDER BY total_spent DESC;


-- ==========================================================
-- 39. CUSTOMERS WHO NEVER ORDERED
-- Business Question:
-- Which registered customers have never placed an order?
-- ==========================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.acquisition_channel
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


-- ==========================================================
-- 40. RESTAURANTS WITH NO ORDERS
-- Business Question:
-- Which restaurants have never received an order?
-- ==========================================================

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.avg_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
WHERE o.restaurant_id IS NULL;


-- ==========================================================
-- 41. CITY REVENUE CONTRIBUTION
-- Business Question:
-- What percentage of total revenue comes from each city?
-- ==========================================================

WITH city_revenue AS (
    SELECT
        c.city,
        SUM(o.order_amount) AS revenue
    FROM orders o
    JOIN customer c
        ON o.customer_id = c.customer_id
    GROUP BY c.city
)
SELECT
    city,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0
        / SUM(revenue) OVER (),
        2
    ) AS revenue_percentage
FROM city_revenue
ORDER BY revenue DESC;


-- ==========================================================
-- 42. TOP 10% HIGHEST-SPENDING CUSTOMERS
-- Business Question:
-- Identify the top 10% of customers by spending.
-- Uses NTILE().
-- ==========================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(order_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
ranked AS (
    SELECT
        customer_id,
        total_spent,
        NTILE(10) OVER (
            ORDER BY total_spent DESC
        ) AS spending_decile
    FROM customer_revenue
)
SELECT
    customer_id,
    ROUND(total_spent, 2) AS total_spent
FROM ranked
WHERE spending_decile = 1
ORDER BY total_spent DESC;


-- ==========================================================
-- 43. BEST-PERFORMING RESTAURANT IN EACH CITY
-- Business Question:
-- Find each city's best-performing restaurant.
-- ==========================================================

WITH restaurant_city_revenue AS (
    SELECT
        r.city,
        r.restaurant_name,
        SUM(o.order_amount) AS revenue
    FROM restaurants r
    JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_name
),
ranked AS (
    SELECT
        city,
        restaurant_name,
        revenue,
        RANK() OVER (
            PARTITION BY city
            ORDER BY revenue DESC
        ) AS ranking
    FROM restaurant_city_revenue
)
SELECT
    city,
    restaurant_name,
    ROUND(revenue, 2) AS revenue
FROM ranked
WHERE ranking = 1
ORDER BY city;


-- ==========================================================
-- 44. RESTAURANTS ABOVE CITY AVERAGE REVENUE
-- Business Question:
-- Find restaurants whose revenue is above their city's
-- average restaurant revenue.
-- ==========================================================

WITH restaurant_revenue AS (
    SELECT
        r.city,
        r.restaurant_id,
        r.restaurant_name,
        SUM(o.order_amount) AS revenue
    FROM restaurants r
    JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    GROUP BY
        r.city,
        r.restaurant_id,
        r.restaurant_name
),
city_average AS (
    SELECT
        city,
        AVG(revenue) AS avg_city_restaurant_revenue
    FROM restaurant_revenue
    GROUP BY city
)
SELECT
    rr.city,
    rr.restaurant_name,
    ROUND(rr.revenue, 2) AS revenue,
    ROUND(ca.avg_city_restaurant_revenue, 2)
        AS city_average_revenue
FROM restaurant_revenue rr
JOIN city_average ca
    ON rr.city = ca.city
WHERE rr.revenue > ca.avg_city_restaurant_revenue
ORDER BY rr.city, rr.revenue DESC;


-- ==========================================================
-- 45. CUMULATIVE REVENUE
-- Business Question:
-- What is the cumulative revenue over time?
-- ==========================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_timestamp, '%Y-%m') AS order_month,
        SUM(order_amount) AS revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
)
SELECT
    order_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY order_month
        ),
        2
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY order_month;


/*
============================================================
 BUSINESS KPI FORMULAS
============================================================

1. Average Order Value (AOV)
   --------------------------------
   Total Revenue / Total Orders

2. Repeat Customer Rate
   --------------------------------
   Repeat Customers / Total Customers * 100

3. Revenue Per Customer
   --------------------------------
   Total Revenue / Unique Customers

4. Delivery Success Rate
   --------------------------------
   Delivered Orders / Total Orders * 100

5. Revenue Contribution
   --------------------------------
   Segment Revenue / Total Revenue * 100

6. Discount Percentage
   --------------------------------
   Discount Amount / Order Amount * 100

7. Month-over-Month Growth
   --------------------------------
   (Current Month Revenue - Previous Month Revenue)
   / Previous Month Revenue * 100


============================================================
 BUSINESS AREAS COVERED
============================================================

Revenue Analysis
Customer Analysis
Retention Analysis
Restaurant Analysis
Cuisine Analysis
City Analysis
Marketing / Acquisition Analysis
Discount Analysis
Payment Analysis
Order Status Analysis
Time-Series Analysis
Ranking Analysis
Customer Segmentation
Business Opportunity Analysis

============================================================
 END OF PROJECT
============================================================
*/

