select *
from CovidDeaths
order by 3,4

--select *
--from Covidvaccinations
--order by 3,4

-- select data that we are going to be using
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST (total_cases  AS float))*100 AS
death_precentage
FROM CovidDeaths cd
WHERE location like '%Germany%'
ORDER BY 1,2;

--- what precentage of population got covid

SELECT Location, date, total_cases, population, (CAST(total_cases AS float)/population)*100 AS infection_precentage
FROM CovidDeaths cd
WHERE location like '%Germany%'
ORDER BY 1,2;

--- contries with highest infaction rate compared to population

SELECT Location, date, population, max(total_cases ) AS highest_infection_count, max(CAST(total_cases AS float)/population)*100 
AS infection_precentage
FROM CovidDeaths cd
--WHERE location like '%Germany%'
GROUP BY location, population
ORDER BY 5 DESC ;

--- showing countries with highest deathcount per population

SELECT Location, max(CAST(total_deaths AS int)) AS total_death_count
FROM CovidDeaths cd
--WHERE location like '%Germany%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY total_death_count DESC;

-- breaking down by continent 

SELECT continent, max(CAST(total_deaths AS int)) AS total_death_count
FROM CovidDeaths cd
--WHERE location like '%Germany%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC;

---showing the continent with highest death count per population

SELECT continent, max(CAST(total_deaths AS int)) AS total_death_count
FROM CovidDeaths cd
--WHERE location like '%Germany%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC;

--Global Numbers
SELECT date, sum(new_cases) AS total_cases, sum(CAST (new_deaths AS int)) AS total_deaths, sum(CAST (new_deaths AS int))/
sum(new_cases)*100 AS death_precentage
FROM CovidDeaths cd
--WHERE location like '%Germany%'
--WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2;



SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cv.new_vaccinations  IS not NULL 
ORDER BY 1,2,3;

UPDATE CovidDeaths 
SET continent = NULL WHERE continent = '';

UPDATE CovidVaccinations 
SET new_vaccinations = NULL WHERE new_vaccinations = '';

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent  IS not NULL 
ORDER BY 2,3;

---Looking at total population vs vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST (cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3;

--use CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST (cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/CAST(population AS float))*100
FROM pop_vs_vac



-- TEMP table
DROP TABLE IF EXISTS #precentagepopulationvaccinatedd
CREATE TABLE #precentagepopulationvaccinatedd
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population NUMERIC,
new_vaccinations NUMERIC,
rollling_people_vaccinated NUMERIC
)

INSERT INTO #precentagepopulationvaccinatedd
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST (cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL 
--ORDER BY 2,3
SELECT *, (rolling_people_vaccinated/CAST(population AS float))*100
FROM #precentagepopulationvaccinatedd;

---creating view to store data for later visualizations

CREATE VIEW precentagepopulationvaccinatedd as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(CAST (cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
AND cd.date = cv.date;
---WHERE cd.continent IS NOT NULL;
---ORDER BY 2,3


