-- Calculation of the mean and standard deviation of purchase_amount_usd
WITH Stats AS (
SELECT ROUND(AVG(purchase_amount_usd),2) AS mean,
	ROUND(STDDEV(purchase_amount_usd),2) AS stddev
FROM fashion_retail.sales
)
-- Calculation of Z-score for each value and to identify outliers
SELECT *,(purchase_amount_usd - mean) / stddev AS z_score
FROM fashion_retail.sales
JOIN Stats ON true
WHERE ABS((purchase_amount_usd - mean) / stddev) > 3;
