SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM CovidDeaths
ORDER BY 1, 2

--Total Death vs Total Cases
--Death Rate: Likelihood of dying if you contract covid in your country
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%china%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Total Cases vs Population
--Shows what percentage of population got covid
SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%china%'
ORDER BY 1, 2

--Countries with highest infection rate compared to population
SELECT 
	Location, 
	Population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population
SELECT 
	Location, 
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Continents with the highest death count per population
SELECT 
	continent, 
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT 
	SUM(new_Cases) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/sum(new_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL


--Total Population vs Vaccinations
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
	AND 
	vac.new_vaccinations IS NOT NULL
ORDER BY 2, 3


--Percentage of people vaccinated (using CTE )
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vacinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 


--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT * 
FROM PercentPopulationVaccinated



