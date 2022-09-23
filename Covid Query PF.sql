Select *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select *
--FROM CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using
Select Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Total Cases vs. Total Deaths
Select Location, Date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Total Cases vs. Population
Select Location, Date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Countries with highest infection rate compaired to population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectionPercentage
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY InfectionPercentage desc

--By Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--removes countries, only includes continents
WHERE continent is null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc

--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers
Select Date, Sum(new_cases)as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by Date
ORDER BY 1,2


--Select*
--From [Portfolio Project]..CovidDeaths dea
--Join [Portfolio Project]..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date


--Total Pop vs Vaccinations (Using Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinatedRolling)
	as
	(
Select dea.continent, dea.location, dea.date, dea.population as Population, vac.new_vaccinations as NewVaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
--, (RollingPeoppleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select*, (PeopleVaccinatedRolling/Population)*100 as PercentagePopVaccinated
	from PopvsVac


--Total Pop vs Vaccinations (Using temp table)

DROP Table if exists #PercentagePopVaccinated
Create Table #PercentagePopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedRolling numeric
)

Insert into #PercentagePopVaccinated
Select dea.continent, dea.location, dea.date, dea.population as Population, vac.new_vaccinations as NewVaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
--, (RollingPeoppleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select*, (PeopleVaccinatedRolling/Population)*100 as PercentagePopVaccinated
	from #PercentagePopVaccinated



--Creating view to store data for later visualization

Create View PercentagePopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population as Population, vac.new_vaccinations as NewVaccinations
, Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as PeopleVaccinatedRolling
--, (RollingPeoppleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select *
FROM PercentagePopVaccinated