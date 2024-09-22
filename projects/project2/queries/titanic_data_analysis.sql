-- Data Exploration and Summary Statics 

-- Data Preview
select * from titanic_dataset.titanic limit 10;

select count(*) from titanic_dataset.titanic;

-- Survival statistics
select 
       count(*) as total_passengers,
       sum(case when survived=1 then 1 else 0 end) as survival_passengers,
       sum(case when survived=0 then 1 else 0 end) as non_survival_passengers
from titanic_dataset.titanic;

-- Age statistics
select 
      max(age) as oldest_passenger,
      min(age) as youngest_passenger,
      avg(age) as middleaged_passenger
from titanic_dataset.titanic;


--Fare Statistics
select 
      max(fare),
      min(fare)
from titanic_dataset.titanic; 

-- Distinct embarkation points
select distinct(embarked) from titanic_dataset.titanic;

-- Distinct number of siblings/spouses
select distinct SibSp from titanic_dataset.titanic;

-----------------------------------------------------------------------------------
select 
    count(*) as total_rows,
    count(pclass) as non_null_pclass,
    count(embarked) as non_null_embarked,
    count(age) as non_null_age,
    count(survived) as non_null_survived,
    (count(*) - count(pclass)) as null_pclass,
    (count(*) - count(embarked)) as null_embarked,
    (count(*) - count(age)) as null_age,
    (count(*) - count(survived)) as null_survived
from
    titanic_dataset.titanic;

--- check the data duplicates)

select 
      PassengerId,
      count(*) as total
from titanic_dataset.titanic 
group by PassengerId
having count(*) > 1;
       

-----Handling Missing Values-----

-- Check for missing values in Age
select * from titanic_dataset.titanic where age is null;

-- Check for missing values in Embarked
select * from titanic_dataset.titanic where embarked is null; 

-- Count missing values in Cabin
select count(*) from titanic_dataset.titanic
where Cabin is null;

--set median value to age --
update titanic_dataset.titanic set age = (select avg(age) from titanic_dataset.titanic where age is not null) 
where age is null;

--set mode value to embarked ---
select distinct embarked, count(*) from titanic_dataset.titanic group by Embarked;
-- S is mode --
update titanic_dataset.titanic set embarked = 'S' 
where embarked is null; 

--delete the column of Cabin--
alter table titanic_dataset.titanic
drop column Cabin;

-----Feature Engineering--------    
--- add a column of family_size (int) Parch+SibSp
alter table titanic_dataset.titanic
add column Family_Size int; 

update titanic_dataset.titanic 
set Family_Size = Parch+SibSp; 

------------------------------------------------------------------------------------------
--Survival Rate by Age group
select 
        case 
           when age > 0 and age <=25 then '0-25'  
           when age >25 and age <= 50 then '26-50' 
           when age >50 and age <= 100 then '50-100' 
      else 'undefined' 
      end as age_group,
       count(*) as total_passengers,
       sum(case when survived=1 then 1 else 0 end) as survival_passengers,
       sum(case when survived=0 then 1 else 0 end) as non_survival_passengers
from titanic_dataset.titanic
group by age_group;


--Survival Rate by Class 
select 
       Pclass,
       count(*) as total_passengers,
       sum(case when survived=1 then 1 else 0 end) as survival_passengers,
       sum(case when survived=0 then 1 else 0 end) as non_survival_passengers
from titanic_dataset.titanic
group by Pclass
order by Pclass;

SELECT 
    Pclass,
    ROUND(AVG(survived) * 100, 2) AS survival_rate_by_class
FROM 
    titanic_dataset.titanic
GROUP BY 
    Pclass;


--Survival Rate by Embarked 
select 
       embarked,
       count(*) as total_passengers,
       sum(case when survived=1 then 1 else 0 end) as survival_passengers,
       sum(case when survived=0 then 1 else 0 end) as non_survival_passengers
from titanic_dataset.titanic
group by embarked;

