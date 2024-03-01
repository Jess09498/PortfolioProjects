Select *
From PortfolioProject..CovidDeaths
where continent is NOT NULL
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is NOT NULL
Order by 1,2

--Looking at the Total cases vs Total deaths
-- The expression (CONVERT...()) worked as it converts the columns to float data types
--handles division

--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
--(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2


--Total cases vs population
--shows what % of population got covid

Select Location, date, Population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2


--Countries with highest infection rate compared to population
Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population
Order by PercentagePopulationInfected desc

--showing the countries with highest death count per population

Select Location, MAX(cast(Total_Deaths as bigint)) as TotalDeathCount
--issue with datatype total_deaths(nvarchar(255,null)) 
From PortfolioProject..CovidDeaths
where continent is NOT NULL
Group by Location
Order by TotalDeathCount desc




Select Location, MAX(cast(Total_Deaths as bigint)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is NULL
AND location NOT IN ('High income', 'Upper middle income', 'Lower middle income','Low income')
Group by location
Order by TotalDeathCount desc



--Now breaking things down by Continents, highest death count/population
Select continent, MAX(cast(Total_Deaths as bigint)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is NOT NULL
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select date, SUM(New_cases), SUM(cast(new_deaths as bigint)),SUM((CONVERT(float, new_deaths) / NULLIF(CONVERT(float, New_cases), 0)))*100 as DeathPercentage
--total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is NOT NULL
--Group by date
Order by 1,2


Select *
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking at Total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
	order by 2,3


--	USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
	
)
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 -- USE TEMP TABLE

 DROP TABLE if exists #PercentPopulationVaccinated -- for making any altercations
 CREATE Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
--order by 2,3

 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


 -- Creating view to store data for later visualizations

 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL
--order by 2,3

Select *
From PercentPopulationVaccinated