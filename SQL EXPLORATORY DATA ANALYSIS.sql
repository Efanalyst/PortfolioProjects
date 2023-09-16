--Exploratory data analysis

use PortfolioProject


select *
from PortfolioProject..CovidDeathsCS
where continent is not null

select location, date, total_cases, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeathsCS
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying from covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeathsCS
where location like '%kingdom%'
where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what Percentage of Population got Covid
select location, date,population, total_cases,  (total_cases/population)*100 as percentageOfPopInfected
from PortfolioProject..CovidDeathsCS
where continent is not null
where location like '%kingdom%'

--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as
percentageOfPopInfected
from PortfolioProject..CovidDeathsCS
where continent is not null
--where location like '%kingdom%'
group by location, population
order by percentageOfPopInfected desc

--showing the countries with the highest death count
select location, max(total_deaths) as TotalDeathsCount
from PortfolioProject..CovidDeathsCS
--where location like '%kingdom%'
where continent is not null
group by location
order by TotalDeathsCount desc

-- BREAKDOWN BY CONTINENT 
select continent, max(total_deaths) as TotalDeathsCount
from PortfolioProject..CovidDeathsCS
--where location like '%kingdom%'
where continent is not null
group by continent
order by TotalDeathsCount desc

--Showing the Continent with the highest Death Count
select continent, max(total_deaths) as TotalDeathsCount
from PortfolioProject..CovidDeathsCS
--where location like '%kingdom%'
where continent is not null
group by continent
order by TotalDeathsCount desc


--GLOBAL NUMBERS
select sum(total_cases) as total_cases, sum(total_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeathsCS
--where location like '%kingdom%'
where continent is not null
order by 1,2

--total population vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over
(partition by d.location order by d.location, d.date) as rollingpeoplevac
from PortfolioProject..CovidDeathsCS d
join PortfolioProject..CovidVaccinationsCSV v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3

--use cte
with PopvsVac (continent, location, population, date, new_vaccinations, rollingpeoplevac)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over
(partition by d.location order by d.location, d.date) as rollingpeoplevac
from PortfolioProject..CovidDeathsCS d
join PortfolioProject..CovidVaccinationsCSV v
on d.location = v.location
and d.date = v.date
where d.continent is not null
)

select *, (rollingpeoplevac/population)*100
from PopvsVac

-- temp table
create table #PercentPopulationVaccinated
(
continent nvarchar(50)
location varchar(50)
date datetime
population numeric
new_vaccinations numeric
rollingpeoplevac numeric
)
insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over
(partition by d.location order by d.location, d.date) as rollingpeoplevac
from PortfolioProject..CovidDeathsCS d
join PortfolioProject..CovidVaccinationsCSV v
on d.location = v.location
where d.continent is not null

select *, (rollingpeoplevac/population)*100
from #PercentPopulationVaccinated
