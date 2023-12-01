select *
from 
order by 3,4

--select*
--from Portfolioproject..covidvaccinations
--order by 3,4

select location, DATE, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

-- Looking at Total cases vs Total deaths
-- shows what percentage of population got covid

select location, DATE, total_cases, total_deaths, (total_deaths/total_cases)
from portfolioproject..coviddeaths


--- CHANGING DATA TYPE ---

--update portfolioproject..coviddeaths
--set total_deaths = null
--where ISNUMERIC(total_deaths) =0

--alter table portfolioproject..coviddeaths
--alter column total_deaths INT

--update portfolioproject..coviddeaths
--set  total_cases = null
--where ISNUMERIC(total_cases)=0

--alter table portfolioproject..coviddeaths
--alter column total_cases INT


select location, DATE, total_cases, total_deaths
from portfolioproject..coviddeaths
order by 1,2

select portfolioproject..coviddeaths.total_cases, data_type
from INFORMATION_SCHEMA.columns
where table_name=portfolioproject..coviddeaths and COLUMN_NAME=total_cases

drop table portfolioproject..coviddeaths

select location, DATE, total_cases, total_Deaths, (total_deaths/total_cases)*100
from portfolioproject..coviddeaths
order by 1,2

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'coviddeaths';

update coviddeaths
set total_cases = CAST(total_cases AS float)

select location, DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
from coviddeaths

SELECT total_deaths, total_cases
FROM coviddeaths
WHERE ISNUMERIC(total_deaths) = 0 OR ISNUMERIC(total_cases) = 0;

UPDATE coviddeaths
SET 
    total_deaths = NULLIF(CAST(total_deaths AS float), 0),
    total_cases = NULLIF(CAST(total_cases AS float), 1)

---	*** VERY IMP FORMULA FOR WRONG DATA TYPE INT, use the below formula aptly, source - comment section, project portfolio, alex the analyst

Select location, date, population, total_cases,

(CONVERT(float, total_cases) / NULLIF(CONVERT(float, "population"), 0)) * 100 AS Infectionrate
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1,2

--- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as Casespercountry,

(CONVERT(float, max(total_cases)) / NULLIF(CONVERT(float, max(population)), 0)) * 100 AS Infectionrate
from PortfolioProject..covidDeaths
group by location, population
order by Infectionrate desc

-- countries with the highest death count per population

Select location, population, max(total_deaths) as deathspercountry,

(CONVERT(float, max(total_deaths)) / NULLIF(CONVERT(float, max(population)), 0)) * 100 AS deathrate
from PortfolioProject..covidDeaths
group by location, population
order by deathrate desc

select total_deaths, total_cases, 
CONVERT(float,total_deaths) as total_death_float, CONVERT(float,total_cases) as total_cases_float
from Portfolioproject..coviddeaths

select (total_death_float/total_cases_float)

select continent, MAX(cast(total_deaths AS float)) as totaldeathcount
from Portfolioproject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- showing continents with the highest death count per population

select continent, MAX(cast(total_deaths AS float)) as totaldeathcount
from Portfolioproject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers

select  SUM(new_cases) as totalcases, SUM(new_deaths) totaldeaths, 
		case
		when sum(new_cases) = 0 then null
		else sum(new_deaths)/sum(new_cases)*100
		end as 'death%'
from  Portfolioproject..coviddeaths
where continent is not null
-- group by date
order by 1,2


--  looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population,convert(float,vac.new_vaccinations) newvaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Portfolioproject..covidvaccinations as vac
join Portfolioproject..coviddeaths as dea
on	dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null
order by location, date

-- cte

with popvsvac(continent, location, date, population, newvaccinations, rollingpeoplevaccinated) as 
(select dea.continent, dea.location, dea.date, dea.population,convert(float,vac.new_vaccinations) newvaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Portfolioproject..covidvaccinations as vac
join Portfolioproject..coviddeaths as dea
on	dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (rollingpeoplevaccinated/population)*100 as vaccinatedperpopulation
from popvsvac
order by 7 desc

-- temp table

drop table if exists #POPVSVAC1
CREATE TABLE #POPVSVAC1
(continent VARCHAR (100), 
location VARCHAR (100), 
date datetime, 
population numeric, 
newvaccinations numeric, 
rollingpeoplevaccinated numeric)

insert into #POPVSVAC1 
select dea.continent, dea.location, dea.date, dea.population,convert(float,vac.new_vaccinations) newvaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Portfolioproject..covidvaccinations as vac
join Portfolioproject..coviddeaths as dea
on	dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100 vaccinatedperpopulation
from #POPVSVAC1
order by vaccinatedperpopulation desc

create view portfolioproject..POPVSVAC1 as
select dea.continent, dea.location, dea.date, dea.population,convert(float,vac.new_vaccinations) newvaccinations
,SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from Portfolioproject..covidvaccinations as vac
join Portfolioproject..coviddeaths as dea
on	dea.location = vac.location
and  dea.date = vac.date
where dea.continent is not null

select *
from portfolioproject.dbo.POPVSVAC1

