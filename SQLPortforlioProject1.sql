select * 
from PortforlioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortforlioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortforlioProject..CovidDeaths
where location = 'Australia'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as CovidCasesPercentage
from PortforlioProject..CovidDeaths
where location = 'Australia'
order by 1,2

-- Looking at countries with highest Infection rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectedPopulationPercentage
from PortforlioProject..CovidDeaths
group by location, population
order by InfectedPopulationPercentage desc

-- Showing countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortforlioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Break things down by Continent
-- Showing continents with Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortforlioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortforlioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Looking at Toal Population and Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortforlioProject..CovidDeaths as dea
join PortforlioProject..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortforlioProject..CovidDeaths as dea
join PortforlioProject..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
from PopVsVac

-- Use TEMP Table
drop table if exists #VaccinatedPopulationPercentage
create table #VaccinatedPopulationPercentage
(
Continent nvarchar(100),
Location nvarchar(100),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #VaccinatedPopulationPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortforlioProject..CovidDeaths as dea
join PortforlioProject..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
from #VaccinatedPopulationPercentage

-- Creating View to store data for later visualizations
create view VaccinatedPopulationPercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortforlioProject..CovidDeaths as dea
join PortforlioProject..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from VaccinatedPopulationPercentage