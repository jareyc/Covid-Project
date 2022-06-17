-- 1. COVID-19 Global Stats
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as total_death_percentage
FROM Covid_project..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- 2. COVID-19 Deaths by Continent
SELECT continent, SUM(cast(new_deaths as int)) as total_death_count
FROM Covid_project..CovidDeaths
WHERE continent is not null
and location not in ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY total_death_count desc

-- 3. Percentage of Countries' Population Infected with COVID-19
SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 AS population_infected_percentage
FROM Covid_project..CovidDeaths
where continent is not null
GROUP BY population, location
ORDER BY population_infected_percentage desc

-- 4. Time series of Percentage of Population infected with COVID-19 by Country
SELECT location, date, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 AS population_infected_percentage
FROM Covid_project..CovidDeaths
where continent is not null
GROUP BY location, population, date
ORDER BY population_infected_percentage desc

-- Rolling count of vaccinations and percentage of population vaccinated by country
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM Covid_project..CovidDeaths dea
JOIN Covid_project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_vaccination_count/population)*100 as population_vaccinated_percentage FROM PopvsVac