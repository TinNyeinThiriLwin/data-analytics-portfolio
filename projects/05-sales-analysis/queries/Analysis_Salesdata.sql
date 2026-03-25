

-- Exploring the data -- 


select count(*) from sales_dataset.transactions limit 10;
select * from sales_dataset.products limit 10;
select * from sales_dataset.customers limit 10;   
select * from sales_dataset.stores limit 10;
select * from sales_dataset.salespersons limit 10;

SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.products;
SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.customers;
SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.stores;
SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.salespersons;

-- Checking Out Missing Values 

SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.transactions;
SELECT 
        COUNT(TransactionID),
        COUNT(ProductID),
        COUNT(CustomerID),
        COUNT(StoreID),
        COUNT(Date),
        COUNT(Quantity),
        COUNT(TotalAmount)
FROM sales_dataset.transactions;


select max(date) , min(date) from sales_dataset.transactions;
SELECT DISTINCT EXTRACT(YEAR FROM Date) FROM sales_dataset.transactions;

-- update the data 

--  2025,2026,2027   > 2020
--  2028,2029,2030   > 2021
--  2031,2032,2033   > 2022
--  2034,2035        > 2023

update sales_dataset.transactions SET Date = TIMESTAMP(DATETIME(CONCAT('2020-', FORMAT_TIMESTAMP('%m-%d %H:%M:%S', Date))))
WHERE EXTRACT(YEAR FROM Date) in (2025,2026,2027) ;


UPDATE sales_dataset.transactions
SET Date = TIMESTAMP(
  IF(
    FORMAT_TIMESTAMP('%m-%d', Date) = '02-29',
    CONCAT('2021-02-28 ', FORMAT_TIMESTAMP('%H:%M:%S', Date)),
    CONCAT('2021-', FORMAT_TIMESTAMP('%m-%d %H:%M:%S', Date))
  )
)
WHERE EXTRACT(YEAR FROM Date) IN (2028, 2029, 2030);



UPDATE sales_dataset.transactions
SET Date = TIMESTAMP(
  IF(
    FORMAT_TIMESTAMP('%m-%d', Date) = '02-29',
    CONCAT('2022-02-28 ', FORMAT_TIMESTAMP('%H:%M:%S', Date)),
    CONCAT('2022-', FORMAT_TIMESTAMP('%m-%d %H:%M:%S', Date))
  )
)
WHERE EXTRACT(YEAR FROM Date) IN (2031, 2032, 2033);


update sales_dataset.transactions SET Date = TIMESTAMP(DATETIME(CONCAT('2023-', FORMAT_TIMESTAMP('%m-%d %H:%M:%S', Date))))
WHERE EXTRACT(YEAR FROM Date) in (2034,2035) ;

UPDATE sales_dataset.transactions
SET Date = make_date(2024, EXTRACT(MONTH FROM Date), EXTRACT(DAY FROM Date))
WHERE EXTRACT(YEAR FROM Date) = 2023;


--  Sales overview --
select 
        round(sum(TotalAmount)) as Total_Sales_Amount,
        round(avg(TotalAmount)) as Avg_Sales_Amount,
        round(max(TotalAmount)) as Max_Sales_Amount,
        round(min(TotalAmount)) as Min_Sales_Amount
from sales_dataset.transactions ;

--Sales Overview Comparison with previous periods 
select 
        Extract(Year from Date) as Year,
        round(Sum(TotalAmount)) as Sales_Amount
from sales_dataset.transactions 
group by Extract  (Year from Date)
order by Sales_Amount desc ;



-----------------------------------------------------

--Total Sales Amount by Store --
select  S.StoreName,
        round(sum(T.TotalAmount))
From sales_dataset.transactions T
left join  sales_dataset.stores S
on T.StoreID = S.StoreID 
group by S.StoreName
order by S.StoreName;


-- Total Sales Amount by ProductCategory --
select  P.Category,
        T.ProductID,
        Sum(T.TotalAmount) as Sales_Amount
from sales_dataset.transactions T 
left join sales_dataset.products P 
     on T.ProductID = P.ProductID
group by P.Category, T.ProductID
order by P.Category, T.ProductID;


<<<<<<< HEAD
-- Top Ten Products Per Year 

