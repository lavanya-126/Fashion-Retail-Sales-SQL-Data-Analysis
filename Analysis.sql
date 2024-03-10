--fashion_retail.sales dataset
SELECT * 
FROM fashion_retail.sales

--Daily Average Customers
SELECT ROUND(AVG(daily_count),0) AS average_daily_customers
FROM (
    SELECT COUNT(DISTINCT Customer_Reference_ID) AS daily_count
    FROM fashion_retail.sales
    GROUP BY DATE(Date_Purchase)
) AS daily_counts;

--Weekly Average Customers
SELECT ROUND(AVG(weekly_count),0) AS average_weekly_customers
FROM (
    SELECT COUNT(DISTINCT Customer_Reference_ID) AS weekly_count
    FROM fashion_retail.sales
    GROUP BY DATE_TRUNC('week', Date_Purchase)
) AS weekly_counts;

--Monthly Average Customers
SELECT ROUND(AVG(monthly_count),0) AS average_monthly_customers
FROM (
    SELECT COUNT(DISTINCT Customer_Reference_ID) AS monthly_count
    FROM fashion_retail.sales
    GROUP BY DATE_TRUNC('month', Date_Purchase)
) AS monthly_counts;

--Total Revenue: Calculation of the total revenue generated from all purchases.
SELECT SUM(Purchase_Amount_USD) AS total_revenue
FROM fashion_retail.sales;

--Average Purchase Amount: Calculation of average purchase amount per transaction.
SELECT ROUND(AVG(Purchase_Amount_USD),2) AS average_purchase_amount
FROM fashion_retail.sales;

--Number of Purchases per Customer: Count the number of purchases made by each customer.
SELECT Customer_Reference_ID, COUNT(*) AS purchase_count
FROM fashion_retail.sales
GROUP BY Customer_Reference_ID;

--Maximum and Minimum Purchase Amount: Identify the largest and smallest purchase amounts.
SELECT 
    MAX(Purchase_Amount_USD) AS max_purchase_amount,
    MIN(Purchase_Amount_USD) AS min_purchase_amount
FROM fashion_retail.sales;

--Distribution of Review Ratings: Analyze the distribution of review ratings.
SELECT 
    CASE 
        WHEN Review_Rating >= 1 AND Review_Rating < 2 THEN '1'
        WHEN Review_Rating >= 2 AND Review_Rating < 3 THEN '2'
        WHEN Review_Rating >= 3 AND Review_Rating < 4 THEN '3'
        WHEN Review_Rating >= 4 AND Review_Rating < 5 THEN '4'
		WHEN Review_Rating = 5 THEN '5'
        ELSE 'No Rating'
    END AS rating_range,
    COUNT(*) AS rating_count
FROM 
    fashion_retail.sales
GROUP BY 
    rating_range
ORDER BY 
    rating_range;
--Correlation Analysis :
SELECT 
    CORR(Purchase_Amount_USD, review_rating) AS Correlation
FROM 
    Fashion_Retail.Sales;

--Payment Method Distribution: Analyze the distribution of payment methods used.
SELECT Payment_Method, COUNT(*) AS payment_count
FROM fashion_retail.sales
GROUP BY Payment_Method;

--Most Popular Items: Determine the most frequently purchased items.
SELECT Item_Purchased, COUNT(*) AS purchase_count
FROM fashion_retail.sales
GROUP BY Item_Purchased
ORDER BY purchase_count DESC
LIMIT 10; 

--Pairs Analysis: Products that are frequently bought together by customers
SELECT 
    CONCAT(s1.Item_Purchased, ' & ', s2.Item_Purchased) AS product_combination,
    COUNT(*) AS frequency
FROM 
    Fashion_Retail.Sales s1
JOIN 
    Fashion_Retail.Sales s2 ON s1.Customer_Reference_ID = s2.Customer_Reference_ID
WHERE 
    s1.Item_Purchased < s2.Item_Purchased -- to avoid counting pairs twice
GROUP BY 
    s1.Item_Purchased,
    s2.Item_Purchased
ORDER BY 
    frequency desc
LIMIT 10;

--Date-Based Analysis (e.g., daily sales trends):
SELECT 
    date_purchase,
    SUM(Purchase_Amount_USD) AS Total_Sales
FROM 
    Fashion_Retail.Sales
GROUP BY 
    date_purchase
ORDER BY 
    date_purchase;

--Trend Analysis
-- Calculate a 7-day moving average for daily sales
SELECT 
    date_purchase,
	daily_sales,
    ROUND(AVG(daily_sales) OVER (ORDER BY date_purchase ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING),2) AS moving_avg_sales
FROM (
    SELECT date_purchase, SUM(purchase_amount_usd) AS daily_sales
    FROM fashion_retail.sales
    GROUP BY date_purchase
) AS daily_sales_data;

--Seasonality Analysis
-- Analyze month-over-month seasonality
SELECT 
    TO_CHAR(MAX(date_purchase), 'YYYY-MM-DD') AS max_date,
    EXTRACT(YEAR FROM MAX(date_purchase)) AS year,
	TO_CHAR(MAX(date_purchase), 'Month') AS month_name,
	SUM(purchase_amount_usd) AS monthly_sales
FROM fashion_retail.sales
GROUP BY EXTRACT(YEAR FROM date_purchase), EXTRACT(MONTH FROM date_purchase)
ORDER BY EXTRACT(YEAR FROM MAX(date_purchase)), EXTRACT(MONTH FROM MAX(date_purchase));




