create database blinkit_analysis;
use blinkit_analysis;

select * from blinkit_data;

-- Data Cleaning:

UPDATE blinkit_data
SET item_fat_content=
CASE
WHEN item_fat_content IN ("LF","low fat") THEN  "Low Fat"
WHEN item_fat_content IN ("reg") THEN "Regular"
ELSE item_fat_content
END;

select DISTINCT item_fat_content from blinkit_data;

-- Total Sales:
SELECT ROUND(SUM(total_sales),2) as Total_Sales FROM blinkit_data;

-- Average Sales:
SELECT ROUND(AVG(total_sales),2) as Average_Sales FROM blinkit_data;

-- Number of Items:
SELECT DISTINCT (COUNT(item_identifier)) as Number_of_Items from blinkit_data;

-- Average Rating:
SELECT ROUND(AVG(Rating),2) as Average_Rating from blinkit_data;

-- Total Sales by Fat Content:
SELECT item_fat_content as Item_Fat_Content,
ROUND(SUM(total_sales),2) as Total_Sales from blinkit_data 
GROUP BY item_fat_content
ORDER BY item_fat_content;

-- Total Sales by Item Type:
SELECT item_type as Item_Type, 
ROUND(SUM(total_sales),2) as Total_Sales from blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;

-- Fat Content by Outlet for Total Sales
SELECT Outlet_Location_Type,
IFNULL(ROUND(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' 
THEN Total_Sales END),2), 0) AS Low_Fat,
IFNULL(ROUND(SUM(CASE WHEN Item_Fat_Content = 'Regular' 
THEN Total_Sales END),2), 0) AS Regular
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

-- Percentage of Sales by Outlet Size
SELECT outlet_size as Outlet_Size, 
ROUND(SUM(total_sales),2) as Total_Sales,
ROUND((SUM(total_sales)*100/SUM(SUM(total_sales)) OVER()),2) as Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size;

-- Sales by Outlet Location
SELECT outlet_location_type as Outlet_Location,
ROUND(SUM(total_sales),2) as Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location
ORDER BY Outlet_Location;

-- All Metrics by Outlet Type
SELECT outlet_location_type as Outlet_Location,
ROUND(SUM(total_sales),2) as Total_Sales,
ROUND(AVG(total_sales),2) as Average_Sales,
COUNT(*) as Number_of_Items,
ROUND(AVG(rating),2) as Rating,
ROUND(AVG(item_visibility),2) as Item_Visibility
FROM blinkit_data
GROUP BY Outlet_Location
ORDER BY Outlet_Location;

-- Year-wise Total Sales
SELECT outlet_establishment_year as Establishment_Year,
ROUND(SUM(total_sales),2) as Total_Sales
FROM blinkit_data
GROUP BY Establishment_Year
ORDER BY Establishment_Year;

-- Year-on-Year Sales Growth
SELECT outlet_establishment_year as Establishment_Year,
ROUND(SUM(total_sales),2) as Total_Sales,
ROUND(SUM(total_sales)-LAG(SUM(total_sales)) OVER(ORDER BY outlet_establishment_year),2) as YoY_Growth
FROM blinkit_data
GROUP BY Establishment_Year
ORDER BY Establishment_Year;

-- Cumulative Sales Over Years
SELECT outlet_establishment_year as Establishment_Year,
ROUND(SUM(total_sales),2) as Total_Sales,
ROUND(SUM(SUM(total_sales)) OVER(ORDER BY outlet_establishment_year),2) as Cummulative_sales
FROM blinkit_data
GROUP BY Establishment_Year
ORDER BY Establishment_Year;

-- Top 5 Item Types by Sales
SELECT item_type as Item_Type,
ROUND(SUM(total_sales),2) as Total_sales
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC LIMIT 5;

-- Ranking Outlet Types by Total Sales
SELECT outlet_type as Outlet_Type,
ROUND(SUM(total_sales),2) as Total_Sales,
RANK() OVER(ORDER BY SUM(total_sales) DESC) as Sales_Rank
FROM blinkit_data
GROUP BY Outlet_Type;

-- Performance vs Quality Analysis
SELECT Outlet_Type,
ROUND(SUM(Total_Sales),2) AS Total_Sales,
AVG(Rating) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Type
HAVING Avg_Rating < (
    SELECT AVG(Rating) FROM blinkit_data);

-- Sales per Item by Outlet Type
SELECT outlet_type as Outlet_Type,
ROUND(SUM(total_sales)/COUNT(item_identifier),2) as Sales_per_Item
from blinkit_data
GROUP BY Outlet_Type;

-- Most Efficient Outlet Size
SELECT outlet_size as Outlet_Size,
ROUND(SUM(total_sales)/COUNT(item_identifier),2) as Efficiency
from blinkit_data
GROUP BY Outlet_Size
ORDER BY Outlet_Size;

-- Best-Selling Item Type per Location
SELECT * FROM (
SELECT item_type as Item_Type,
outlet_location_type as Outlet_Location_Type,
ROUND(SUM(total_sales),2) as Total_Sales,
RANK() OVER(partition by outlet_location_type 
ORDER BY SUM(total_sales)DESC) as Ranks 
FROM blinkit_data
GROUP BY Outlet_Location_Type,Item_Type) t
WHERE Ranks=1;

-- Fat Content Preference by Location
SELECT item_fat_content as Item_Fat_Content,
outlet_location_type as Outlet_Location_Type,
ROUND(SUM(total_sales),2) as Total_Sales
FROM blinkit_data
GROUP BY outlet_location_type,item_fat_content
ORDER BY outlet_location_type,Total_Sales DESC;

-- Compare Outlet Sales with Overall Average
SELECT Outlet_Type,
ROUND(SUM(Total_Sales),2) AS Total_Sales,
ROUND(AVG(SUM(Total_Sales)) OVER (),2) AS Overall_Avg_Sales
FROM blinkit_data
GROUP BY Outlet_Type;

