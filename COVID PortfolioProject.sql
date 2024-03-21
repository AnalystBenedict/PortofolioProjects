SELECT Location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths
order by 1,2


--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
where Location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as infectedpopulationpercentage
from Portfolioproject..CovidDeaths
--where Location like '%states%'
order by 1,2 

--looking at countries with higest infection rate compared to population

SELECT Location, population, Max(total_cases) as highestinfectioncount, Max ((total_cases/population))*100 as infectedpopulationpercentage
FROM Portfolioproject..CovidDeaths
--where Location like '%states%'
group by location , population
order by infectedpopulationpercentage desc

--showing countries with higest death count per population

SELECT Location, Max(cast(total_deaths as int)) as totaldeathcount
FROM Portfolioproject..CovidDeaths
--where Location like '%states%'
where continent is not null
group by location 
order by totaldeathcount desc 


--LET'S BREAK THINGS UP BY CONTINENT 

SELECT continent, Max(cast(total_deaths as int)) as totaldeathcount
FROM Portfolioproject..CovidDeaths
--where Location like '%states%'
where continent is NOT null
group by continent
order by totaldeathcount desc  --INCLUD IN VIEW

--global numbers


SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
--where Location like '%states%'
where continent  is not null
group by date
order by 1,2

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
--where Location like '%states%'
where continent  is not null
--group by date
order by 1,2  --INCLUDE IN VIEW


--looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as rollingpeoplevaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	--USE CTE

WITH Popvsvac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as rollingpeoplevaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3 
	)
	select *, (rollingpeoplevaccinated/population)*100
	from popvsvac

	--temp table

	drop table if EXISTS #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as rollingpeoplevaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	select *, (rollingpeoplevaccinated/population)*100
	from #percentpopulationvaccinated

	--CREATING VIEW TO STORE DATA FOR VISUALIZATION

	CREATE VIEW percentpopulationvaccinated AS
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
 as rollingpeoplevaccinated
from  Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3


	 SELECT *
	 from percentpopulationvaccinated


	create view deathpercentage as
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
--where Location like '%states%'
where continent  is not null
group by date
--order by 1,2 

select * 
from deathpercentage



create view totaldeathcount as
SELECT continent, Max(cast(total_deaths as int)) as totaldeathcount
FROM Portfolioproject..CovidDeaths
--where Location like '%states%'
where continent is NOT null
group by continent
--order by totaldeathcount desc  --INCLUD IN VIEW

select * 
FROM totaldeathcount


