/*
COVID19 Data Exploration

Skills used: Joins, Aggregate Functions, Windows Functions, CTEs, Temp Tables, Converting Data Types, Creating Views.
*/

SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 3, 4

SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations
ORDER BY 3, 4

-- Selecting the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2

--Looking at the United Kingdom alone

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of the population of the UK got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2

--Countries with highest infection rate compared to the population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentpopulationInfected
FROM [Portfolio Project]..CovidDeaths
GROUP BY location, population
ORDER BY PercentpopulationInfected DESC

--Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BREAKING THINGS DOWN BY CONTINENT
--Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
--Showing the number of cases and deaths each day and the rate of dying if you contract Covid

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total population vs vaccinations
--Showing the total number of people vaccinated each day for each location

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac ON  dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
Order by 2, 3

--USING CTE
--Looking at the percentage of the population vaccinated each day in each location

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac ON  dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopvsVac

--Using a temp table to perform calculations on the previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac ON  dea.location = vac.location and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated

--Creating a view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac ON  dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null

--Another View

CREATE VIEW RollingPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac ON  dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null



