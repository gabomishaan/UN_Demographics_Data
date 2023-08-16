/* DATA FROM: https://clio-infra.eu/Indicators/LifeExpectancyatBirthTotal.html (Public UN Data fro Demographic Indicators) */

USE UN_Demographic_Indicators;

SELECT * FROM Demographic_Indicators;

-- Current total population and population density for each region
--By Country
SELECT
   region_country_area,
    Tot_Pop_Jan_1first_thousands AS TotalPopulation,
    Pop_density_July_km2 AS AvgPopulationDensity
FROM Demographic_Indicators
WHERE Type_of_region LIKE '%country%' AND Year_date = (SELECT MAX(Year_date) FROM Demographic_Indicators)
ORDER BY TotalPopulation DESC;

--By Continent
SELECT
    region_country_area,
    Tot_Pop_Jan_1first_thousands AS TotalPopulation,
    Pop_density_July_km2 AS AvgPopulationDensity
FROM Demographic_Indicators
WHERE Type_of_region LIKE 'Region' AND Year_date = (SELECT MAX(Year_date) FROM Demographic_Indicators)
ORDER BY TotalPopulation DESC;



-- Current life expectancy by region
--By Country
SELECT
	region_country_area,
    Life_expentancey_at_birth_both_sexes AS Life_Expentancy
FROM Demographic_Indicators
WHERE Type_of_region LIKE '%country%' AND Year_date = (SELECT MAX(Year_date) FROM Demographic_Indicators) AND Life_expentancey_at_birth_both_sexes is not null
ORDER BY Life_Expentancy ASC;

--By Continent
SELECT
	region_country_area,
    Life_expentancey_at_birth_both_sexes AS Life_Expentancy
FROM Demographic_Indicators
WHERE Type_of_region IN ('region', 'World') AND Year_date = (SELECT MAX(Year_date) FROM Demographic_Indicators)
ORDER BY Life_Expentancy ASC;




--Changes in life expectancy over decades
--By Country
SELECT
    d1.region_country_area,
    FLOOR(d1.[Year_date] / 10) * 10 AS Decade,
    AVG(d1.Life_expentancey_at_birth_both_sexes) AS AvgLifeExpectancy,
    ROUND(
        (
            AVG(d1.Life_expentancey_at_birth_both_sexes) -
            (
                SELECT AVG(d2.Life_expentancey_at_birth_both_sexes)
                FROM Demographic_Indicators d2
                WHERE d2.region_country_area = d1.region_country_area
                AND FLOOR(d2.[Year_date] / 10) * 10 = FLOOR(d1.[Year_date] / 10) * 10 - 10
            )
        ) / (AVG(d1.Life_expentancey_at_birth_both_sexes) ) * 100, 2) AS Change_From_Prev_Decade_Percent
FROM Demographic_Indicators d1
WHERE d1.Type_of_region LIKE '%country%'
GROUP BY d1.region_country_area, FLOOR(d1.[Year_date] / 10) * 10
ORDER BY d1.region_country_area, FLOOR(d1.[Year_date] / 10) * 10;

--By Continent & World
SELECT
    d1.region_country_area,
    FLOOR(d1.[Year_date] / 10) * 10 AS Decade,
    AVG(d1.Life_expentancey_at_birth_both_sexes) AS AvgLifeExpectancy,
    ROUND(
        (
            AVG(d1.Life_expentancey_at_birth_both_sexes) -
            (
                SELECT AVG(d2.Life_expentancey_at_birth_both_sexes)
                FROM Demographic_Indicators d2
                WHERE d2.region_country_area = d1.region_country_area
                AND FLOOR(d2.[Year_date] / 10) * 10 = FLOOR(d1.[Year_date] / 10) * 10 - 10
            )
        ) / (AVG(d1.Life_expentancey_at_birth_both_sexes) ) * 100, 2) AS Change_From_Prev_Decade_Percent
FROM Demographic_Indicators d1
WHERE d1.Type_of_region IN ('region', 'World')
GROUP BY d1.region_country_area, FLOOR(d1.[Year_date] / 10) * 10
ORDER BY d1.region_country_area, FLOOR(d1.[Year_date] / 10) * 10;

