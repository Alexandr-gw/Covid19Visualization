--select * from t1 order by 3,4;
--select * from t2 order by 3,4;
--select location, date_, total_cases, new_cases, total_deaths, population from t1 order by 1,2;

--TOTAL CASE & TOTAL DEATHS

select location, date_, total_cases, total_deaths, 
(to_number(total_deaths, '9999999999.99')/to_number(total_cases,'9999999999.99'))*100 as Deaths_By_Case 
from t1 
where location like 'Poland' 
order by 1,2;

--TOTAL CASE & POPULATION

select location, date_, total_cases, population, 
(to_number(total_cases, '9999999999.99')/to_number(population,'9999999999.99'))*100 as Case_By_Population 
from t1 
where location like 'Poland' 
order by 1,2;


--COUNTRIES TOTAL CASES & POPULATION 

select location, MAX(to_number(total_cases, '9999999999.99')) as Highest_Total_Cases, max(population), 
MAX(to_number(total_cases, '9999999999.99')/to_number(population,'9999999999.99'))*100 as Case_by_Population 
from t1 where continent is not null
group by location
order by 4 DESC nulls last;


--COUNTRIES TOTAL DEATHS & POPULATION 

select location, MAX(to_number(total_deaths, '9999999999.99')) as Highest_Total_Deaths, max(population), 
MAX(to_number(total_deaths, '9999999999.99')/to_number(population,'9999999999.99'))*100 as Deaths_by_Population 
from t1 where continent is not null
group by location
order by 4 DESC nulls last;

-- CONTINENTS DATA

-- DATA PER DAY

select date_, SUM(to_number(new_cases, '9999999999.99'))as DayTotalCases, SUM(to_number(new_deaths, '9999999999.99'))as DayTotalDeaths, 
SUM(to_number(new_deaths, '9999999999.99'))/SUM(to_number(new_cases, '9999999999.99'))*100 as PercentageOfNewDeaths
from t1 
where continent is not null
GROUP BY date_
order by 1;

-- POPULATION & VACCINATION RELATION (+CTE)
with PopAndVaccinations (Continent, Location, Date_,Population, New_Vaccination, CalculatingVaccinations)
as(
select t1.continent, t1.location, t1.date_, t1.population, t2.new_vaccinations,
sum(to_number(t2.new_vaccinations, '9999999999.99')) over (partition by t1.location order by t1.location, t1.date_) as CalculatingVaccinations
--,(CalculatingVaccinations/t1.population)*100 as PercetByPopulation
from t1 join t2 on (t1.location=t2.location and t1.date_=t2.date_)
where t1.continent is not null 
--order by 2,3
) 
select Continent, Location, Date_,Population, New_Vaccination, CalculatingVaccinations
,(CalculatingVaccinations/to_number(population,'9999999999.99'))*100
from PopAndVaccinations
order by 7 desc nulls last;


-- CREATING VIEW FOR NEXT VIZUALIZATION

create view PopulationAndVaccinations as (
select t1.continent, t1.location, t1.date_, t1.population, t2.new_vaccinations,
sum(to_number(t2.new_vaccinations, '9999999999.99')) over (partition by t1.location order by t1.location, t1.date_) as CalculatingVaccinations
from t1 join t2 on (t1.location=t2.location and t1.date_=t2.date_)
where t1.continent is not null 
);

select * from PopulationAndVaccinations;

-- 1

select SUM(to_number(new_cases, '9999999999.99'))as DayTotalCases, SUM(to_number(new_deaths, '9999999999.99'))as DayTotalDeaths, 
SUM(to_number(new_deaths, '9999999999.99'))/SUM(to_number(new_cases, '9999999999.99'))*100 as PercentageOfNewDeaths
from t1 
where continent is not null
GROUP BY date_
order by 1;

-- 2

select location, SUM(to_number(new_deaths, '9999999999.99'))as TotalDeaths, 
SUM(to_number(new_deaths, '9999999999.99'))/SUM(to_number(new_cases, '9999999999.99'))*100 as PercentageOfDeaths
from t1 
where continent is null and location not in ('European Union', 'World', 'International')
group by location
order by 1;

-- 3

select location, to_number(population, '9999999999.99')as Population, max(to_number(total_cases, '9999999999.99')) as TotalCase,
max(to_number(total_cases, '9999999999.99'))/to_number(population, '9999999999.99')*100 as PercentageOfInfaction
from t1 
where continent is not null
group by location, population
order by 1;

-- 4

select location, to_number(population, '9999999999.99')as Population, date_, max(to_number(total_cases, '9999999999.99')) as TotalCase,
max(to_number(total_cases, '9999999999.99'))/SUM(to_number(population, '9999999999.99'))*100 as PercentageOfInfaction
from t1 
where continent is not null
group by location, population, date_
order by 5 desc nulls last;