with cte_top as
(
        
select 
        Extract (Year from Date) as Year ,
        ProductID,
        round(sum(TotalAmount)) as Sales_Amount,
from sales_dataset.transactions 
group by Year, ProductID
)
select 
        B.Year, 
        B.ProductID, 
        P.ProductName,
        B.rankproduct
from ( select Year, 
        ProductID, 
        row_number() over(partition by Year order by Sales_Amount) as rankproduct
from cte_top

) B 
left join sales_dataset.products P 
on B.ProductID = P.ProductID
where rankproduct <=10
order by Year, rankproduct;

=======
>>>>>>> acd80e0c16b40db7b93e39ed35977b2e528c8a79



-- Total Sales Amount by CustomerID --
select 
        S.SalespersonID,
        S.SalespersonName,
        round(sum(T.TotalAmount)) as Sales_Amount
From sales_dataset.salespersons S 
left join sales_dataset.transactions T
on T.StoreID = S.StoreID
group by S.SalespersonID,S.SalespersonName
order by S.SalespersonID,S.SalespersonName;



-- Total Sales over time  --
select 
      DATE(date) as sale_date,
      round(Sum(TotalAmount)) as total_sales
from sales_dataset.transactions
group by  sale_date
order by  sale_date; 


-- monthly Sales Trends 

select 
    format_date('%Y-%m', date) as sale_month,
    round(sum(TotalAmount)) as total_sales
FROM sales_dataset.transactions
group by sale_month
order by sale_month;

-- Quarterly Sales Trends 

select 
    CONCAT(CAST(EXTRACT(YEAR FROM DATE(date)) AS STRING), '-Q', CAST(EXTRACT(QUARTER FROM DATE(date)) AS STRING)) AS sale_quarter,
    round(sum(TotalAmount)) AS total_sales
from sales_dataset.transactions
group by sale_quarter
order by sale_quarter;


-- Total Sales by StoreName and Salesperson with rank -- 
with cte_sales as
(
select
      S.StoreName as StoreName,
      P.SalespersonID as SalespersonID,
      round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.stores S
left join sales_dataset.salespersons  P on S.StoreID = P.StoreID
left join sales_dataset.transactions T on P.StoreID = T.StoreID
group by S.StoreName,
         P.SalespersonID
)
select 
        row_number() over(order by Sales_Amount desc) as row,
        StoreName,
        SalespersonID,
        Sales_Amount
from cte_sales
order by row

--Total Sales by StoreName and Salesperson



-- Total Sales by locations --
select 
        S.Location,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.stores S
left join sales_dataset.transactions T
on T.StoreID = S.StoreID
group by Location
order by Location



-- Total Sales by Specific Location (Location starts with 'A' ) --

select 
        S.Location,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.stores S
left join sales_dataset.transactions T
on T.StoreID = S.StoreID
where Location like ('A%')
group by Location
order by Location

select 
        S.Location,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.stores S
left join sales_dataset.transactions T
on T.StoreID = S.StoreID
where Location = 'Boston'
group by Location


-----------------------------------------------------------------------------------------------------------------------------
-- Top selling products 

select 
        subquery.Category,
        subquery.ProductName,
        subquery.Sales_Amount
from 
(select 
        P.Category as Category,
        P.ProductName as ProductName,
        round(sum(T.TotalAmount)) as Sales_Amount,
        row_number() over ( order by sum(T.TotalAmount) desc) as rown
from sales_dataset.products P 
left join sales_dataset.transactions T
on P.ProductID = T.ProductID
group by Category,ProductName  
) as subquery
where subquery.rown = 1



--  Top selling products over time
select 
        date_trunc('month', T.Date) as Sales_Month, 
        P.Category,
        P.ProductName,
        sum(T.TotalAmount) as Sales_Amount
from sales_dataset.transactions T 
left join sales_dataset.products P on T.ProductID = P.ProductID 
group by Sales_Month,Category,ProductName
order by Sales_Month,Category,ProductName



(select 
        P.Category as Category,
        P.ProductName as ProductName,
        round(sum(T.TotalAmount)) as Sales_Amount,
        row_number() over ( partition by P.Category order by sum(T.TotalAmount) desc) as rown
from sales_dataset.products P 
left join sales_dataset.transactions T
on P.ProductID = T.ProductID
group by Category,ProductName  
) as subquery
where subquery.rown = 1


<<<<<<< HEAD
=======

----------------------


-- Top Ten Products Per Year 

