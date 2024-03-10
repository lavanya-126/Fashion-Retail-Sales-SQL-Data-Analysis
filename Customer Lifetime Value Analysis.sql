WITH 
    Purchase_frequency AS (
        SELECT 
            ROUND(COUNT(*) / COUNT(DISTINCT Customer_Reference_ID), 2) AS average_purchase_frequency_rate 
        FROM 
            Fashion_retail.sales
    ),
    Customer_CLTV AS (
        SELECT 
            Customer_Reference_ID,
            ROUND(AVG(Purchase_Amount_USD), 2) AS avg_purchase_value,
            COUNT(DISTINCT Date_Purchase) AS total_purchases,
            EXTRACT(DAY FROM AGE(MAX(Date_Purchase), MIN(Date_Purchase))) 
            + EXTRACT(MONTH FROM AGE(MAX(Date_Purchase), MIN(Date_Purchase))) * 30 
            AS customer_lifetime_days
        FROM 
            Fashion_retail.sales
        GROUP BY 
            Customer_Reference_ID
    ),
    Customer_Value AS (
        SELECT 
            c.Customer_Reference_ID,
            c.avg_purchase_value,
            ROUND(p.average_purchase_frequency_rate * c.avg_purchase_value, 2) AS customer_value,
            p.average_purchase_frequency_rate,
            c.customer_lifetime_days
        FROM 
            Customer_CLTV c
        CROSS JOIN 
            Purchase_frequency p
    ),
    Average_Customer_Lifetime AS (
        SELECT 
            ROUND(AVG(customer_lifetime_days) / 365, 2) AS avg_customer_lifetime_years
        FROM 
            Customer_CLTV
    )

SELECT 
    cv.Customer_Reference_ID,
    cv.avg_purchase_value,
    cv.average_purchase_frequency_rate,
    cv.customer_value,
    cv.customer_lifetime_days,
    acl.avg_customer_lifetime_years,
    ROUND(cv.customer_value * acl.avg_customer_lifetime_years, 2) AS cltv,
    CASE 
        WHEN cv.customer_value * acl.avg_customer_lifetime_years >= Q3 THEN 'High'
        WHEN cv.customer_value * acl.avg_customer_lifetime_years BETWEEN Q2 AND Q3 THEN 'Medium'
        ELSE 'Low'
    END AS cltv_segment
FROM 
    Customer_Value cv
CROSS JOIN 
    Average_Customer_Lifetime acl
CROSS JOIN (
    SELECT 
        percentile_cont(0.25) WITHIN GROUP (ORDER BY customer_value * acl.avg_customer_lifetime_years) AS Q1,
        percentile_cont(0.5) WITHIN GROUP (ORDER BY customer_value * acl.avg_customer_lifetime_years) AS Q2,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY customer_value * acl.avg_customer_lifetime_years) AS Q3
    FROM 
        Customer_Value cv
    CROSS JOIN 
        Average_Customer_Lifetime acl
) AS quartiles;
