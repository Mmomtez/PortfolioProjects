SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT  null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Tunisia
SELECT location,date,total_cases,total_deaths,(total_deaths*100)/total_cases as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location='tunisia'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT location,date,population,total_cases,(total_cases*100)/population as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location='tunisia'
ORDER BY 1,2

--Looking at countries with the Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) AS HighestInfectioCount,MAX((total_cases/population))*100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT  null
GROUP BY Location,Population
ORDER BY PercentPopInfected DESC;


--Showing the countries with the Highest Death Count per Population
SELECT location,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT  null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


--BY CONTINENT
--Showing Contitnents with the highest death count per population
SELECT continent,MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS not  null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--GLOBAL NUMBERS


SELECT SUM(total_cases) AS total_cases,SUM(cast(new_deaths as int )) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date)
AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--USE CTE
WITH PopvsVac(Continent ,Location,Date,Population, New_Vaccinations,RollingPeopleVaccinated)
AS 
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date)
AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--CovidData Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



