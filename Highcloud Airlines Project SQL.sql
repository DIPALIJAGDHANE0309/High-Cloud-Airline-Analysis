SHOW DATABASES;
USE high_cloud;

SELECT
  DATE(CONCAT(Year,'-',Month,'-',Day)) AS Flight_Date,

  YEAR(DATE(CONCAT(Year,'-',Month,'-',Day))) AS Year,
  MONTH(DATE(CONCAT(Year,'-',Month,'-',Day))) AS MonthNo,
  MONTHNAME(DATE(CONCAT(Year,'-',Month,'-',Day))) AS MonthFullName,
  CONCAT('Q', QUARTER(DATE(CONCAT(Year,'-',Month,'-',Day)))) AS Quarter,
  DATE_FORMAT(DATE(CONCAT(Year,'-',Month,'-',Day)), '%Y-%b') AS YearMonth,
  WEEKDAY(DATE(CONCAT(Year,'-',Month,'-',Day))) + 1 AS WeekdayNo,
  DAYNAME(DATE(CONCAT(Year,'-',Month,'-',Day))) AS WeekdayName,

  CASE 
    WHEN Month >= 4 THEN Month - 3 
    ELSE Month + 9 
  END AS FinancialMonth,

  CASE
    WHEN Month BETWEEN 4 AND 6 THEN 'FQ1'
    WHEN Month BETWEEN 7 AND 9 THEN 'FQ2'
    WHEN Month BETWEEN 10 AND 12 THEN 'FQ3'
    ELSE 'FQ4'
  END AS FinancialQuarter

FROM highcloud;

-- Load Factor % (Yearly, Quarterly, Monthly)
SELECT
    `Year`,
    CONCAT(
        ROUND(SUM(`Transported Passengers`) / NULLIF(SUM(`Available Seats`), 0) * 100, 2),
        '%'
    ) AS Load_Factor_Percentage
FROM highcloud
GROUP BY `Year`
ORDER BY `Year`;

-- Quarterly Load Factor
SELECT
    `Year`,
    `Quarter`,
    CONCAT(
        ROUND(SUM(`Transported Passengers`) / NULLIF(SUM(`Available Seats`), 0) * 100, 2),
        '%'
    ) AS Load_Factor_Percentage
FROM highcloud
GROUP BY `Year`, `Quarter`
ORDER BY `Year`, `Quarter`;

-- Monthly Load Factor

SELECT
    `Year`,
    MONTH(DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day Date`))) AS MonthNo,
    MONTHNAME(DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day Date`))) AS MonthName,
    CONCAT(
        ROUND(SUM(`Transported Passengers`) / NULLIF(SUM(`Available Seats`),0) * 100, 2),
        '%'
    ) AS Load_Factor_Percentage
FROM highcloud
GROUP BY `Year`, MonthNo, MonthName
ORDER BY `Year`, MonthNo;

-- Load Factor % by Carrier Name

SELECT
    `Carrier Name`,
    CONCAT(
        ROUND(SUM(`Transported Passengers`) / NULLIF(SUM(`Available Seats`), 0) * 100, 2),
        '%'
    ) AS Load_Factor_Percentage
FROM highcloud
GROUP BY `Carrier Name`
ORDER BY SUM(`Transported Passengers`) DESC;

-- Top 10 Carrier Names
SELECT
    `Carrier Name`,
    CONCAT(
        ROUND(SUM(`Transported Passengers`) / 1000, 1), 'K'
    ) AS Total_Passengers
FROM highcloud
GROUP BY `Carrier Name`
ORDER BY SUM(`Transported Passengers`) DESC
LIMIT 10;

-- Top 10 Routes (From-To City) by Number of Flights

SELECT
    `From - To City` AS From_City_To_City,
    COUNT(`Airline ID`) AS Number_of_Flights
FROM highcloud
GROUP BY `From - To City`
ORDER BY Number_of_Flights DESC
LIMIT 10;

-- Number of Flights by Distance Group

SELECT
    CASE
        WHEN `Distance` < 500 THEN '< 500 km'
        WHEN `Distance` BETWEEN 500 AND 1000 THEN '500 - 1000 km'
        WHEN `Distance` BETWEEN 1001 AND 2000 THEN '1001 - 2000 km'
        ELSE '> 2000 km'
    END AS Distance_Group,
    CONCAT(
        ROUND(COUNT(`Airline ID`) / 1000, 1), 'K'
    ) AS Number_of_Flights
FROM highcloud
GROUP BY Distance_Group
ORDER BY COUNT(`Airline ID`) DESC;

-- Weekend vs Weekday Load Factor %

SELECT
    `Weekday & Weekend` AS Day_Type,
    CONCAT(
        ROUND(SUM(`Transported Passengers`) / NULLIF(SUM(`Available Seats`),0) * 100,2),'%'
    ) AS Load_Factor_Percentage
FROM highcloud
GROUP BY `Weekday & Weekend`
ORDER BY Day_Type;