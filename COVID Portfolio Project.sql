select *
from PortfolioProject..[Covid Deaths]
Where location is not null
order by 3,4

--select *
--from PortfolioProject..[Covid Vaccinations]
--order by 3,4

-- Select data that we are going to be using

select continent, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[Covid Deaths]
Where continent is not null
order by 1,2 

-- looking at the total cases vs. total deaths
-- shows the chance of dying if covid contracted in your country

select location, date, total_cases, total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths] 
order by 1,2

-- looking at the total cases vs. population
-- shows what percentage of population got covid

select location, date, total_cases, population, (Total_Cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
--Where location like '%states%'
order by 1,2

-- looking at countries with highest infection rates comapred to population

select location, MAX(total_cases) as HighestInfectionCount, population, MAX((Total_Cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
--Where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc

-- showing the countries with the highest death count per population

select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent

-- showing the continents with the highest death count

select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc

select continent, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[Covid Deaths]
Where continent is not null 
and total_cases is not null
order by 1,2

select continent, date, total_cases, total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths] 
Where continent like '%north%' 
and total_deaths is not null
order by DeathPercentage asc

select continent, MAX(total_cases) as HighestInfectionCount, population, MAX((Total_Cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
where continent is not null
Group by continent,population
order by PercentPopulationInfected desc




-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
	as DeathPercentage
from PortfolioProject..[Covid Deaths] 
--Where location like '%states%' 
where continent is not null
--Group by date
order by 1,2

-- looking at total vaccination vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

with popvsvac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
join PortfolioProject..[Covid Vaccinations] vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null
--order by 2,3

create view totaldeathcount as
select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
Where continent is not null
Group by continent
--order by TotalDeathCount desc

create view PercentPopulationInfected as
select continent, MAX(total_cases) as HighestInfectionCount, population, MAX((Total_Cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
where continent is not null
Group by continent,population
--order by PercentPopulationInfected desc

create view GlobalNumbers as
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 
	as DeathPercentage
from PortfolioProject..[Covid Deaths] 
where continent is not null
--order by 1,2

create view ChanceOfDying as
select location, date, total_cases, total_deaths, (Total_Deaths/Total_Cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths] 
--order by 1,2

select *
from PercentPopulationVaccinated