--By Continent & World USING CTE
WITH PrevDecadeAvg AS (
    SELECT
        d2.region_country_area,
        FLOOR(d2.[Year_date] / 10) * 10 AS PrevDecade,
        AVG(d2.Life_expentancey_at_birth_both_sexes) AS AvgLifeExpectancyPrevDecade
    FROM Demographic_Indicators d2
    WHERE d2.Type_of_region IN ('region', 'World')
    GROUP BY d2.region_country_area, FLOOR(d2.[Year_date] / 10) * 10
)
SELECT
    d1.region_country_area,
    FLOOR(d1.[Year_date] / 10) * 10 AS Decade,
    AVG(d1.Life_expentancey_at_birth_both_sexes) AS AvgLifeExpectancy,
    ROUND(
        (
            AVG(d1.Life_expentancey_at_birth_both_sexes) - PrevDecadeAvg.AvgLifeExpectancyPrevDecade
        ) / AVG(d1.Life_expentancey_at_birth_both_sexes) * 100, 2
    ) AS Change_From_Prev_Decade_Percent
FROM Demographic_Indicators d1
JOIN PrevDecadeAvg ON d1.region_country_area = PrevDecadeAvg.region_country_area AND FLOOR(d1.[Year_date] / 10) * 10 = PrevDecadeAvg.PrevDecade + 10
WHERE d1.Type_of_region IN ('region', 'World')
GROUP BY d1.region_country_area, FLOOR(d1.[Year_date] / 10) * 10, PrevDecadeAvg.AvgLifeExpectancyPrevDecade
ORDER BY d1.region_country_area, FLOOR(d1.[Year_date] / 10) * 10;


--Abslute change in life expectancy 
--By Country
SELECT
    region_country_area,
	MAX(Life_expentancey_at_birth_both_sexes) AS Max_measured_life_expect,
	MIN(Life_expentancey_at_birth_both_sexes) AS Min_measured_life_expect,
    MAX(Life_expentancey_at_birth_both_sexes) - MIN(Life_expentancey_at_birth_both_sexes) AS Change_In_Life_Expectancy
FROM Demographic_Indicators
WHERE Type_of_region LIKE '%country%'
GROUP BY region_country_area
ORDER BY Change_In_Life_Expectancy DESC;

--By Continent & World
SELECT
    region_country_area,
	MAX(Life_expentancey_at_birth_both_sexes) AS Max_measured_life_expect,
	MIN(Life_expentancey_at_birth_both_sexes) AS Min_measured_life_expect,
    MAX(Life_expentancey_at_birth_both_sexes) - MIN(Life_expentancey_at_birth_both_sexes) AS Change_In_Life_Expectancy
FROM Demographic_Indicators
WHERE Type_of_region IN ('region', 'World')
GROUP BY region_country_area
ORDER BY Change_In_Life_Expectancy DESC;


--Population Growth Rate vs Change in Life Expectancy
--Bu Country
WITH YearlyChange AS (
    SELECT
        d1.region_country_area,
        d1.Year_date,
        d1.Life_expentancey_at_birth_both_sexes,
        d1.Population_Growth_Rate,
        LAG(d1.Life_expentancey_at_birth_both_sexes) OVER (PARTITION BY d1.region_country_area ORDER BY d1.Year_date) AS PrevLifeExpectancy
    FROM Demographic_Indicators d1
    WHERE d1.Type_of_region LIKE '%country%'
)
SELECT
    YC.region_country_area,
    YC.Year_date,
    YC.Life_expentancey_at_birth_both_sexes,
    ROUND(
        ((YC.Life_expentancey_at_birth_both_sexes - YC.PrevLifeExpectancy) / YC.PrevLifeExpectancy) * 100, 2
    ) AS LifeExpectancyChangePercent,
	YC.Population_Growth_Rate
FROM YearlyChange YC
ORDER BY YC.region_country_area, YC.Year_date;

--By Continent & World
WITH YearlyChange AS (
    SELECT
        d1.region_country_area,
        d1.Year_date,
        d1.Life_expentancey_at_birth_both_sexes,
        d1.Population_Growth_Rate,
        LAG(d1.Life_expentancey_at_birth_both_sexes) OVER (PARTITION BY d1.region_country_area ORDER BY d1.Year_date) AS PrevLifeExpectancy
    FROM Demographic_Indicators d1
    WHERE d1.Type_of_region IN ('region', 'World')
)
SELECT
    YC.region_country_area,
    YC.Year_date,
    YC.Life_expentancey_at_birth_both_sexes,
    ROUND(
        ((YC.Life_expentancey_at_birth_both_sexes - YC.PrevLifeExpectancy) / YC.PrevLifeExpectancy) * 100, 2
    ) AS LifeExpectancyChangePercent,
	YC.Population_Growth_Rate
FROM YearlyChange YC
ORDER BY YC.region_country_area, YC.Year_date;



--Different Parameters vs Life Expectancy
SELECT
	region_country_area,
	Year_date,
	Life_expentancey_at_birth_both_sexes,
	Mean_Age_Childbearing, 
	Infant_Mortality_Rate_per_1000_live_births
FROM Demographic_Indicators
WHERE Type_of_region LIKE '%country%'












