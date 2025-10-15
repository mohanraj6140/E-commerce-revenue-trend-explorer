Create table
  
order_id INT,
order_date DATE,
state VARCHAR(50),
category VARCHAR(50),
sub_category VARCHAR(50),
sales DECIMAL(10,2),
quantity INT,
profit DECIMAL(10,2)


1.Basic Data Checks
a. Check for missing or null values

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM sales_data;

b. Count total records

SELECT COUNT(*) AS total_records FROM sales_data;

2. Overall KPIs

a. Total Sales, Quantity, and Profit

SELECT 
    ROUND(SUM(sales), 2) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales_data;

b. Profit Margin %

SELECT 
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_percent
FROM sales_data;

3. Sales Trend by Month

SELECT 
    DATENAME(MONTH, order_date) AS month_name,
    MONTH(order_date) AS month_number,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales_data
GROUP BY DATENAME(MONTH, order_date), MONTH(order_date)
ORDER BY month_number;

4. Sales vs Profit by Month

SELECT 
    DATENAME(MONTH, order_date) AS month_name,
    MONTH(order_date) AS month_number,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales_data
GROUP BY DATENAME(MONTH, order_date), MONTH(order_date)
ORDER BY month_number;

5. Sales and Profit by Category

SELECT 
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(sales) / (SELECT SUM(sales) FROM sales_data) * 100, 2) AS sales_percentage
FROM sales_data
GROUP BY category
ORDER BY total_sales DESC;

6. Top 10 States by Sales and Profit

SELECT TOP 10
    state,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_percent
FROM sales_data
GROUP BY state
ORDER BY total_sales DESC;
(If you’re using MySQL, replace TOP 10 with LIMIT 10.)

7. Category-wise Monthly Trend (Optional Drilldown)

SELECT 
    category,
    DATENAME(MONTH, order_date) AS month_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales_data
GROUP BY category, DATENAME(MONTH, order_date), MONTH(order_date)
ORDER BY category, MONTH(order_date);

8. Profitability Insights

a. Identify loss-making products or categories

SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM sales_data
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit;

b. Average Sales and Profit per Order

SELECT 
    ROUND(AVG(sales), 2) AS avg_sales_per_order,
    ROUND(AVG(profit), 2) AS avg_profit_per_order
FROM sales_data;

9. Monthly Growth Rate (Sales)

WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(sales) AS total_sales
    FROM sales_data
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    year,
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY year, month)) 
        / NULLIF(LAG(total_sales) OVER (ORDER BY year, month), 0) * 100, 2
    ) AS growth_percent
FROM monthly_sales;
