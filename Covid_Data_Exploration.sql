SELECT *
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM Covid_Portfolio_Project..Covid_vaccinations
ORDER BY 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Portfolio_Project..Covid_deaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths in Russia
-- Shows likelihood of dying in you contract covid in Russia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) AS deaths_percentage
FROM Covid_Portfolio_Project..Covid_deaths
WHERE location = 'Russia'
ORDER BY 1,2 

-- Looking at Total Cases vs Population in Russia
-- Shows what percentage of population got Covid in Russia

SELECT location, date, total_cases, population, (total_cases/population * 100) AS got_covid_percentage
FROM Covid_Portfolio_Project..Covid_deaths
WHERE location = 'Russia'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population * 100)) AS got_covid_percentage
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY got_covid_percentage DESC

-- Looking at highest death count per country

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NOT NULL AND location != 'World'  -- otherwise, it includes global observations (continents AND the world)
GROUP BY location
ORDER BY highest_death_count DESC

-- BY CONTINENT
-- Looking at highest death count per continent

SELECT location, MAX(CAST(total_deaths AS int)) AS highest_death_count
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NULL AND location != 'World' 
GROUP BY location
ORDER BY highest_death_count DESC

-- GLOBAL NUMBERS

-- Looking at death percentage by date across the world

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

-- Looking at death percentage overall across the world

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM Covid_Portfolio_Project..Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2 



-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
FROM Covid_Portfolio_Project..Covid_deaths dea
JOIN Covid_Portfolio_Project..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- If we want to look at the rate of vaccinated people we have several options:

--	¹1 USE CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations, cummulative_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
FROM Covid_Portfolio_Project..Covid_deaths dea
JOIN Covid_Portfolio_Project..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (cummulative_vaccinations/population)*100 AS vaccinated_rate
FROM pop_vs_vac

--	¹2 TEMP TABLE

DROP TABLE IF exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummulative_vaccinations numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
FROM Covid_Portfolio_Project..Covid_deaths dea
JOIN Covid_Portfolio_Project..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (cummulative_vaccinations/population)*100 AS vaccinated_rate
FROM #Percent_Population_Vaccinated


--	¹3 CREATE VIEW 

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS cummulative_vaccinations
FROM Covid_Portfolio_Project..Covid_deaths dea
JOIN Covid_Portfolio_Project..Covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (cummulative_vaccinations/population)*100 AS vaccinated_rate
FROM Percent_Population_Vaccinated