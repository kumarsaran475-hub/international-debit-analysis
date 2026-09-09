
CREATE DATABASE DebtAnalysis;

USE DebtAnalysis;

CREATE TABLE Countries (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,       
    long_name NVARCHAR(MAX),                
    short_name NVARCHAR(MAX),              
    region NVARCHAR(255),                  
    income_group NVARCHAR(MAX),            
    lending_category NVARCHAR(MAX),         
    external_debt_reporting_status NVARCHAR(MAX) 
);

select * from Countries;

CREATE TABLE Indicators (
    indicator_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    indicator_name NVARCHAR(MAX),
    short_definition NVARCHAR(MAX),
    long_definition NVARCHAR(MAX),
    source NVARCHAR(MAX),        
    topic NVARCHAR(MAX),           
    dataset NVARCHAR(MAX),        
    periodicity NVARCHAR(255),    
    aggregation_method NVARCHAR(255)
    );

select * from Indicators;

CREATE TABLE DebtData (
    debt_id INT IDENTITY(1,1) PRIMARY KEY,
    country_id INT NOT NULL,                
    indicator_id INT NOT NULL,              
    year INT NOT NULL,                      
    value DECIMAL(18,2),                   
    FOREIGN KEY (country_id) REFERENCES Countries(country_id),
    FOREIGN KEY (indicator_id) REFERENCES Indicators(indicator_id)
);

select * from DebtData;




drop table CountrySeries;

CREATE TABLE CountrySeries (
    series_id INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(100),
    Country_Code NVARCHAR(MAX) NOT NULL,    
    Series_Code NVARCHAR(MAX) NOT NULL,    
    Description NVARCHAR(MAX) NOT NULL,     
    Country_Name NVARCHAR(255) NOT NULL,  
    ISO_Code NVARCHAR(50) NOT NULL,         
);
select * from CountrySeries;


CREATE TABLE Footnotes (
    footnote_id INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(50),                   
    Country_Code NVARCHAR(255) NOT NULL, 
    Series_Code NVARCHAR(MAX) NOT NULL,    
    Time_Code NVARCHAR(50) NOT NULL,       
    Description NVARCHAR(MAX) NOT NULL,   
    Country_Name NVARCHAR(255) NOT NULL,  
    ISO_Code VARCHAR(10) NOT NULL,         
    Year INT NOT NULL,                     
    Year_Code NVARCHAR(20) NOT NULL, 
);

select * from Footnotes;

-- 1. Retrieve all distinct country names
SELECT DISTINCT short_name
FROM Countries;

-- 2. Count the total number of countries available
SELECT COUNT(DISTINCT short_name) AS TotalCountries
FROM Countries;

-- 3. Find the total number of indicators present
SELECT COUNT(DISTINCT indicator_name) AS TotalIndicators
FROM Indicators;

-- 4. Display the first 10 records of the dataset (DebtData joined with Countries + Indicators)
SELECT TOP 10 d.debt_id, c.short_name AS Country, i.indicator_name AS Indicator, d.year, d.value
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
JOIN Indicators i ON d.indicator_id = i.indicator_id;

-- 5. Calculate the total global debt
SELECT SUM(value) AS TotalGlobalDebt
FROM DebtData;

-- 6. List all unique indicator names
SELECT DISTINCT indicator_name
FROM Indicators;

-- 7. Find the number of records for each country
SELECT c.short_name AS Country, COUNT(*) AS RecordCount
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
ORDER BY RecordCount DESC;

-- 8. Display all records where debt is greater than 1 billion USD
SELECT c.short_name AS Country, i.indicator_name AS Indicator, d.year, d.value
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
JOIN Indicators i ON d.indicator_id = i.indicator_id
WHERE d.value > 1000000000;

-- 9. Find the minimum, maximum, and average debt values
SELECT 
    MIN(value) AS MinDebt,
    MAX(value) AS MaxDebt,
    AVG(value) AS AvgDebt
FROM DebtData;

-- 10. Count total number of records in the dataset
SELECT COUNT(*) AS TotalRecords
FROM DebtData;


-- 1. Find the total debt for each country
SELECT c.short_name AS Country, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name;

-- 2. Display the top 10 countries with the highest total debt
SELECT TOP 10 c.short_name AS Country, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
ORDER BY TotalDebt DESC;

-- 3. Find the average debt per country
SELECT c.short_name AS Country, AVG(d.value) AS AvgDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name;

-- 4. Calculate total debt for each indicator
SELECT i.indicator_name AS Indicator, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Indicators i ON d.indicator_id = i.indicator_id
GROUP BY i.indicator_name;

-- 5. Identify the indicator contributing the highest total debt
SELECT TOP 1 i.indicator_name AS Indicator, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Indicators i ON d.indicator_id = i.indicator_id
GROUP BY i.indicator_name
ORDER BY TotalDebt DESC;

-- 6. Find the country with the lowest total debt
SELECT TOP 1 c.short_name AS Country, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
ORDER BY TotalDebt ASC;

-- 7. Calculate total debt for each country and indicator combination
SELECT c.short_name AS Country, i.indicator_name AS Indicator, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
JOIN Indicators i ON d.indicator_id = i.indicator_id
GROUP BY c.short_name, i.indicator_name
ORDER BY Country, Indicator;

-- 8. Count how many indicators each country has
SELECT c.short_name AS Country, COUNT(DISTINCT d.indicator_id) AS IndicatorCount
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name;

-- 9. Display countries whose total debt is above the global average
WITH CountryDebt AS (
    SELECT c.short_name AS Country, SUM(d.value) AS TotalDebt
    FROM DebtData d
    JOIN Countries c ON d.country_id = c.country_id
    GROUP BY c.short_name
),
GlobalAvg AS (
    SELECT AVG(TotalDebt) AS GlobalAverage
    FROM CountryDebt
)
SELECT cd.Country, cd.TotalDebt
FROM CountryDebt cd, GlobalAvg ga
WHERE cd.TotalDebt > ga.GlobalAverage;

-- 10. Rank countries based on total debt (highest to lowest)
SELECT c.short_name AS Country, SUM(d.value) AS TotalDebt,
       RANK() OVER (ORDER BY SUM(d.value) DESC) AS DebtRank
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
ORDER BY DebtRank;

-- 1. Find the top 5 indicators contributing most to global debt
SELECT TOP 5 i.indicator_name AS Indicator, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Indicators i ON d.indicator_id = i.indicator_id
GROUP BY i.indicator_name
ORDER BY TotalDebt DESC;

-- 2. Calculate percentage contribution of each country to total global debt
SELECT c.short_name AS Country,
       SUM(d.value) AS TotalDebt,
       (SUM(d.value) * 100.0 / (SELECT SUM(value) FROM DebtData)) AS PercentageContribution
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
ORDER BY PercentageContribution DESC;

-- 3. Identify the top 3 countries for each indicator based on debt
SELECT Indicator, Country, TotalDebt
FROM (
    SELECT i.indicator_name AS Indicator,
           c.short_name AS Country,
           SUM(d.value) AS TotalDebt,
           RANK() OVER (PARTITION BY i.indicator_name ORDER BY SUM(d.value) DESC) AS RankPerIndicator
    FROM DebtData d
    JOIN Countries c ON d.country_id = c.country_id
    JOIN Indicators i ON d.indicator_id = i.indicator_id
    GROUP BY i.indicator_name, c.short_name
) ranked
WHERE RankPerIndicator <= 3
ORDER BY Indicator, RankPerIndicator;

-- 4. Find the difference between maximum and minimum debt for each country
SELECT c.short_name AS Country,
       MAX(d.value) - MIN(d.value) AS DebtRange
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name;

-- 5. Create a view for the top 10 countries with highest debt
CREATE VIEW Top10CountriesDebt AS
SELECT TOP 10 c.short_name AS Country, SUM(d.value) AS TotalDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
ORDER BY TotalDebt DESC;
GO

SELECT * FROM Top10CountriesDebt;

-- 6. Categorize countries into High, Medium, Low Debt (example thresholds)
SELECT c.short_name AS Country,
       SUM(d.value) AS TotalDebt,
       CASE 
           WHEN SUM(d.value) > 100000000000 THEN 'High Debt'
           WHEN SUM(d.value) BETWEEN 10000000000 AND 100000000000 THEN 'Medium Debt'
           ELSE 'Low Debt'
       END AS DebtCategory
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name;

-- 7. Use window functions to calculate cumulative debt per country
SELECT c.short_name AS Country, d.year, SUM(d.value) AS YearlyDebt,
       SUM(SUM(d.value)) OVER (PARTITION BY c.short_name ORDER BY d.year) AS CumulativeDebt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name, d.year
ORDER BY c.short_name, d.year;

-- 8. Find indicators where average debt is higher than overall average debt
WITH IndicatorAvg AS (
    SELECT i.indicator_name AS Indicator, AVG(d.value) AS AvgDebt
    FROM DebtData d
    JOIN Indicators i ON d.indicator_id = i.indicator_id
    GROUP BY i.indicator_name
),
GlobalAvg AS (
    SELECT AVG(value) AS OverallAvgDebt FROM DebtData
)
SELECT ia.Indicator, ia.AvgDebt
FROM IndicatorAvg ia, GlobalAvg ga
WHERE ia.AvgDebt > ga.OverallAvgDebt;

-- 9. Identify countries contributing more than 5% of global debt
SELECT c.short_name AS Country, SUM(d.value) AS TotalDebt,
       (SUM(d.value) * 100.0 / (SELECT SUM(value) FROM DebtData)) AS PercentageContribution
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
GROUP BY c.short_name
HAVING (SUM(d.value) * 100.0 / (SELECT SUM(value) FROM DebtData)) > 5
ORDER BY PercentageContribution DESC;

-- 10. Find the most dominant indicator (highest contribution) for each country
SELECT Country, Indicator, TotalDebt
FROM (
    SELECT c.short_name AS Country,
           i.indicator_name AS Indicator,
           SUM(d.value) AS TotalDebt,
           RANK() OVER (PARTITION BY c.short_name ORDER BY SUM(d.value) DESC) AS RankPerCountry
    FROM DebtData d
    JOIN Countries c ON d.country_id = c.country_id
    JOIN Indicators i ON d.indicator_id = i.indicator_id
    GROUP BY c.short_name, i.indicator_name
) ranked
WHERE RankPerCountry = 1
ORDER BY Country;
