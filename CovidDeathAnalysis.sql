select * 
from CovidDeaths
order by 3,4

--select * 
--from CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- total cases vs total deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from CovidDeaths
where location like '%kingdom%' and continent is not null
order by 1,2

-- total cases vs population 
select Location, date, population, total_cases, (total_cases/population)*100 as RateofCases 
from CovidDeaths
where location like '%kingdom%' and continent is not null
order by 1,2

-- look at countries with highest infection rate compared to population
select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as RateofCases 
from CovidDeaths
--where location like '%kingdom%'
group by population, Location
order by RateofCases desc

-- countries with highest death rate compared to population 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where continent is not null
group by location
order by TotalDeathCount desc

-- continents with highest death rate per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- global numbers
-- continents with highest death rate per population
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from CovidDeaths
where continent is not null
group by date
order by 1,2

--CTE 
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as 
(
-- total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp table

Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated

-- Creating View to store data for visualizations

Create View PercentagePopulationVaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations)) 
over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v 
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3

select * 
from #PercentagePopulationVaccinated