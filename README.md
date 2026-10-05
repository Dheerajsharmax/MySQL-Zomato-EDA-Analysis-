# 🍽️ Zomato SQL Business Analysis

## 1. Project Introduction

This SQL project analyzes Zomato's customer, restaurant, and order data to answer real-world business questions.

### Dataset Tables

```text
customer
├── customer_id
├── customer_name
├── city
├── signup_time
└── acquisition_channel

restaurants
├── restaurant_id
├── restaurant_name
├── cuisine
├── city
└── avg_rating

orders
├── order_id
├── customer_id
├── restaurant_id
├── order_timestamp
├── order_amount
├── discount_amount
├── delivery_fee
├── payment_mode
└── order_status
```

### Table Relationships

```text
customer
   │
   │ customer_id
   ▼
orders
   │
   │ restaurant_id
   ▼
restaurants
```

---

# 📊 Business Questions & SQL Answers

## Q1. What is the total number of customers?

### Business Purpose
Understand the overall customer base.

```sql
SELECT 
    COUNT(*) AS total_customers
FROM customer;
```

---

# Q2. How many restaurants are available?

```sql
SELECT 
    COUNT(*) AS total_restaurants
FROM restaurants;
```

---

# Q3. What is the total number of orders?

```sql
SELECT 
    COUNT(*) AS total_orders
FROM orders;
```

---

# Q4. What is the total revenue generated from orders?

### Business Purpose
Measure overall sales performance.

```sql
SELECT 
    SUM(order_amount) AS total_revenue
FROM orders;
```

---

# Q5. What is the Average Order Value (AOV)?

### Formula

```text
AOV = Total Revenue / Total Orders
```

### SQL

```sql
SELECT 
    ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders;
```

---

# Q6. What is the total discount given to customers?

```sql
SELECT 
    ROUND(SUM(discount_amount), 2) AS total_discount
FROM orders;
```

---

# Q7. What is the total delivery fee collected?

```sql
SELECT 
    ROUND(SUM(delivery_fee), 2) AS total_delivery_fee
FROM orders;
```

---

# Q8. How many orders were delivered, cancelled and refunded?

### Business Purpose
Understand operational performance.

```sql
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
```

---

# Q9. What percentage of orders were successfully delivered?

### Formula

```text
Delivered Orders / Total Orders × 100
```

```sql
SELECT 
    ROUND(
        SUM(
            CASE 
                WHEN order_status = 'Delivered' THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delivery_success_rate
FROM orders;
```

---

# Q10. Which cities generate the highest revenue?

### Business Purpose
Identify the most valuable markets.

```sql
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_revenue
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;
```

---

# Q11. Which city has the highest number of orders?

```sql
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_orders DESC;
```

---

# Q12. What is the Average Order Value by city?

```sql
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY average_order_value DESC;
```

---

# Q13. Which restaurants generate the highest revenue?

### Business Purpose
Identify high-value restaurant partners.

```sql
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
```

---

# Q14. Which restaurants have the highest number of orders?

```sql
SELECT 
    r.restaurant_name,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC
LIMIT 10;
```

---

# Q15. Which cuisines generate the highest revenue?

```sql
SELECT 
    r.cuisine,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_revenue,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine
ORDER BY total_revenue DESC;
```

---

# Q16. Which cuisines have the highest average restaurant rating?

```sql
SELECT 
    cuisine,
    ROUND(AVG(avg_rating), 2) AS average_rating,
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY cuisine
HAVING COUNT(*) >= 3
ORDER BY average_rating DESC;
```

---

# Q17. Which restaurants have a rating above 4.0?

```sql
SELECT 
    restaurant_id,
    restaurant_name,
    cuisine,
    city,
    avg_rating
FROM restaurants
WHERE avg_rating > 4.0
ORDER BY avg_rating DESC;
```

---

# Q18. Find restaurants with high demand but low ratings.

### Business Question
Identify restaurants that receive many orders but may have customer-experience problems.

```sql
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
```

> `200` is a business threshold; adjust it according to your dataset.

---

# Q19. Which customers have placed the most orders?

```sql
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
```

---

# Q20. Who are the highest-value customers?

### Business Purpose
Identify customers contributing the most revenue.

```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_amount), 2) AS total_spent,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id,
    c.customer_name,
    c.city
ORDER BY total_spent DESC
LIMIT 20;
```

---

# Q21. What percentage of customers are repeat customers?

### Definition

A repeat customer is a customer who has placed **more than one order**.

```sql
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
    ) AS repeat_customer_rate
FROM customer_orders;
```

---

# Q22. Compare revenue generated by one-time vs repeat customers.

```sql
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
```

---

# Q23. Which acquisition channel brings the most customers?

```sql
SELECT 
    acquisition_channel,
    COUNT(*) AS total_customers
FROM customer
GROUP BY acquisition_channel
ORDER BY total_customers DESC;
```

---

# Q24. Which acquisition channel generates the highest revenue?

