There ARE missing DATE-_OF_BIRTH AND SOME OF the people have DEFAULT DATA value '01-JAN-00'
Business wants TO know  18-25 , 26-50 AND OVER 50 years THEN OTHERS ARE remared AS unclassified

IN the gender field also, there ARE M FOR Male AND F FOR Female and OTHERS will be unclassified 

There need TO be filterd OUT which IS NOT HAVING IN other TABLE.

FINAL RESULT must be Count OF Age GROUP based ON gender

With CTE_COUNT AS
(   SELECT 
        C.CUSTOMER_NO AS CIF_NO,
        CASE WHEN P.SEX IN ('F','M') THEN P.SEX ELSE 'Unclassified' END AS SEX,
        P.DATE_OF_BIRTH AS DATE_OF_BIRTH,
        round((SYSDATE - DATE_OF_BIRTH)/365) AGE, 
        CASE 
            WHEN DATE_OF_BIRTH='01-JAN-00' THEN 'Unclassified'
        ELSE
            CASE
            WHEN round((SYSDATE - DATE_OF_BIRTH)/365) BETWEEN 18 AND 25 THEN '18-25 Years Old'
            WHEN round((SYSDATE - DATE_OF_BIRTH)/365) BETWEEN 26 AND 50 THEN '26-50 Years Old'
            WHEN round((SYSDATE - DATE_OF_BIRTH)/365) >= 50 THEN 'Over 50 Years Old'
            ELSE 'Unclassified'
            END
        END AS AGE_GROUP
    FROM CUSTOMERS 
    LEFT JOIN CUSTOMER_PERSONAL P ON P.CUSTOMER_NO = C.CUSTOMER_NO
    WHERE C.CUSTOMER_NO NOT IN (
        SELECT CUSTOMER_NO 
        FROM CUSTOMER_SEGMENT_LOOKUP 
        WHERE DATE_REF = TO_DATE('31-MAY-24', 'DD-MON-YY')
    )
)
SELECT 
     AGE_GROUP,SEX,Count(AGE_GROUP)
from CTE_COUNT
    GROUP BY AGE_GROUP,SEX
    ORDER BY AGE_GROUP,SEX
    
    
  
  
  
  