-------------------Survival Rate per age range, passenger Class, Fare Range, Numbers of Siblings and Spouse/ Parents and Child----------------------------

select 
        case 
           when age > 0 and age <=25 then '0-25'  
           when age >25 and age <= 50 then '26-50' 
           when age >50 and age <= 100 then '50-100' 
      else 'undefined' 
      end as age_group,
       count(*) as total_passengers,
       sum(case when survived=1 then 1 else 0 end) as survival_passengers,
       sum(case when survived=0 then 1 else 0 end) as non_survival_passengers,
       round(avg(survived)*100,2) as survival_rate
from titanic_dataset.titanic
group by age_group;


select 
       Pclass,
       count(*) as number_of_passengers,
       sum(case when survived = 1 then 1 else 0 end) as survival_passengers,
       sum(case when survived = 0 then 1 else 0 end) as non_survival_passengers,
       round(avg(survived)*100,2) as survival_rate
from titanic_dataset.titanic 
group by Pclass
order by Pclass; 



select
       case when fare > 0 and fare <=100 then '0-100'
            when fare >100 and fare <=200 then '101-200'
            when fare > 200 and fare <=300 then '201-300'
            when fare > 300 and fare <= 400 then '300-400'
       else 'Over_500'
       end as ticker_fare,
       count(*) as number_of_passengers,
       sum(case when survived = 1 then 1 else 0 end) as survival_passengers,
       sum(case when survived =0 then 1 else 0 end) as non_survival_passengers,
       round(avg(survived)*100,2) as survival_rate
from titanic_dataset.titanic
group by ticker_fare
order by ticker_fare;


      
select 
       SibSp as sibling_spouse_numbers,
       count(*) number_of_passengers,
       sum(case when Survived = 1 then 1 else 0 end) as survival_passengers,
       sum(case when Survived = 0 then 1 else 0 end) as non_survival_passengers,
       round(avg(survived)*100,2) as survival_rate
from titanic_dataset.titanic
group by sibling_spouse_numbers
order by sibling_spouse_numbers;

----------------------------survival rate by embark-------------------
select 
      Embarked, 
      sum(case when survived =1 then 1 else 0 end) as survival_passengers,
      sum(case when survived =0 then 1 else 0 end) as non_survival_passengers,
      round(avg(survived)*100,2) as survival_rate
from titanic_dataset.titanic
group by Embarked
order by Embarked;

-- Check for any passengers with invalid ages
select count(*) from titanic_dataset.titanic where age < 0 or age > 100;


-----------------------------------------------------------------------------------
-- final summary overview of key findings (filtering out nulls)

select *
from (
    -- overall survival rate
    select 
        'overall survival rate' as metric,
        round(avg(survived) * 100, 2) as value
    from 
        titanic_dataset.titanic

    union all

    -- survival rate by class (excluding null pclass)
    select 
        concat('survival rate by class: ', pclass) as metric,
        round(avg(survived) * 100, 2) as value
    from 
        titanic_dataset.titanic
--     where 
--         pclass is not null
    group by 
        pclass

    union all

    -- survival rate by age group
    select 
        'survival rate by age group' as metric,
        round(avg(survived) * 100, 2) as value
    from 
        (select 
            case 
                when age > 0 and age <= 25 then '0-25'  
                when age > 25 and age <= 50 then '26-50' 
                when age > 50 and age <= 100 then '51-100' 
                else 'undefined' 
            end as age_group,
            avg(survived) as survived
        from 
            titanic_dataset.titanic
        group by 
            age_group) as age_summary

    union all

    -- survival rate by embarkation (excluding null embarked)
    select 
        concat('survival rate by embarkation: ', embarked) as metric,
        round(avg(survived) * 100, 2) as value
    from 
        titanic_dataset.titanic
--     where 
--         embarked is not null
    group by 
        embarked
) as summary
where value is not null;  -- filter out null values in the final result
