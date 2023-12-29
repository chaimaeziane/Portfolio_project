select * 
from CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location like '%state%'
order by 1, 2

select location, date, total_cases, population, (total_cases/population)*100 as cases_porcentage
from CovidDeaths
where location like '%state%'
order by 1, 2

select location, population, MAX(total_cases), MAX ((total_cases/population))*100 as cases_porcentage
from CovidDeaths
GROUP BY location, population
order by cases_porcentage

select location, max(cast(total_deaths as int)) as highest_death_count
from CovidDeaths
where continent is not null
group by location
order by highest_death_count desc

select location, max(cast(total_deaths as int)) as highest_death_count
from CovidDeaths
where continent is null
group by location
order by highest_death_count


select date, sum(new_cases) as totalcases, sum(cast (new_deaths as int)) as totaldeaths, sum (cast (new_deaths as int))/sum(new_cases)*100 as totaldeathpercases
from coviddeaths
where continent is not null
and new_cases > 0
group by date
order by date

select sum( new_cases), sum (cast (new_deaths as int)), sum (cast (new_deaths as int))/sum( new_cases)*100
from CovidDeaths

select*
from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3


with populationvsvaccinated (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
)
select*, Rolling_People_Vaccinated/population*100
from populationvsvaccinated 

DROP TABLE IF EXISTS  #percentageofvaccinatedpeople
create table #percentageofvaccinatedpeople
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population int, 
new_vaccinations numeric, 
Rolling_People_Vaccinated numeric)

insert into #percentageofvaccinatedpeople 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null

select*, Rolling_People_Vaccinated/population*100
from  #percentageofvaccinatedpeople 

CREATE VIEW Percentageofvaccinatedpeople as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as Rolling_People_Vaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
