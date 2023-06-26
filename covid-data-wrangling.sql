-- Join COVID deaths and vaccinations tables

SELECT dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations
FROM `datasciportfolio.covid19.covid-deaths` dea
JOIN `datasciportfolio.covid19.covid-vaccinations` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- Looking at total population vs. vaccinations

SELECT dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations
  -- SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM `datasciportfolio.covid19.covid-deaths` dea
JOIN `datasciportfolio.covid19.covid-vaccinations` vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- Set up CTE

WITH `datasciportfolio.covid19.PopvsVac` AS 
  (SELECT dea.continent,
    dea.location,
    dea.date,
    IFNULL(dea.population,0) AS population,
    IFNULL(vac.new_vaccinations,0) AS new_vaccinations,
    IFNULL(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date),0) AS rolling_vaccinations
  FROM `datasciportfolio.covid19.covid-deaths` dea
  JOIN `datasciportfolio.covid19.covid-vaccinations` vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  )
-- use CTE in subsequent query
SELECT *,
  ROUND((rolling_vaccinations/population)*100, 3) AS vac_rate
FROM `datasciportfolio.covid19.PopvsVac`
ORDER BY location, date;


-- Create views to store data for later visualizations

-- vaccination rates
CREATE VIEW `datasciportfolio.covid19.PercentPopVaccinated` AS
WITH `datasciportfolio.covid19.PopvsVac` AS 
  (SELECT dea.continent,
    dea.location,
    dea.date,
    IFNULL(dea.population,0) AS population,
    IFNULL(vac.new_vaccinations,0) AS new_vaccinations,
    IFNULL(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date),0) AS rolling_vaccinations
  FROM `datasciportfolio.covid19.covid-deaths` dea
  JOIN `datasciportfolio.covid19.covid-vaccinations` vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  )
SELECT *,
  ROUND((rolling_vaccinations/population)*100, 3) AS vac_rate
FROM `datasciportfolio.covid19.PopvsVac`
ORDER BY location, date;

-- highest infection rates by country
CREATE VIEW `datasciportfolio.covid19.HighInfectionRateCountry` AS
SELECT location,  
  MAX(total_cases) AS highest_infection_count, 
  population, 
  MAX((total_cases/population))*100 AS pct_population_infected
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY pct_population_infected DESC;

-- highest infection rates by country AND time
CREATE VIEW `datasciportfolio.covid19.HighInfectionRateCountryTime` AS
SELECT location, 
  date,
  MAX(total_cases) AS highest_infection_count, 
  population, 
  MAX((total_cases/population))*100 AS pct_population_infected
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY pct_population_infected DESC;

-- deaths by country
CREATE VIEW `datasciportfolio.covid19.HighDeathRateCountry`AS
SELECT location,  
  MAX(total_deaths) AS total_death_count
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- deaths by continent
CREATE VIEW `datasciportfolio.covid19.HighDeathRateContinent`AS
SELECT continent,  
  MAX(total_deaths) AS total_death_count
FROM `datasciportfolio.covid19.covid-deaths` 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- global COVID stats
CREATE VIEW `datasciportfolio.covid19.GlobalStats` AS
SELECT 
  MAX(total_cases) AS global_cases, 
  MAX(total_deaths) AS global_deaths,
  MAX(total_deaths)/MAX(total_cases)*100 AS death_percentage
FROM `datasciportfolio.covid19.covid-deaths`
WHERE continent IS NOT NULL;
