select * 
from PortfolioProject..Covid_deaths  
--where continent is not null
order by 3,4

--select * from
--PortfolioProject..Covid_Vaccinations
--order by 3,4

-- select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_deaths 
where continent is not null
order by 1,2

--Looking at Total Cases vs Total  Deaths

select location, date, total_cases, total_deaths,  (CAST(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_deaths where continent is not null
order by 1,2

-- shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,  (CAST(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_deaths where location like '%india%'and continent is not null 
order by 1,2 

--Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

select location, date, total_cases, population,  (CAST(total_cases as decimal)/population)*100 as PercentPopulationInfected
from PortfolioProject..Covid_deaths where location like '%india%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Popultion

select location, population,  Max(total_cases) as HighestInfectionCount, 
Max((CAST(total_cases as decimal)/population))*100 as PercentPopulationInfected
from PortfolioProject..Covid_deaths
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countires with Highest Death Count per Population

select location, Max(total_deaths) as TotalDeathCount
from PortfolioProject..Covid_deaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc
 
-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing contintents with the highest death count per population

select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject..Covid_deaths
--where location like '%india%'
where continent is  not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, SUM(new_deaths)/nullif  (SUM(cast(new_cases as decimal)),0)*100 as DeathPercentage
from PortfolioProject..Covid_deaths
--where location like '%india%'and 
where continent is not null
group by date
order by 1,2 

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, SUM(new_deaths)/nullif  (SUM(cast(new_cases as decimal)),0)*100 as DeathPercentage
from PortfolioProject..Covid_deaths
--where location like '%india%'and 
where continent is not null
--group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations


select * from PortfolioProject..Covid_Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..Covid_deaths dea
join PortfolioProject..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.location  like '%india%' and 
where dea.continent is not null 
order by 2,3


-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..Covid_deaths dea
join PortfolioProject..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.location  like '%india%' and 
where dea.continent is not null 
--order by 2,3
)
select * ,(Convert(float,RollingPeopleVaccinated)/population)*100
from PopvsVac

-- TEMP TABLE
drop Table if exists #PercentPopulationVaccinated
Create  Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..Covid_deaths dea
join PortfolioProject..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.location  like '%india%' and 
--where dea.continent is not null 
--order by 2,3
select * ,(Convert(int,RollingPeopleVaccinated)/population)*100
from #PercentPopulationVaccinated

--- Creating View to store data for later visualizations
drop view if exists #PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..Covid_deaths dea
join PortfolioProject..Covid_Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.location  like '%india%' and 
where dea.continent is not null 
--order by 2,3

select * from PercentPopulationVaccinated
