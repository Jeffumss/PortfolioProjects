Select *
From JeffumsPortfolio.coviddeaths
where continent not like ''
order by 3,4;

-- Select *
-- From JeffumsPortfolio.covidvaccines
-- order by 3,4;

-- Selecting my data

Select location, date, total_cases, new_cases, total_deaths, population
From JeffumsPortfolio.coviddeaths
where continent not like ''
order by 1,2;

-- Looking at the Total Cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deaths_percentage
From JeffumsPortfolio.coviddeaths
Where location like '%states%' and continent not like ''
order by 1,2;

-- Looking at Total Cases vs Population
-- shows percentage of population that got covid
Select location, date,population, total_cases, (total_cases/population) * 100 as percentage_population_infected
From JeffumsPortfolio.coviddeaths
Where location like '%states%' and continent not like ''
order by 1,2;


-- Looking at Countries wt Highest Infection Rate compared to Population
Select location,population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)) * 100 as percentage_population_infected
From JeffumsPortfolio.coviddeaths
where continent not like ''
-- Where location like '%states%'
group by location, population
order by percentage_population_infected desc;

-- Showing Countries wt Highest Death Count per the Population
Select location, MAX(cast(total_deaths as double)) as TotalDeathCount
From JeffumsPortfolio.coviddeaths
where continent not like ''
Group by location
Order by TotalDeathCount desc;

-- SELECT @@GLOBAL.sql_mode;
-- -- SELECT @@SESSION.sql_mode;
-- SET @@global.sql_mode= 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
-- SET GLOBAL sql_mode = 'NO_BACKSLASH_ESCAPES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
-- set global sql_mode='NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
-- set session sql_mode='';
-- SHOW VARIABLES LIKE 'sql_mode';
-- select @@GLOBAL.sql_mode;


-- BREAKING DOWN BY CONTINENT

-- Showing Continents wt Highest Death Count per Population
Select continent, MAX(cast(total_deaths as double)) as TotalDeathCount
From JeffumsPortfolio.coviddeaths
where continent not like ''
Group by continent
Order by TotalDeathCount desc;


-- GLOBAL NUMBERS

-- Showing total cases, deaths, and the percentage 
Select SUM(new_cases)as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths) / SUM(new_cases) *100 as DeathPercentage
From JeffumsPortfolio.coviddeaths
Where continent not like ''
-- Group by date
order by 1,2;

-- Showing US totals cases, deaths, percentage over time
Select date, SUM(new_cases)as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths) / SUM(new_cases) *100 as DeathPercentage
From JeffumsPortfolio.coviddeaths
Where location like '%states%'
and continent not like ''
Group by date
order by 1,2;



-- Looking at Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one Covid-19 vaccine

Select Distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, double)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From JeffumsPortfolio.coviddeaths dea
Join JeffumsPortfolio.covidvaccines vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent not like ''
Order by 2,3;


-- Using a CTE(common table expression) to perform calculation on Partion By in previous query 
With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as 
(
Select Distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, double)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From JeffumsPortfolio.coviddeaths dea
Join JeffumsPortfolio.covidvaccines vac
	on dea.date = vac.date
	and dea.location = vac.location
Where dea.continent not like ''
-- Order by 2,3; 
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac;

-- TEMP TABLE
DROP TABLE if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select Distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, double)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From JeffumsPortfolio.coviddeaths dea
Join JeffumsPortfolio.covidvaccines vac
	on dea.date = vac.date
	and dea.location = vac.location
	Where dea.continent not like '';
-- Order by 2,3;

Select *, (RollingPeopleVaccinated/Population) * 100
From PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE View PercentPopVaccinated as 
Select Distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, double)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From JeffumsPortfolio.coviddeaths dea
Join JeffumsPortfolio.covidvaccines vac
	on dea.date = vac.date
	and dea.location = vac.location
	Where dea.continent not like '';
-- Order by 2,3;

Select *,(RollingPeopleVaccinated/Population) * 100
From percentpopvaccinated
Where location like '%states%';


