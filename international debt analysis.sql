
CREATE DATABASE DebtAnalysis;
GO
USE DebtAnalysis;

CREATE TABLE Countries (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,       -- e.g. AFG, IND
    long_name NVARCHAR(255),                -- full country name
    short_name NVARCHAR(255),               -- short/common name
    region NVARCHAR(255),                   -- region grouping
    income_group NVARCHAR(255),             -- income classification
    lending_category NVARCHAR(255),         -- IBRD/IDA/etc.
    external_debt_reporting_status NVARCHAR(255) -- Actual/Estimate/etc.
);
select * from Countries;

CREATE TABLE Indicators (
    indicator_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    indicator_name NVARCHAR(MAX),
    short_definition NVARCHAR(MAX),
    long_definition NVARCHAR(MAX),
    source NVARCHAR(MAX),          -- was 255
    topic NVARCHAR(MAX),           -- was 255
    dataset NVARCHAR(MAX),         -- was 255
    periodicity NVARCHAR(255),     -- was 50
    aggregation_method NVARCHAR(255)
    );



CREATE TABLE DebtData (
    debt_id INT IDENTITY(1,1) PRIMARY KEY,
    country_id INT NOT NULL,                -- FK to Countries
    indicator_id INT NOT NULL,              -- FK to Indicators
    year INT NOT NULL,                      -- year of data
    value DECIMAL(18,2),                    -- numeric value
    FOREIGN KEY (country_id) REFERENCES Countries(country_id),
    FOREIGN KEY (indicator_id) REFERENCES Indicators(indicator_id)
);






drop table CountrySeries;

CREATE TABLE CountrySeries (
    series_id INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(100),
    Country_Code NVARCHAR(MAX) NOT NULL,    -- long country/region names
    Series_Code NVARCHAR(MAX) NOT NULL,     -- long indicator names
    Description NVARCHAR(MAX) NOT NULL,     -- very long explanatory text
    Country_Name NVARCHAR(255) NOT NULL,    -- short country names
    ISO_Code NVARCHAR(50) NOT NULL,         -- allow longer codes like "excluding high income"
);
select * from CountrySeries;


CREATE TABLE Footnotes (
    footnote_id INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(50),                     -- "FootNote"
    Country_Code NVARCHAR(255) NOT NULL,   -- e.g. "Afghanistan (AFG)"
    Series_Code NVARCHAR(MAX) NOT NULL,    -- long indicator names
    Time_Code NVARCHAR(50) NOT NULL,       -- e.g. "2024 (YR2024)"
    Description NVARCHAR(MAX) NOT NULL,    -- explanatory text
    Country_Name NVARCHAR(255) NOT NULL,   -- e.g. "Afghanistan"
    ISO_Code VARCHAR(10) NOT NULL,         -- must match Countries.code
    Year INT NOT NULL,                     -- numeric year
    Year_Code NVARCHAR(20) NOT NULL, 
);

select * from Footnotes;


SELECT TOP 10 c.long_name, SUM(d.value) AS total_debt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
WHERE d.year = 2024
GROUP BY c.long_name
ORDER BY total_debt DESC;

SELECT d.year, d.value
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
WHERE c.code = 'IND'
ORDER BY d.year;

SELECT i.indicator_name, SUM(d.value) AS total_value
FROM DebtData d
JOIN Indicators i ON d.indicator_id = i.indicator_id
WHERE d.year = 2024
GROUP BY i.indicator_name
ORDER BY total_value DESC;

SELECT TOP 5 c.long_name, d.value AS fdi_inflows
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
JOIN Indicators i ON d.indicator_id = i.indicator_id
WHERE i.code = 'BX.KLT.DINV.CD.DT' AND d.year = 2024
ORDER BY fdi_inflows DESC;

SELECT c.income_group, SUM(d.value) AS total_debt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
WHERE d.year = 2024
GROUP BY c.income_group
ORDER BY total_debt DESC;

SELECT c.region, SUM(d.value) AS total_debt
FROM DebtData d
JOIN Countries c ON d.country_id = c.country_id
WHERE d.year = 2024
GROUP BY c.region
ORDER BY total_debt DESC;


