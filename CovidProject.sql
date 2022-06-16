SELECT * FROM Covid_project..CovidDeaths 
where continent is not null
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_project..CovidDeaths
where continent is not null
ORDER BY 1, 2

-- Percentage of deaths per cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_project..CovidDeaths
WHERE location LIKE 'United States'
AND continent is not null
ORDER BY 1, 2

-- Percentage of population infected
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM Covid_project..CovidDeaths
WHERE location LIKE 'United States'
AND continent is not null
ORDER BY 1, 2

-- Highest percentage of population infected by country
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM Covid_project..CovidDeaths
where continent is not null
GROUP BY population, location
ORDER BY PopulationInfectedPercentage desc

-- Highest percentage of population dead by country
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, MAX(total_deaths/population) * 100 as PopulationDeadPercentage
FROM Covid_project..CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY PopulationDeadPercentage desc


-- Continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM Covid_project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- Day-to-day data
SELECT date, SUM(new_cases) as DailyCases, SUM(cast(new_deaths as int)) as DailyDeaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DailyDeathPercentage
FROM Covid_project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- All-time numbers
SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as TotalDeathPercentage
FROM Covid_project..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM Covid_project..CovidDeaths dea
JOIN Covid_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM Covid_project..CovidDeaths dea
JOIN Covid_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingVaccinationCount/population)*100 FROM PopvsVac

-- Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM Covid_project..CovidDeaths dea
JOIN Covid_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingVaccinationCount/population) * 100
FROM #PercentPopulationVaccinated

-- Creating view to bring into Tableau
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM Covid_project..CovidDeaths dea
JOIN Covid_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null