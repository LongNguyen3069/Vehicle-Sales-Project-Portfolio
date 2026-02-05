/*

Data cleaning to transforming it to answer real world questions

Questions we are going to be answering:
1. Which year had the highest sales volume and the strongest pricing performance relative to market value?
2. Which vehicle makes and transmission types account for the highest sales volume?
3. Which states contribute the highest vehicle sales volume?
4. Which vehicles consistently underperform based on low sales price relative to market value and high mileage (Odometer)?
5. What day of the week, month, and year combinations drive the highest vehicle sales volume?

*/

-- Exploratory checks

SELECT
	TOP 100 *
FROM PortfolioProject..VehicleSales_Raw
WHERE saledate IS NOT NULL;

SELECT
    DATENAME(weekday, d) AS DOW,
    FORMAT(d, 'MMMM d, yyyy') AS PrettyDate
FROM (
    SELECT TRY_CONVERT(date, SUBSTRING(saledate, 5, 11), 100) AS d
    FROM PortfolioProject..VehicleSales_Raw
) x
WHERE d IS NOT NULL;
-- Checking for uniqueness
SELECT
	COUNT(*) AS total_rows,
	COUNT(DISTINCT(vin)) AS distinct_vins
FROM PortfolioProject..VehicleSales_Raw;

SELECT
	vin,
	COUNT(*) AS sale_attempts
FROM PortfolioProject..VehicleSales_Raw
GROUP BY vin
HAVING COUNT(*) > 1
ORDER BY sale_attempts DESC

SELECT
	vin,
	COUNT(DISTINCT(sellingprice)) AS distinct_prices,
	COUNT(DISTINCT(saledate)) AS distinct_dates
FROM PortfolioProject..VehicleSales_Raw
GROUP BY vin
HAVING COUNT(*) > 1;

-- Defining clean and Analytics-Ready Table

DROP TABLE IF EXISTS PortfolioProject..VehicleSales_Cleaned
CREATE TABLE PortfolioProject..VehicleSales_Cleaned
(
	sale_id INT IDENTITY(1,1) PRIMARY KEY,
	vin NVARCHAR(255),
	vehicle_year INT,
	make NVARCHAR(255),
	model NVARCHAR(255),
	trim NVARCHAR(255),
	body_type NVARCHAR(255),
	transmission NVARCHAR(255),
	state NVARCHAR(255),
	vehicle_condition INT,
	odometer INT,
	exterior_color NVARCHAR(255),
	interior_color NVARCHAR(255),
	seller NVARCHAR(255),
	mmr INT,
	selling_price INT,
	DOW nvarchar(255),
	sale_date DATE
);

INSERT INTO PortfolioProject..VehicleSales_Cleaned
(
    vin,
    vehicle_year,
    make,
    model,
    trim,
    body_type,
    transmission,
    state,
    vehicle_condition,
    odometer,
    exterior_color,
    interior_color,
    seller,
    mmr,
    selling_price,
	DOW,
    sale_date
)
SELECT
	UPPER(vin) AS vin,
	year AS vehicle_year,
	UPPER(LTRIM(RTRIM(make))) AS make,
	LTRIM(RTRIM(model)) AS model,
	LTRIM(RTRIM(trim)) AS trim,
	body AS body_type,
	LOWER(transmission) AS transmission,
	UPPER(state) As state,
	condition AS vehicle_condition,
	odometer,
	color AS exterior_color,
	interior AS interior_color,
	seller,
	mmr,
	sellingprice AS selling_price,
    -- Day of week
    DATENAME(weekday, d) AS DOW,
    -- Actual date
    d AS sale_date
FROM (
    SELECT
        *,
        TRY_CONVERT(date, SUBSTRING(saledate, 5, 11), 100) AS d
    FROM PortfolioProject..VehicleSales_Raw
) x
WHERE d IS NOT NULL
AND sellingprice IS NOT NULL;


/* 

Foundational Assumption:
Grain: 1 row = 1 sale attempt

Sales volume: COUNT(*)

Pricing performance: selling_price - mmr

Profit proxy: Price vs Market (MMR), not true profit

Date type: sale_date (DATE, YYYY-MM-DD)

*/

-- Master Analytics View for Tableau Visualization

