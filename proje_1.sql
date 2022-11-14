
select location, max(cast(total_deaths as int))

from DOGUKAN..CovidDeaths
where continent =''
group by location
order by 1 desc

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathrate


from DOGUKAN.dbo.CovidDeaths
where location like 'Turkey' and continent is not null
order by 1,2


select location, date,population, total_cases, total_deaths, (total_cases/population)*100 as cases_pop


from DOGUKAN.dbo.CovidDeaths
where location like 'Turkey' and continet !=''
order by 1,2


 looking at countries at highest infection rate comppared to population
select location,population, max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as infection_rate 

from DOGUKAN.dbo.CovidDeaths
where continent continet !=''
group by   location , population

order by 4 desc



select location, max(cast(total_deaths as int)) as totaldeathcount

from DOGUKAN.dbo.CovidDeaths
where continent !=''
group by   location , population

order by 2 desc

select location, max(cast(total_deaths as int)) as totaldeathcount

from DOGUKAN.dbo.CovidDeaths
where continent='' and location not like '%income%'
group by   location 

order by 2 desc


select location, max(cast(total_deaths as int)) as totaldeathcount, population

from DOGUKAN.dbo.CovidDeaths
where location = 'Germany' or location = 'Turkey'
--where continent!='' and location not like '%income%'
group by   location, population 

order by 2 desc

 Global Numbers

select   sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths  , sum(cast(new_deaths as int))/ sum(new_cases )*100 as death_pearcent

from DOGUKAN.dbo.CovidDeaths
where  continent is not null and new_cases !=0

--group by date
order by 1,2

select de.continent, de.location, de.population ,sum( va.new_vaccinations) over (partition by month(de.date))as aylýk_vac, sum(va.new_vaccinations) over (partition by year(de.date)) as yýllýk_vac,year(de.date) as yýl
 
from DOGUKAN..CovidDeaths de
JOIN DOGUKAN..CovidVaccinations va ON de.location=va.location and de.date=va.date
where de.continent !='' and de.location='Turkey'
group by de.continent,de.location,de.population,de.date,va.new_vaccinations
order by 6


select de.continent, de.location, de.population , va.new_vaccinations, de.date,

 sum(convert(bigint,(va.new_vaccinations)))  over ( PARTITION BY de.location order by de.location ,de.date) as total_vac

from DOGUKAN..CovidDeaths de
JOIN DOGUKAN..CovidVaccinations va ON de.location=va.location and de.date=va.date
where de.continent !=''
order by 2,5




WITH CTE1 (continent,location,date,population,new_vaccinations,total_vac) 
as 
(
select de.continent, de.location,de.date, de.population , va.new_vaccinations,

 sum(convert(bigint,(va.new_vaccinations)))  over ( PARTITION BY de.location order by de.location ,de.date) as total_vac

from DOGUKAN..CovidDeaths de
JOIN DOGUKAN..CovidVaccinations va ON de.location=va.location and de.date=va.date
where de.continent !=''
--order by 2,5
)
select continent,location,date,population,sum(total_vac) over (partition by date) as sum_tot_vac, (total_vac/population)*100 as totalvacvspop,

(select case 
	WHEN total_vac = 0 then  null 
	else total_vac
	end as total_vac_new)
	,population,continent,location

from CTE1

GROUP BY continent,location,population,total_vac,date
order by 3,5,6

WITH CTE1 (continent,location,date,population,new_vaccinations,total_vac) 
as 
(
select de.continent, de.location,de.date, de.population/10 , va.new_vaccinations,

 sum(convert(bigint,(va.new_vaccinations)))  over ( PARTITION BY de.location order by de.location ,de.date) as total_vac

from DOGUKAN..CovidDeaths de
JOIN DOGUKAN..CovidVaccinations va ON de.location=va.location and de.date=va.date
where de.continent !=''
--order by 2,5
)
select distinct location,population,--sum(total_vac) over (partition by date) as sum_tot_vac
max((total_vac/population)*100) as totalvacvspopmax 

--select case 
--	WHEN total_vac = 0 then  null 
--	else total_vac
--	end as total_vac_new
--	,population,continent,location

from CTE1
--where location like '%nether%'
GROUP BY location,population
order by 3 desc

select location ,population from DOGUKAN..CovidDeaths 
where location = 'Turkey'
group by location,population


select
	case
		when try_convert(int, replace(new_vaccinations,'.',',')) is not null
		
		then 'notdone'
		else 'done'
	end as cevirme 
, new_vaccinations

from DOGUKAN..CovidVaccinations


select new_vaccinations,
	case 
		when ISNUMERIC(new_vaccinations)=1
		then
		convert(decimal(18,2),new_vaccinations)
		else 0 
		end as deneme
		
from DOGUKAN..CovidVaccinations


select len(new_vaccinations) as uzunluk--new_vaccinations

		
from DOGUKAN..CovidVaccinations

group by len(new_vaccinations)
order by 1 


create table #percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
total_vac bigint

)
Insert into #percentpopvac
select de.continent, de.location,de.date, de.population , va.new_vaccinations,

 sum(convert(bigint,(va.new_vaccinations)))  over ( PARTITION BY de.location order by de.location ,de.date) as total_vac

from DOGUKAN..CovidDeaths de
JOIN DOGUKAN..CovidVaccinations va ON de.location=va.location and de.date=va.date
where de.continent !=''


select  *,(total_vac/population)*100 

from #percentpopvac
DROP TABLE #percentpopvac





--FARKLI BÝR YÖNTEM
select  *INTO #percentpopvac

from
(
select de.continent, de.location,de.date, de.population , va.new_vaccinations,

 sum(convert(bigint,(va.new_vaccinations)))  over ( PARTITION BY de.location order by de.location ,de.date) as total_vac

from DOGUKAN..CovidDeaths de
JOIN DOGUKAN..CovidVaccinations va ON de.location=va.location and de.date=va.date
where de.continent !=''
) AS DG

SELECT *,(new_vaccinations/population)*100 as vac_pop FROM #percentpopvac
DROP TABLE #percentpopvac
