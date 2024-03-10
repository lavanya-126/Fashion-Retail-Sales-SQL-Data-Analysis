WITH 
    RFM_Data AS (
        SELECT 
            Customer_Reference_ID,
            MAX(Date_Purchase) AS last_purchase_date,
            COUNT(DISTINCT Date_Purchase) AS frequency,
            ROUND(AVG(Purchase_Amount_USD), 2) AS avg_purchase_amount,
            SUM(Purchase_Amount_USD) AS total_purchase_amount
        FROM 
            Fashion_retail.sales
        GROUP BY 
            Customer_Reference_ID
    ),
    RFM_Scores AS (
        SELECT 
            rd.Customer_Reference_ID,
            DATE_PART('day', TIMESTAMP '2023-11-01' - rd.last_purchase_date) AS recency,
            rd.frequency,
            rd.avg_purchase_amount,
            rd.total_purchase_amount,
            NTILE(4) OVER (ORDER BY DATE_PART('day', TIMESTAMP '2023-11-01' - rd.last_purchase_date)) AS R_score,
            NTILE(4) OVER (ORDER BY rd.frequency ) AS F_score,
            NTILE(4) OVER (ORDER BY rd.total_purchase_amount ) AS M_score
        FROM 
            RFM_Data rd
    )

SELECT 
    *,
    CASE 
        WHEN R_score = 4 AND (F_score = 4 OR F_score = 3) 
			  AND (M_score = 4 OR M_score = 3) 
			  THEN 'Churned-Best'
        WHEN R_score = 4 AND (F_score = 3 OR F_score = 2) 
			  AND (M_score < 4) 
			  THEN 'Lost'
		WHEN R_score = 3 AND (F_score = 4 OR F_score = 3) 
			  AND (M_score = 2 OR M_score = 1) 
			  THEN 'Declining'
		WHEN R_score = 3 AND (F_score = 4 OR F_score = 3) 
			  AND (M_score = 4 OR M_score = 3) 
			  THEN 'Slipping-Best'
		WHEN (R_score = 2 OR R_score = 1) AND (F_score = 4 OR F_score = 3) 
			  AND (M_score = 3 OR M_score = 2 OR M_score = 1) 
			  THEN 'Active-Loyal'
		WHEN R_score = 2 OR R_score = 1 AND (F_score = 1) 
			  AND (M_score < 4) 
			  THEN 'New'
		WHEN R_score = 1 AND (F_score = 4) 
			  AND (M_score = 4) 
			  THEN 'Best'
		WHEN R_score = 4 OR R_score = 3 AND (F_score = 1) 
			  AND (M_score < 4) 
			  THEN 'One-Time'
		WHEN R_score = 2 AND (F_score = 2) 
			  AND (M_score = 4 OR M_score = 3) 
			  THEN 'Potential'
        ELSE 'Regular'
    END AS Customer_RFM_segment
FROM 
    RFM_Scores;