CREATE OR ALTER VIEW VehicleSales_Analytics AS
SELECT
	sale_id,
    vin,
    vehicle_year,
    CASE  -- Standardizing the make
        WHEN make IS NULL THEN NULL
        WHEN make IN ('VW', 'VOLKSWAGEN') THEN 'VOLKSWAGEN'
        WHEN make IN ('MERCEDES', 'MERCEDES-B', 'MERCEDES-BENZ') THEN 'MERCEDES-BENZ'
        WHEN make IN ('LAND ROVER', 'LANDROVER') THEN 'LAND ROVER'
        WHEN make IN ('HYUNDAI', 'HYUNDAI TK') THEN 'HYUNDAI'
        WHEN make IN ('MAZDA', 'MAZDA TK') THEN 'MAZDA'
        WHEN make IN ('FORD', 'FORD TK', 'FORD TRUCK') THEN 'FORD'
        WHEN make IN ('GMC', 'GMC TRUCK') THEN 'GMC'
        WHEN make IN ('DODGE', 'DODGE TK') THEN 'DODGE'
        WHEN make IN ('CHEVROLET', 'CHEV TRUCK') THEN 'CHEVROLET'
        ELSE make
    END AS standard_make,
	make AS raw_make, -- keeping this for auditability
    model,
    trim,
    body_type,
    transmission,
    state,
    vehicle_condition,
    CAST(odometer AS BIGINT) AS odometer_clean,
    CAST(mmr AS DECIMAL(18,2)) AS mmr,
    CAST(selling_price AS DECIMAL(18,2)) AS selling_price,
-- Core Business metric
	CAST(selling_price - mmr AS DECIMAL(18,2)) AS price_vs_mmr,
-- Date dimensions
	sale_date,
	YEAR(sale_date) AS sale_year,
	MONTH(sale_date) AS sale_month,
	DATENAME(WEEKDAY, sale_date) AS sale_day_of_week
FROM PortfolioProject..VehicleSales_Cleaned
WHERE 
	selling_price IS NOT NULL
	AND sale_date >= '2010-01-01'
	AND MAKE IS NOT NULL;

SELECT *
FROM VehicleSales_Analytics;
-- Business question 1: Year with Most Sales & Best Pricing Performance

SELECT
	sale_year,
	COUNT(*) AS vehicle_sold,
	AVG(price_vs_mmr) AS avg_price_vs_mmr
FROM VehicleSales_Analytics
GROUP BY sale_year
ORDER BY vehicle_sold DESC;

-- Business question 2: Top Vehicle Makes by Transmission
SELECT
	standard_make AS vehicle_make,
	CASE
		WHEN transmission is NULL or transmission = '' THEN 'UNKNOWN'
		ELSE transmission
	END AS vehicle_transmission,
	COUNT(*) AS vehicle_sold
FROM VehicleSales_Analytics
GROUP BY 
	standard_make,
	CASE
		WHEN transmission is NULL or transmission = '' THEN 'UNKNOWN'
		ELSE transmission
	END
HAVING standard_make IS NOT NULL -- Having vehicle make NULL serves no purpose in our data
ORDER BY vehicle_sold DESC;

-- Business question 3: Top States by Vehicle Sales
SELECT
	state,
	COUNT(*) AS vehicle_sales
FROM VehicleSales_Analytics
GROUP BY state
ORDER BY COUNT(*) DESC;

-- Business question 4: Vehicles to Exclude from Inventory (Underperformers)
SELECT
	standard_make,
	model,
	AVG(price_vs_mmr) AS avg_price_vs_mmr,
	AVG(odometer_clean) AS avg_mileage,
	COUNT(*) AS vehicle_sold
FROM VehicleSales_analytics
GROUP BY standard_make, model
HAVING
	AVG(price_vs_mmr) < 0
	AND AVG(odometer_clean) > (
		SELECT AVG(odometer_clean)
		FROM VehicleSales_Analytics
	)
ORDER BY avg_price_vs_mmr

-- Business question 5: Sales by Day of Week, Month, Year
SELECT
	sale_year,
	sale_month,
	sale_day_of_week,
	COUNT(*) AS vehicle_sold
FROM VehicleSales_Analytics
GROUP BY sale_year, sale_month, sale_day_of_week
ORDER BY vehicle_sold DESC;
