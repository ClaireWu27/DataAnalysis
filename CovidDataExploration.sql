SELECT  *
from CovidDeaths;

SELECT  *
from CovidVaccinations;

-- select data is to be used

SELECT location ,`date` ,total_cases ,new_cases ,total_deaths ,population
from CovidDeaths;

-- looking at total case vs total deaths
SELECT  location ,`date` ,total_cases ,total_deaths, (total_deaths /total_cases)*100 as DeathPercentage
from CovidDeaths
WHERE  location like '%state%'
order by 1,2;


-- looking at total cases vs population
select  location ,`date` ,total_cases ,population,  (total_cases/population)*100 as CasePercentage
from CovidDeaths
order by 1,2;


-- looking at countries with highest infection rate

select location, population, total_cases ,(total_cases/population)*100 as InfectionRate
FROM CovidDeaths
group by location, population, total_cases
having InfectionRate =  (select max((total_cases/population)*100 )
                                      from CovidDeaths
                                   );
                                  
-- showing contries with highest death percentage
select  location, population, total_deaths,(total_deaths/population)*100 as DeathRate                                
from CovidDeaths  
group by location, population, total_deaths
having DeathRate=(select max((total_deaths/population)*100)
                  from CovidDeaths );
                 
--  global numbers 
select date, sum(new_cases) newCaseSum,sum(new_deaths) newDeathSum         
from CovidDeaths 
where continent  is not null 
group by `date` 
order by newCaseSum desc ;


with PopVsVac(continent, location,date,population, new_vaccinations, RollingPeopleVaccinated)
as(
select cd.continent ,cd.location ,cd.`date` ,cd.population,cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.`date`) as RollingPeopleVaccinated
from CovidDeaths cd 
join CovidVaccinations cv 
on cd.location =cv.location and cd.`date` =cv.`date` 
where cd.continent is not null
-- order by cv.new_vaccinations  desc
)
select *,(RollingPeopleVaccinated/population)*100 
from PopVsVac

drop table if exists PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated double
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, nullif(vac.new_vaccinations,'')
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths  dea
Join CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

-- create view to store data for later visilization
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, nullif(vac.new_vaccinations,'')
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths  dea
Join CovidVaccinations  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

