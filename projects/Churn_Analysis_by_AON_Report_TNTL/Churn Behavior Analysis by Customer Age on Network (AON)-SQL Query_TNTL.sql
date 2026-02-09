-- Active Base - Six Months

With ACTIVE_BASE AS

(
SELECT
TO_CHAR(TO_DATE(day_key::VARCHAR,'YYYYMMDD'),'YYYYMM') AS MONTH ,
msisdn,
actvtn_dt,
DATEDIFF(day,actvtn_dt::DATE,TO_DATE(day_key::VARCHAR,'YYYYMMDD')) AS AON
FROM snpsht_dly
WHERE day_key BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(DATE '2025-04-30', -6), 'YYYYMMDD')) AND '20250430'  --int - char to date
AND DORMANCY_DAY_CNT < 30 
AND CBS_STAT_CD <> 4

)
,
AON_GROUPED AS (           -- AON Group
SELECT 
     MONTH,
     MSISDN,
     DATEDIFF(day,actvtn_dt::DATE, TO_DATE(MONTH ||01,'YYYYMMDD')) AS AON,
     CASE WHEN DATEDIFF(day, actvtn_dt::DATE, TO_DATE(MONTH||01,'YYYYMMDD')) <270 THEN '<270' ELSE '>270' 
     END AS AON_GROUP
     FROM ACTIVE_BASE
)
,
MONTH_PAIRS AS (                     --- M0 current month  AND M1 = M0+1 
SELECT 
DISTINCT MONTH AS Month_M0, 
TO_CHAR(ADD_MONTHS(TO_DATE( MONTH||'01','YYYYMMDD'),1),'YYYYMM') AS Month_M1
FROM AON_GROUPED
WHERE MONTH < '202504'
)
,
PAIRED_ACTIVE AS (
    SELECT 
        MP.Month_M0,
        MP.Month_M1,
        AG0.MSISDN,    -- getting MSISDN for Current Month_M0
--        AG1.MSISDN,
        AG0.AON,       -- AON of focused month M0
        AG0.AON_GROUP,
        CASE 
            WHEN AG1.MSISDN IS NULL THEN 1 ELSE 0 
        END AS IS_CHURNED
    FROM MONTH_PAIRS MP
    JOIN AON_GROUPED AG0 ON AG0.MONTH = MP.Month_M0                                  -- JOIN with Month_M0 for current month 
    LEFT JOIN AON_GROUPED AG1 ON AG1.MONTH = MP.Month_M1 AND AG0.MSISDN = AG1.MSISDN -- JOIN with Month M1 for next month 
--    LEFT JOIN AON_GROUPED AG1 ON AG.MONTH = MP.MONTH_M1
)
,
CHURN_SUMMARY AS (                                  -- CHURN Summary
    SELECT
        AON_GROUP,
        COUNT(DISTINCT MSISDN) AS total_count,
        COUNT(DISTINCT CASE WHEN IS_CHURNED = 1 THEN MSISDN END) AS churned,
        COUNT(DISTINCT CASE WHEN IS_CHURNED = 0 THEN MSISDN END) AS not_churned,
        ROUND(AVG(AON)::DECIMAL, 2) AS avg_aon
    FROM PAIRED_ACTIVE
    GROUP BY AON_GROUP

)
SELECT 
    AON_GROUP,
    total_count,
    churned,
    not_churned,
    ROUND(churned::DECIMAL / total_count * 100, 2) AS churn_rate_pct,
    avg_aon
FROM CHURN_SUMMARY;

   

--------------------------------------------------------------------------------------------------------------------------


SELECT * FROM snpsht_dly LIMIT 10 ; 

-- Activity making Customers Active 
SELECT
    msisdn,
    day_key,
    dormancy_day_cnt,
    last_actvty_dt,
    last_cdr_actvty_typ,
    life_cycle_stat_cd,
    main_acct_bal,
    ecb_acct_bal
FROM snpsht_dly
WHERE dormancy_day_cnt = 0
  AND last_actvty_dt IS NOT NULL
  AND day_key BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(DATE '2025-04-30', -6), 'YYYYMMDD')) AND '20250430'  -- int - char to date
ORDER BY day_key DESC;



SELECT
    msisdn,
    day_key,
    dormancy_day_cnt,
    aon,
    last_cdr_actvty_typ,
    last_actvty_dt,
    inactvty_days_cnt
FROM snpsht_dly
WHERE msisdn = '95975xxxxxxx' -- random pick
  AND day_key BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(DATE '2025-04-30', -6), 'YYYYMMDD')) AND '20250430'
ORDER BY day_key DESC;


--- DATA 

-- Analyzing activity count by AON age grouped
SELECT
    CASE WHEN DATEDIFF(day,actvtn_dt::DATE,TO_DATE(day_key::VARCHAR,'YYYYMMDD')) < 270 THEN '<270' ELSE '>270' END AS aon_group,
    last_cdr_actvty_typ,
    COUNT(*) AS activity_count
FROM snpsht_dly
WHERE aon IS NOT NULL
  AND day_key BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(DATE '2025-04-30', -6), 'YYYYMMDD')) AND '20250430'  -- int - char to date 
GROUP BY 1, last_cdr_actvty_typ
ORDER BY aon_group, activity_count DESC;


SELECT DISTINCT msisdn
FROM snpsht_dly
WHERE last_cdr_actvty_typ = 'DATA'
  AND aon < 270
  AND day_key BETWEEN TO_NUMBER(TO_CHAR(ADD_MONTHS(DATE '2025-04-30', -6), 'YYYYMMDD')) AND '20250430'
 LIMIT 5;