### Business Purpose
Customer count alone doesn't tell us which marketing channel is valuable.

```sql
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
```

---

# Q25. Which acquisition channel has the highest Revenue per Customer?

### Formula

```text
Revenue per Customer
=
Total Revenue / Unique Customers
```

```sql
SELECT 
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.order_amount), 2) AS revenue,
    ROUND(
        SUM(o.order_amount) / COUNT(DISTINCT c.customer_id),
        2
    ) AS revenue_per_customer
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;
```

---

# Q26. Which payment mode is most popular?

```sql
SELECT 
    payment_mode,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS order_percentage
FROM orders
GROUP BY payment_mode
ORDER BY total_orders DESC;
```

### Concept Used

**Window Function**

```sql
SUM(COUNT(*)) OVER ()
```

---

# Q27. Which payment mode generates the highest revenue?

```sql
SELECT 
    payment_mode,
    COUNT(*) AS total_orders,
    ROUND(SUM(order_amount), 2) AS revenue,
    ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders
GROUP BY payment_mode
ORDER BY revenue DESC;
```

---

# Q28. What is the monthly revenue trend?

```sql
SELECT 
    DATE_FORMAT(order_timestamp, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_amount), 2) AS revenue
FROM orders
GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
ORDER BY order_month;
```

---

# Q29. Which month generated the highest revenue?

```sql
SELECT 
    DATE_FORMAT(order_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(order_amount), 2) AS revenue
FROM orders
GROUP BY DATE_FORMAT(order_timestamp, '%Y-%m')
ORDER BY revenue DESC
LIMIT 1;
```

---

# Q30. What is the Month-over-Month revenue growth?

🔥 **Interview-level SQL**

```sql
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
        * 100.0 / previous_month_revenue,
        2
    ) AS mom_growth_percentage
FROM revenue_with_previous
ORDER BY order_month;
```

---

# Q31. Which day of the week receives the most orders?

```sql
SELECT 
    DAYNAME(order_timestamp) AS order_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DAYNAME(order_timestamp)
ORDER BY total_orders DESC;
```

---

# Q32. What is the average discount percentage?

```sql
SELECT 
    ROUND(
        AVG(
            discount_amount / NULLIF(order_amount, 0) * 100
        ),
        2
    ) AS average_discount_percentage
FROM orders;
```

---

# Q33. Which restaurants give the highest total discounts?

```sql
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
```

---

# Q34. Do higher-value orders receive larger discounts?

```sql
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
```

---

# Q35. Which restaurants have the highest Average Order Value?

```sql
SELECT 
    r.restaurant_name,
    r.cuisine,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_amount), 2) AS avg_order_value
FROM restaurants r
JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY 
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine
HAVING COUNT(o.order_id) >= 20
ORDER BY avg_order_value DESC
LIMIT 10;
```

---

# Q36. Find the top 3 restaurants in each city by revenue.

🔥 **Window Function — Interview Level**

```sql
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
```

---

# Q37. Rank customers based on total spending.

```sql
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
```

---

# Q38. Find customers who have spent more than the average customer.

🔥 **Subquery**

```sql
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
```

---

# Q39. Find customers who have never placed an order.

### Business Purpose
Identify inactive customers.

```sql
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.acquisition_channel
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
```

---

# Q40. Find restaurants that have never received an order.

```sql
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
```

---

# 🏆 Advanced SQL Business Questions

Ab thoda **Data Analyst Interview Level → Advanced** karte hain. 🔥

---

# Q41. What percentage of total revenue comes from each city?

```sql
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
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_percentage
FROM city_revenue
ORDER BY revenue DESC;
```

---

# Q42. Find the top 10% highest-spending customers.

```sql
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
```

---

# Q43. Find each city's best-performing restaurant.

```sql
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
WHERE ranking = 1;
```

---

# Q44. Find restaurants whose revenue is above their city's average restaurant revenue.

🔥 **Very good interview question**

```sql
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
```

---

# Q45. Calculate cumulative revenue over time.

```sql
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
```

---

# 📌 SQL Concepts Covered

This project gives you practical experience with:

### Basic SQL

- `SELECT`
- `WHERE`
- `ORDER BY`
- `LIMIT`
- `DISTINCT`

### Aggregation

- `COUNT`
- `SUM`
- `AVG`
- `MIN`
- `MAX`

### Grouping

- `GROUP BY`
- `HAVING`

### Joins

- `INNER JOIN`
- `LEFT JOIN`

### Advanced SQL

- `CASE`
- Subqueries
- CTE
- `WITH`
- `LAG()`
- `RANK()`
- `DENSE_RANK()`
- `NTILE()`
- `SUM() OVER()`
- `PARTITION BY`

### Business Analytics

- Revenue
- AOV
- Customer retention
- Repeat customers
- Revenue per customer
- Acquisition performance
- Discount analysis
- Restaurant performance
- City performance
- Cuisine analysis
- MoM growth
- Revenue contribution
- Customer segmentation

---
