SELECT * FROM Covid_project..CovidDeaths 
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_project..CovidDeaths
ORDER BY 1, 2

-- Percentage of deaths over cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_project..CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1, 2

-- Percentage of cases over population
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM Covid_project..CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1, 2