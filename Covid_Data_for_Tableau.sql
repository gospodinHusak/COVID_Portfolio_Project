-- 1st querry death_percentage_overall

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- 2nd querry deaths_by_continent

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3rd querry infection_rate_by_country

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_Portfolio_Project..Covid_deaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4th querry infection_rate_by_country_date


SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_Portfolio_Project..Covid_deaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC