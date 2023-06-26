-- Looking at cases vs deaths

SELECT location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
FROM `datasciportfolio.covid19.covid-deaths` 
ORDER BY location, date;


-- check 10 most populous countries really quickly

SELECT location, 
  population
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population DESC
LIMIT 10;

-- Looking at total cases vs. population in the US
-- case_percent shows what percentage of the population got COVID

SELECT location, 
  date, 
  total_cases, 
  population, 
  (total_cases/population)*100 AS case_percent
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE location LIKE 'United States'
ORDER BY location, date;


-- Looking at total cases vs. total deaths in the US

SELECT location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths/total_cases)*100 AS death_percent
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE location LIKE 'United States'
ORDER BY location, date;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,  
  MAX(total_cases) AS highest_infection_count, 
  population, 
  MAX((total_cases/population))*100 AS pct_population_infected
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY pct_population_infected DESC;


/* 
Some troubleshooting really quick - Looking at total cases again, except looking at Taiwan.
Taiwan seems to have null values for total_cases and total_deaths based on looking at the first 200 and last 200 rows.
Some other countries have null values too, based on the output of the previous query.
*/

SELECT location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths/total_cases)*100 AS death_percent
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE location LIKE 'Taiwan'
ORDER BY location, date;


-- Showing countries with highest death count per population (not grouping by continents)

SELECT location,  
  MAX(total_deaths) AS total_death_count
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Showing continents with total death count 

SELECT continent,  
  MAX(total_deaths) AS total_death_count
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- Looking at numbers worldwide as of June 21st, 2023

SELECT 
  MAX(total_cases) AS global_cases, 
  MAX(total_deaths) AS global_deaths,
  MAX(total_deaths)/MAX(total_cases)*100 AS death_percentage
FROM `datasciportfolio.covid19.covid-deaths`
WHERE continent IS NOT NULL;