with cte_top as
(
        
select 
        Extract (Year from Date) as Year ,
        ProductID,
        round(sum(TotalAmount)) as Sales_Amount,
from sales_dataset.transactions 
group by Year, ProductID
)
select 
        B.Year, 
        B.ProductID, 
        P.ProductName,
        B.rankproduct
from ( select Year, 
        ProductID, 
        row_number() over(partition by Year order by Sales_Amount) as rankproduct
from cte_top

) B 
left join sales_dataset.products P 
on B.ProductID = P.ProductID
where rankproduct <=10
order by Year, rankproduct;


>>>>>>> acd80e0c16b40db7b93e39ed35977b2e528c8a79
-- Top selling products per Category
select 
        subquery.Category,
        subquery.ProductName,
        subquery.Sales_Amount
from 
(select 
        P.Category as Category,
        P.ProductName as ProductName,
        round(sum(T.TotalAmount)) as Sales_Amount,
        row_number() over ( partition by P.Category order by sum(T.TotalAmount) desc) as rown
from sales_dataset.products P 
left join sales_dataset.transactions T
on P.ProductID = T.ProductID
group by Category,ProductName  
) as subquery
where subquery.rown = 1


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Customer segmentation and behaviours --

-- Total spent amount per customer 
SELECT 
        C.CustomerID, 
        C.CustomerName, 
        round(SUM(T.TotalAmount)) AS total_spent, 
        MIN(T.Date) AS first_purchase, 
        MAX(T.Date) AS last_purchase
FROM sales_dataset.customers C
left join sales_dataset.transactions T
on C.CustomerID = T.CustomerID
group by CustomerID, CustomerName;



-- Customer Lifetime Value --
select 
        C.CustomerID,
        C.CustomerName,
        round(sum(T.TotalAmount)) as Lifetime_Value
from sales_dataset.customers C
left join sales_dataset.transactions T
on C.CustomerID = T.CustomerID
group by CustomerID,CustomerName
order by lifetime_value desc 


-- Spent amount by customer age and gender (Desc)
select 
        C.Age,
        C.Gender,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.transactions T
left join sales_dataset.customers C
on T.CustomerID = C.CustomerID 
where C.Age < 25 
group by Age, Gender
order by Sales_Amount desc

-- spent amount per specific age group --
select 
        case when C.Age >= 18 and C.Age <= 25 then '18-25 age group'
             when C.Age >= 26 and C.Age <= 50 then '26-50 age group'
        else 'Others'
        end as Age_Group,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.transactions T
left join sales_dataset.customers C
on T.CustomerID = C.CustomerID 
group by Age_Group
order by Sales_Amount Desc

-- spent amount per specific age group with gender --
select 
        case when C.Age >= 18 and C.Age <= 25 and C.Gender = 'Male' then 'Male : 18-25 age group'
             when C.Age >= 18 and C.Age <= 25 and C.Gender = 'Female' then 'Female : 18-25age group'
             when C.Age >= 26 and C.Age <= 50 and C.Gender = 'Male' then 'Male : 26-50 age group'
             when C.Age >= 26 and C.Age <= 50 and C.Gender = 'Female' then 'Female : 26-50 age group'
        else 'Others'
        end as Age_Group,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.transactions T
left join sales_dataset.customers C
on T.CustomerID = C.CustomerID 
group by Age_Group
order by Sales_Amount Desc

select distinct Location from sales_dataset.stores   

-- seeking age group with Sales Amount 
select 
        Age,
        case when C.Age >= 18 and C.Age <= 25 then '18-20 age group'
             when C.Age >= 26 and C.Age <= 50 then '21-25 age group'
        else 'Others'
        end as Age_Group,
        C.Gender,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.transactions T
left join sales_dataset.customers C
on T.CustomerID = C.CustomerID 
where Location in ('New York','Los Angeles','Chicago')
group by Age, Gender
order by Sales_Amount

--Customers retention Analysis 

select 
    C.CustomerID,
    C.CustomerName,
    round(sum(T.TotalAmount)) AS total_spent,
    max(T.Date) AS last_purchase,
    date_diff(current_date(), date(max(T.Date)), day) AS days_since_last_purchase -- number of inactive days 
from sales_dataset.customers C
left join sales_dataset.transactions T ON C.CustomerID = T.CustomerID
group by C.CustomerID, C.CustomerName
order by days_since_last_purchase desc;


