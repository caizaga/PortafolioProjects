SELECT *
FROM ProjectTest..CovidDeaths
ORDER BY 3,4

SELECT *
FROM ProjectTest..CovidVaccs
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectTest..CovidDeaths
ORDER BY 1,2

--Muestra la probabilidad de morir de COVID en el Ecuador
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM ProjectTest..CovidDeaths
WHERE location LIKE '%Ecuador%'
ORDER BY 1,2

--Muestra el porcentaja del total de la poblacion que contrajo COVID en el Ecuador
SELECT location, date, population, total_cases, population, (total_cases/population)*100 AS Percent_Population_Infected
FROM ProjectTest..CovidDeaths
WHERE location LIKE '%Ecuador%'
ORDER BY 1,2

--Muestra los paises con los ratios de infeccion mas altos comparados con poblacion 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM ProjectTest..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Muestra los paises con el mas alto recuento de muertes por poblacion

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM ProjectTest..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Muestra el recuento de muertes por Continente

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM ProjectTest..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Muestra el recuento de muertes por Continente 2

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM ProjectTest..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--NUMEROS GLOBALES

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, 
SUM(CAST(new_deaths as INT))/NULLIF(SUM(new_cases), 0)*100 AS Death_Percentage--, total_deaths, (total_deaths/total_cases) AS Death_Percentage
FROM ProjectTest..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--CASOS TOTALES

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, 
SUM(CAST(new_deaths as INT))/NULLIF(SUM(new_cases), 0)*100 AS Death_Percentage--, total_deaths, (total_deaths/total_cases) AS Death_Percentage
FROM ProjectTest..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM ProjectTest..CovidVaccs
ORDER BY 3,4

--JOIN de ambas tablas Deaths y Vaccs

SELECT *
FROM ProjectTest..CovidDeaths AS dea
JOIN ProjectTest..CovidVaccs AS vac
ON dea.date = vac.date AND dea.location = vac.location

--Total population vs total vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
FROM ProjectTest..CovidDeaths AS dea
JOIN ProjectTest..CovidVaccs AS vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USANDO CTEs

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location
order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
FROM ProjectTest..CovidDeaths AS dea
JOIN ProjectTest..CovidVaccs AS vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 3
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population) *100 
FROM PopvsVac

--TEMP Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--VIEW

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
FROM ProjectTest..CovidDeaths AS dea
JOIN ProjectTest..CovidVaccs AS vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
--WHERE dea.continent IS NOT NULL
--ORDER BY 3
--ORDER BY 1,2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100 
FROM ProjectTest..CovidDeaths AS dea
JOIN ProjectTest..CovidVaccs AS vac
	ON dea.date = vac.date 
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3