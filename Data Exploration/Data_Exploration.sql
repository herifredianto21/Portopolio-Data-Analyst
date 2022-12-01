

--looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


--looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as PercenPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


--looking at countries with Highest Infection Rate compared to Population 
--Select Location, Population, MAX(total_cases) as HighestInfectionCount,	MAX((total_cases/population))*100 as DeathPercentage
--FROM PortofolioProject..CovidDeaths
--ORDER BY 1, 2


--looking at countries with Highest Infection Rate compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercenPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercenPopulationInfected DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with Highest Death Count per Population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount Desc


--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Menampilkan jumlah kasus dan kematian covid berdasarkan tanggal-bulan & tahun
SELECT date, location, SUM(CAST(new_cases as int)) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths
FROM PortofolioProject..CovidDeaths
WHERE location like '%indonesia%'
GROUP BY date, location
Order by date Desc


-- Looking at Total Population vs Vaccinations
SELECT covDeaths.continent, 
	   covDeaths.location, 
	   covDeaths.date, 
	   covDeaths.population, 
	   covVac.new_vaccinations, 
	   SUM(CONVERT(int,covVac.new_vaccinations)) OVER (Partition by covDeaths.Location order by covDeaths.location, covDeaths.date) AS RollingPeopleVaccinated
	   --,(RollingPeopleVaccinated/population)*100

FROM PortofolioProject..CovidDeaths covDeaths
	JOIN PortofolioProject..CovidVaccinations covVac
ON covDeaths.location = covVac.location
	AND covDeaths.date = covVac.date
WHERE covDeaths.continent is not null
order by 2,3


With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT covDeaths.continent, 
	   covDeaths.location, 
	   covDeaths.date, 
	   covDeaths.population, 
	   covVac.new_vaccinations, 
	   SUM(CONVERT(int,covVac.new_vaccinations)) OVER (Partition by covDeaths.Location order by covDeaths.location, covDeaths.date) AS RollingPeopleVaccinated
	   --,(RollingPeopleVaccinated/population)*100

FROM PortofolioProject..CovidDeaths covDeaths
	JOIN PortofolioProject..CovidVaccinations covVac
ON covDeaths.location = covVac.location
	AND covDeaths.date = covVac.date
WHERE covDeaths.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT covDeaths.continent, 
	   covDeaths.location, 
	   covDeaths.date, 
	   covDeaths.population, 
	   covVac.new_vaccinations, 
	   SUM(CONVERT(int,covVac.new_vaccinations)) OVER (Partition by covDeaths.Location order by covDeaths.location, covDeaths.date) AS RollingPeopleVaccinated
	   --,(RollingPeopleVaccinated/population)*100

FROM PortofolioProject..CovidDeaths covDeaths
	JOIN PortofolioProject..CovidVaccinations covVac
ON covDeaths.location = covVac.location
	AND covDeaths.date = covVac.date
--WHERE covDeaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
SELECT covDeaths.continent, 
	   covDeaths.location, 
	   covDeaths.date, 
	   covDeaths.population, 
	   covVac.new_vaccinations, 
	   SUM(CONVERT(int,covVac.new_vaccinations)) OVER (Partition by covDeaths.Location order by covDeaths.location, covDeaths.date) AS RollingPeopleVaccinated
	   --,(RollingPeopleVaccinated/population)*100

FROM PortofolioProject..CovidDeaths covDeaths
	JOIN PortofolioProject..CovidVaccinations covVac
ON covDeaths.location = covVac.location
	AND covDeaths.date = covVac.date
WHERE covDeaths.continent is not null
