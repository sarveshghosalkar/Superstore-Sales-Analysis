select *
from superstore;

-- Q1: Total Sales by Region
select  "Region",
SUM("Sales") AS total_sales
from superstore
group by "Region"
order by total_sales DESC;

--Q2: Top 10 Best-Selling Products
SELECT "Product Name",
SUM("Sales") AS total_sales
FROM superstore
GROUP BY "Product Name"
ORDER BY total_sales DESC
LIMIT 10;

-- Q3: Unique Customers per Segment
SELECT 
    "Segment",
    COUNT(DISTINCT "Customer ID") AS unique_customers
FROM superstore
GROUP BY "Segment";


-- Q4: Monthly Sales Trend (Year-Month)
SELECT 
    DATE_TRUNC(
        'month', 
        TO_DATE("Order Date", 'DD/MM/YYYY')
    ) AS month,
    SUM("Sales") AS monthly_sales
FROM superstore
GROUP BY month
ORDER BY month;

-- Q5: Top Sub-Category Revenue within each Category
SELECT *
FROM (
    SELECT 
        "Category",
        "Sub-Category",
        SUM("Sales") AS total_sales,
        RANK() OVER (
            PARTITION BY "Category" 
            ORDER BY SUM("Sales") DESC
        ) AS rnk
    FROM superstore
    GROUP BY "Category", "Sub-Category"
) t
WHERE rnk = 1;

-- Q6: Average Shipping Delay by Ship Mode
-- (Days between Order Date and Ship Date)
SELECT 
    "Ship Mode",
    AVG(
        TO_DATE("Ship Date", 'DD/MM/YYYY') 
        - TO_DATE("Order Date", 'DD/MM/YYYY')
    ) AS avg_shipping_days
FROM superstore
GROUP BY "Ship Mode"
ORDER BY avg_shipping_days;


-- Q7: Top 5 Customers by Sales in each Region
-- (Window Function: RANK)
SELECT *
FROM (
    SELECT 
        "Region",
        "Customer Name",
        SUM("Sales") AS total_sales,
        RANK() OVER (
            PARTITION BY "Region" 
            ORDER BY SUM("Sales") DESC
        ) AS rnk
    FROM superstore
    GROUP BY "Region", "Customer Name"
) t
WHERE rnk <= 5;


-- Q8: Cumulative Sales Over Time (Running Total)
-- (Window Function: SUM OVER)
SELECT 
    "Order Date",
    SUM("Sales") AS daily_sales,
    SUM(SUM("Sales")) OVER (
        ORDER BY "Order Date"
    ) AS cumulative_sales
FROM superstore
GROUP BY "Order Date"
ORDER BY "Order Date";

-- Q9: States Underperforming vs National Average
-- (Subquery / CTE)
WITH state_sales AS (
    SELECT 
        "State",
        SUM("Sales") AS total_sales
    FROM superstore
    GROUP BY "State"
)
SELECT *
FROM state_sales
WHERE total_sales < (
    SELECT AVG(total_sales) FROM state_sales
);

-- Q10: Sales Contribution % by Category
-- (CTE + Ratio)
WITH category_sales AS (
    SELECT 
        "Category",
        SUM("Sales"::numeric) AS total_sales
    FROM superstore
    GROUP BY "Category"
),
overall AS (
    SELECT SUM(total_sales) AS grand_total
    FROM category_sales
)
SELECT 
    c."Category",
    c.total_sales,
    ROUND(c.total_sales * 100.0 / o.grand_total, 2) AS percentage_contribution
FROM category_sales c
CROSS JOIN overall o
ORDER BY percentage_contribution DESC;








