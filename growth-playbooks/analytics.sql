WITH UserFirstTx AS (
    SELECT 
        "from" AS wallet_address,
        MIN(block_time) AS first_interaction_time
    FROM ethereum.transactions
    WHERE "to" = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84
    GROUP BY 1
),
ActivityLog AS (
    SELECT 
        t."from" AS wallet_address,
        DATE_TRUNC('day', t.block_time) AS activity_date,
        DATE_TRUNC('day', f.first_interaction_time) AS cohort_date
    FROM ethereum.transactions t
    JOIN UserFirstTx f ON t."from" = f.wallet_address
    WHERE t."to" = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84
)
SELECT 
    cohort_date,
    COUNT(DISTINCT wallet_address) AS cohort_size,
    COUNT(DISTINCT CASE WHEN activity_date = date_add('day', 1, cohort_date) THEN wallet_address END) AS day_1_retained,
    COUNT(DISTINCT CASE WHEN activity_date = date_add('day', 7, cohort_date) THEN wallet_address END) AS day_7_retained,
    COUNT(DISTINCT CASE WHEN activity_date = date_add('day', 30, cohort_date) THEN wallet_address END) AS day_30_retained
FROM ActivityLog
GROUP BY 1
ORDER BY 1 DESC;
