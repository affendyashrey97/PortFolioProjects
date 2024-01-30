Select *
From CovidDeath
where continent is not null

Select *
From CovidVaccination

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeath
order by 1, 2

ALTER TABLE CovidDeath
ALTER COLUMN total_cases float

ALTER TABLE CovidDeath
ALTER COLUMN total_deaths float

ALTER TABLE CovidVaccination
ALTER COLUMN new_vaccinations float

-- Looking at total case vs total death 
-- show likelihood of dying if you contract covid in country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From CovidDeath
Where location like 'Malaysia'
order by 1,2

-- looking total case vs population
-- show what percentage got covid
Select location, date, total_cases, population, (total_cases/population)*100 PercentagePopulationInfected
From CovidDeath
Where location like 'Malaysia'
order by 1,2

-- looking at country with highest infection rate vs population
Select location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentagePopulationInfected
From CovidDeath
--Where location like 'Malaysia'
Group by location, population
order by PercentagePopulationInfected desc

-- looking the counmtry high deatgh count pre population
Select location, population, MAX(total_cases) HighestInfectionCount, MAX(total_deaths) TotalDeath
From CovidDeath
where continent is not null
Group by location, population
order by TotalDeath desc

-- lets break things down by continents
-- showing the continent with highest death count 
Select location, MAX(total_deaths) TotalDeath
From CovidDeath
where not location like '%income' and continent is null and not location like 'world' and not location like 'european union'
Group by location
order by TotalDeath desc 

-- breaking global number 
Select date, sum(new_cases) TotalCase, sum(new_deaths) TotalDeath, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From CovidDeath
Where continent is not null and new_cases is not null
group by date
order by 1,2


Select sum(new_cases) TotalCase, sum(new_deaths) TotalDeath, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From CovidDeath
Where continent is not null and new_cases is not null
order by 1,2

-- join coviddeath and covidvaccination
Select *
From CovidDeath dea
join CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date

-- total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
From CovidDeath dea
join CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- use cte
with popvsvac (continent, location, date, population, new_vaccinations, CummulativePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
From CovidDeath dea
join CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *, (CummulativePeopleVaccinated/population) * 100
from popvsvac

-- temp table
drop table if exists #PercentagePopulationVaccination
create table #PercentagePopulationVaccination 
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
CummulativePeopleVaccinated numeric,
)

insert into #PercentagePopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
From CovidDeath dea
join CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

Select *, (CummulativePeopleVaccinated/population) * 100 as PercentagePopulationVaccination
from #PercentagePopulationVaccination

--Create view to store data for later visualisation
create view PercentagePopulationVaccination as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as CummulativePeopleVaccinated
From CovidDeath dea
join CovidVaccination vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

select *
from PercentagePopulationVaccination