-- Inspecting data
select * from [dbo].[sales_data_sample]

-- Checking unique value

select distinct STATUS from [dbo].[sales_data_sample] 
select distinct YEAR_ID from [dbo].[sales_data_sample] 
select distinct PRODUCTLINE from [dbo].[sales_data_sample] 
select distinct COUNTRY from [dbo].[sales_data_sample] 
select distinct DEALSIZE from [dbo].[sales_data_sample]
select distinct TERRITORY from [dbo].[sales_data_sample]


select distinct MONTH_ID from [dbo].[sales_data_sample] -- check how long (month) rhat they operate in year
where YEAR_ID = 2005

-- Analysis
--Let's start by Grouping Sales by productline 

select PRODUCTLINE, sum(SALES) Revenue
from [dbo].[sales_data_sample]
group by PRODUCTLINE
order by 2 desc

-- Sales by Year
select YEAR_ID, sum(SALES) Revenue
from [dbo].[sales_data_sample]
group by YEAR_ID
order by 2 desc

-- Sale by Dealsize
select DEALSIZE, sum(SALES) Revenue
from [dbo].[sales_data_sample]
group by DEALSIZE
order by 2 desc

--What was the best month for Sales in a specific year? How much was earned that month? 
select MONTH_ID, sum(SALES) Revenue, COUNT(ORDERNUMBER) Frequency
from [dbo].[sales_data_sample]
where YEAR_ID = 2003 --change year to see the rest 
group by MONTH_ID
order by 2 desc

--November seems to be the best month for Sales, so what product do they sell in November?
select MONTH_ID, PRODUCTLINE,  sum(SALES) Revenue, COUNT(ORDERNUMBER) Frequency
from [dbo].[sales_data_sample]
where YEAR_ID = 2003 and MONTH_ID = 11 --change year to see the rest
group by MONTH_ID, PRODUCTLINE
order by 3 desc
--- So Classic Cars were a best seller in November 


---Who is our best customer?

WITH RFM AS
(
    SELECT 
        Customername, 
        SUM(SALES) AS Monetaryvalue,
        AVG(SALES) AS AvgMonetaryvalue,
        COUNT(ORDERNUMBER) AS Frequency,
        MAX(ORDERDATE) AS Last_order_date,
        (SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample]) AS max_order_date,
        DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample])) AS Recency
    FROM [dbo].[sales_data_sample]
    GROUP BY Customername
),
RFM_calc AS 
(
    SELECT r.*,
        NTILE(4) OVER (ORDER BY Recency) AS RFM_recency,
        NTILE(4) OVER (ORDER BY Frequency) AS RFM_frequency,
        NTILE(4) OVER (ORDER BY AvgMonetaryvalue) AS RFM_monetary
    FROM RFM r
)

-- Create global temporary table
SELECT 
    r.*, 
    RFM_recency + RFM_frequency + RFM_monetary AS RFM_cell,
    CAST(RFM_recency AS varchar) + CAST(RFM_frequency AS varchar) + CAST(RFM_monetary AS varchar) AS RFM_cell_string
INTO ##RFM  -- Use ## for global temporary table
FROM RFM_calc;

-- Query from global temporary table
SELECT CUSTOMERNAME, RFM_recency, RFM_frequency, RFM_monetary
FROM ##RFM;  -- Use ## for global temporary table
