
-- Exploring the data -- 
select count(*) from sales_dataset.transactions limit 10
select * from sales_dataset.products limit 10
select * from sales_dataset.customers limit 10   
select * from sales_dataset.stores limit 10
select * from sales_dataset.salespersons limit 10

SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.products;
SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.customers;
SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.stores;
SELECT COUNT(*) - COUNT(TotalAmount) AS missing_count FROM sales_dataset.salespersons;



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

-- seeking time range of sales transactions -- 
select max(date) , min(date) from sales_dataset.transactions;


--  Sales overview --
select 
        round(sum(TotalAmount)),
        round(avg(TotalAmount)),
        round(max(TotalAmount)),
        round(min(TotalAmount))
from sales_dataset.transactions 


-----------------------------------------------------

--Total Sales Amount by Store --
select  S.StoreName,
        round(sum(T.TotalAmount))
From sales_dataset.transactions T
left join  sales_dataset.stores S
on T.StoreID = S.StoreID 
group by S.StoreName
order by S.StoreName



-- Total Sales Amount by ProductCategory --
select  P.Category,
        T.ProductID,
        Sum(T.TotalAmount) as Sales_Amount
from sales_dataset.transactions T 
left join sales_dataset.products P 
     on T.ProductID = P.ProductID
group by P.Category, T.ProductID
order by P.Category, T.ProductID

-- Total Sales Amount by CustomerID --
select 
        S.SalespersonID,
        S.SalespersonName,
        round(sum(T.TotalAmount)) as Sales_Amount
From sales_dataset.salespersons S 
left join sales_dataset.transactions T
on T.StoreID = S.StoreID
group by S.SalespersonID,S.SalespersonName
order by S.SalespersonID,S.SalespersonName



-- Total Sales over time  --
select 
      DATE(date) as sale_date,
      round(Sum(TotalAmount)) as total_sales
from sales_dataset.transactions
group by  sale_date
order by  sale_date; 



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

-- Total Sales by locations --
select 
        S.Location,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.stores S
left join sales_dataset.transactions T
on T.StoreID = S.StoreID
group by Location
order by Location


-- Boston
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


-- Customer segmentation and behaviours 
SELECT 
        C.CustomerID, 
        C.CustomerName, 
        round(SUM(T.TotalAmount)) AS total_spent, 
        --(select COUNT(CustomerID) from sales_dataset.transactions ) AS total_transactions,
        MIN(T.Date) AS first_purchase, 
        MAX(T.Date) AS last_purchase
FROM sales_dataset.customers C
left join sales_dataset.transactions T
on C.CustomerID = T.CustomerID
group by CustomerID, CustomerName;

select 
        C.Age,
        C.Gender,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.transactions T
left join sales_dataset.customers C
on T.CustomerID = C.CustomerID 
where C.Age < 25 
group by Age, Gender
order by Sales_Amount


select 
        case when C.Age >= 18 and C.Age <= 20 then '18-20 age group'
             when C.Age >= 21 and C.Age <= 25 then '21-25 age group'
        else 'Others'
        end as Age_Group,
        C.Gender,
        round(sum(T.TotalAmount)) as Sales_Amount
from sales_dataset.transactions T
left join sales_dataset.customers C
on T.CustomerID = C.CustomerID 
where C.Age < 25 
group by Age, Gender
order by Sales_Amount



