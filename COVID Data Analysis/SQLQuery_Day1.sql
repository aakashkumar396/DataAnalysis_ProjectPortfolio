--Covid Deaths Data Exploration-----------------

select * 
from AnalystPortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from AnalystPortfolioProject..CovidVaccinations
--order by 3,4

--selecting data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population  
from AnalystPortfolioProject..CovidDeaths
order by 1,2

--checking total_cases VS total_deaths
--shows likelihood of dying if you contract covid in yur country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from AnalystPortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--looking at total_cases VS Population
--showing what percentage of population got COVID
select location, date, population, total_cases, (total_cases/population)*100 as Covid_Population_Percentage
from AnalystPortfolioProject..CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2

--searching at countries with highest infection rate compared to popualtion
select location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as Covid_Population_Percentage
from AnalystPortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by location, population
order by Covid_Population_Percentage desc

--Highest Death Percentage per Population
select location, max(cast(total_deaths as int)) as Death_Count
from AnalystPortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by location
order by Death_Count desc


--Breaking down records by Continent

--Showing Continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeath_Count
from AnalystPortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by continent
order by TotalDeath_Count desc


--Global Numbers of Death
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from AnalystPortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
--Group by date
order by 1, 2
-------------------------------------------------------------------------------------------------------------

--Covid Vaccination Data Exploration-------------

select * 
from AnalystPortfolioProject..CovidVaccinations

--Total Population Vs Vaccinations (By using CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPopulationVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.Location order by dea.location, dea.date) as 
TotalPopulationVaccinated
-- ,(TotalPopulationVaccinated/population)*100
from AnalystPortfolioProject..CovidDeaths dea
join AnalystPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (TotalPopulationVaccinated/Population)*100
from PopvsVac


--Temp Table

DROP Table if exist #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPopulationVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.Location order by dea.location, dea.date) as 
TotalPopulationVaccinated
-- ,(TotalPopulationVaccinated/population)*100
from AnalystPortfolioProject..CovidDeaths dea
join AnalystPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (TotalPopulationVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for visualization
create view PercentPopulationVaccinated01 as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.Location order by dea.location, dea.date) as 
TotalPopulationVaccinated
-- ,(TotalPopulationVaccinated/population)*100
from AnalystPortfolioProject..CovidDeaths dea
join AnalystPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated



