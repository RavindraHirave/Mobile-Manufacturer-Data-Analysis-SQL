--SQL Advance Case Study


--Q1--BEGIN 
	select l.[State],f.[Date]
from [dbo].[FACT_TRANSACTIONS]  f
inner join [dbo].[DIM_LOCATION] l on l.[IDLocation]=f.[IDLocation]
inner join [dbo].[DIM_MODEL] m on m.[IDModel]=f.[IDModel]
where [Date] between '01-01-2005' and getdate()


--Q1--END

--Q2--BEGIN
	
	select top 1 l.[State],sum(f.[Quantity]) as most_price
from  [dbo].[DIM_LOCATION] l
inner join [dbo].[FACT_TRANSACTIONS] f on f.[IDLocation]=l.[IDLocation]
inner join [dbo].[DIM_MODEL] m on m.[IDModel]=f.[IDModel]
inner join [dbo].[DIM_MANUFACTURER] dm on dm.[IDManufacturer]=m.[IDManufacturer]
where [Manufacturer_Name]='Samsung' and Country='US'
group by l.[State]


--Q2--END

--Q3--BEGIN      
	
	select [ZipCode],[State],count(concat(t.[IDCustomer],t.IDModel)) as no_of_Transactions,t.IDModel
from [dbo].[DIM_LOCATION] l
inner join [dbo].[FACT_TRANSACTIONS] t on t.[IDLocation]=l.[IDLocation]
inner join  [dbo].[DIM_CUSTOMER] c on c.[IDCustomer]=t.[IDCustomer]
group by [ZipCode],[State],t.IDModel


--Q3--END

--Q4--BEGIN

select top 1 [IDModel],[Model_Name],[Unit_price]
from [dbo].[DIM_MODEL]
group by [IDModel],[Model_Name],[Unit_price]
order by [Unit_price] asc

--Q4--END

--Q5--BEGIN

select top 5 dm.[Manufacturer_Name],[Model_Name],sum(Quantity) as To_Qty,avg([Unit_price]) as avg_price
from  [dbo].[FACT_TRANSACTIONS] t
inner join [dbo].[DIM_MODEL]m on m.[IDModel]=t.[IDModel]
inner join [dbo].[DIM_MANUFACTURER] dm on dm.[IDManufacturer]=m.[IDManufacturer]
group by dm.[Manufacturer_Name],[Model_Name]
order by avg([Unit_price]) desc


--Q5--END

--Q6--BEGIN

select [Customer_Name],avg([TotalPrice]) as avg_amount
from  [dbo].[DIM_CUSTOMER] c
inner join [dbo].[FACT_TRANSACTIONS] t on t.[IDCustomer]=c.[IDCustomer]
where YEAR([Date])='2009'
group by [Customer_Name]
having avg([TotalPrice]) >500


--Q6--END
	
--Q7--BEGIN  
	

select [Model_Name] from (select [Model_Name],year(date) as OrderYear,
RANK() over(partition by year(date) order by sum(Quantity) desc) as Quantity_rank
from FACT_TRANSACTIONS t
inner join [dbo].[DIM_MODEL] m on m.[IDModel]=t.[IDModel]
where year(date) in ('2008','2009','2010')
group by [Model_Name],year(date)) temp
where Quantity_rank<=5
group by [Model_Name]
having count(distinct OrderYear)=3;


--Q7--END	

--Q8--BEGIN

with rank as (select [Manufacturer_Name],[YEAR],sum([Quantity]) as Total_Qty,
row_number() over (partition by [YEAR] order by sum([Quantity]) desc) as rank 
from [dbo].[DIM_MANUFACTURER] dm
inner join [dbo].[DIM_MODEL] m on m.[IDManufacturer]=dm.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] f on f.[IDModel]=m.[IDModel]
inner join [dbo].[DIM_DATE] d on d.[DATE]=f.[Date]
where [YEAR] in ('2009','2010') 
group by [Manufacturer_Name],[YEAR]
)
select [Manufacturer_Name],[YEAR], Total_Qty
from rank 
where
rank=2

--Q8--END

--Q9--BEGIN
	
select distinct [Manufacturer_Name]
from  [dbo].[DIM_MANUFACTURER] dm
inner join [dbo].[DIM_MODEL] m on m.[IDManufacturer]=dm.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] f on f.[IDModel]=m.[IDModel]
where YEAR(DATE)=2010 and 
dm.[Manufacturer_Name] not in
(select [Manufacturer_Name]
from  [dbo].[DIM_MANUFACTURER] dm
inner join [dbo].[DIM_MODEL] m on m.[IDManufacturer]=dm.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] f on f.[IDModel]=m.[IDModel]
where YEAR(date)=2009 )


--Q9--END

--Q10--BEGIN
	
   SELECT 
     top 10    [IDCustomer],
    YEAR([Date]) as yr,AVG([TotalPrice]) as avg_spend,AVG([Quantity]) as avg_Qty,
	--lag(avg([TotalPrice])) over (partition by IDCustomer order by year([Date])) as lag_avg
	(AVG([TotalPrice])-LAG(AVG([TotalPrice])) over (partition by IDCustomer order by YEAR([Date])))/ nullif(lag(avg([TotalPrice])) 
	over (partition by IDCustomer order by year([Date])),0)*100 as per_spend
	from [dbo].[FACT_TRANSACTIONS] as f
	where [IDCustomer] in 
	(select [IDCustomer] from (select top 10 [IDCustomer],SUM([TotalPrice]) as tot_spend
	from [dbo].[FACT_TRANSACTIONS] 
	group by [IDCustomer]
	order by SUM([TotalPrice]) desc)a)
	group by [IDCustomer],YEAR([Date])


--Q10--END
