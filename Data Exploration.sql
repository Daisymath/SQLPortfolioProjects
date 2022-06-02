--SELECT *
--FROM CovidDeaths$
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT TOP 100 location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at total cases vs total deaths - percent who died of those who had

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,3) AS percent_death
FROM CovidDeaths$
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at total cases vs population

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,3) AS percent_infected
FROM CovidDeaths$
WHERE location = 'United States' AND continent is not null
ORDER BY 1,2

-- Highest infection rate countries

SELECT location, MAX(total_cases) AS total_cases, MAX(population) AS population, MAX(ROUND((total_cases/population)*100,3)) AS percent_infected
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY 4 DESC

-- Highest death rate countries

SELECT location, MAX(cast(total_deaths as int)) AS total_deaths, MAX(population) AS population, MAX(ROUND((total_deaths/population)*100,3)) AS percent_dead
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY 4 DESC

-- Highest death rate by continent

SELECT location, MAX(cast(total_deaths as int)) AS total_deaths, MAX(population) AS population, MAX(ROUND((total_deaths/population)*100,3)) AS percent_dead
FROM CovidDeaths$
WHERE continent is null
and location not like '%income%'
and location <> 'International'
GROUP BY location
ORDER BY 4 DESC

-- Showing continents with highest infection rate

SELECT location, MAX(total_cases) AS total_cases, MAX(population) AS population, MAX(ROUND((total_cases/population)*100,3)) AS percent_infected
FROM PortfolioCovid.dbo.CovidDeaths$
WHERE continent is null
and location not like '%income%'
and location <> 'International'
GROUP BY location
ORDER BY 4 DESC

-- Global Numbers

--SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,3) AS percent_death
--FROM CovidDeaths$
--WHERE location = 'World'
--ORDER BY 1,2

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS percent_death
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT TOP 10 * 
FROM PortfolioCovid.dbo.CovidDeaths$

SELECT TOP 10 * 
FROM PortfolioCovid.dbo.CovidVaccinations$


-- Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--(rolling_vaccinations/dea.population)*100
FROM PortfolioCovid.dbo.CovidDeaths$ dea
JOIN PortfolioCovid.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinations)
AS
(SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--(rolling_vaccinations/dea.population)*100
FROM PortfolioCovid.dbo.CovidDeaths$ dea
JOIN PortfolioCovid.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (Rolling_Vaccinations/Population)*100 AS Percent_Vaccinated
FROM PopvsVac


-- View
CREATE VIEW continent_percent_infected
AS (
SELECT location, MAX(total_cases) AS total_cases, MAX(population) AS population, MAX(ROUND((total_cases/population)*100,3)) AS percent_infected
FROM PortfolioCovid.dbo.CovidDeaths$
WHERE continent is null
and location not like '%income%'
and location <> 'International'
GROUP BY location
)

SELECT *
FROM continent_percent_infected

-- View Population Vaccinated
CREATE VIEW PopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--(rolling_vaccinations/dea.population)*100
FROM PortfolioCovid.dbo.CovidDeaths$ dea
JOIN PortfolioCovid.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT TOP 100 * 
FROM PopulationVaccinated