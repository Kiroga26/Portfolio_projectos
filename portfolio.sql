
SELECT location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
where continent is not null
order by 1,2

-- procurando total de casos vs mortes
-- mostra a probalidade de morte se contrair covid em Portugal

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as porcentagem_Mortes
from Portfolio..CovidDeaths
WHERE location = 'Portugal'
order by 1,2

-- procurar total de casos vs população
-- mostra a porcentagem de populaçao que contraiu covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as porcentagem_populaçao
from Portfolio..CovidDeaths
WHERE location = 'Portugal'
where continent is not null
order by 1,2

-- procurar os paises com maior porcentagem de infeção comparado com a população

SELECT location, population, MAX(total_cases) as MaiorcontagemInfeçao, MAX((total_cases/population))*100 as porcentagem_populaçao
from Portfolio..CovidDeaths
--WHERE location = 'Portugal'
where continent is not null
Group by location, population
order by porcentagem_populaçao desc

-- Mostrar paises com maior taxa de mortes por populacao

SELECT location, MAX(cast(total_deaths as int))as TotalMortes
from Portfolio..CovidDeaths
--WHERE location = 'Portugal'
where continent is not null
Group by location
order by TotalMortes desc

-- Vamos verificar por Continente

SELECT continent, MAX(cast(total_deaths as int))as TotalMortes
from Portfolio..CovidDeaths
--WHERE location = 'Portugal'
where continent is not null
Group by continent
order by TotalMortes desc

-- Numeros Globais

SELECT date, sum(new_cases) as Novoscasos, sum(cast(new_deaths as int)) as NovasMortes, (sum(cast(new_deaths as int))/sum(new_cases))*100 as porcentagem_Mortes
from Portfolio..CovidDeaths
--WHERE location = 'Portugal'
where continent is not null
GROUP BY date
order by 1,2

SELECT sum(new_cases) as Novoscasos, sum(cast(new_deaths as int)) as NovasMortes, (sum(cast(new_deaths as int))/sum(new_cases))*100 as porcentagem_Mortes
from Portfolio..CovidDeaths
--WHERE location = 'Portugal'
where continent is not null
--GROUP BY date
order by 1,2

-- procurar o total populaçao vs vacinaçao

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by 
dea.location, dea.date) as PessoasVacinadasdecorrendo
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

-- Usar CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, PessoasVacinadasdecorrendo)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by 
dea.location, dea.date) as PessoasVacinadasdecorrendo
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (PessoasVacinadasdecorrendo/population)*100
FROM PopvsVac

-- Criar tabela Temp
DROP TABLE if #PercentagemPessoasVacinadas

CREATE TABLE #PercentagemPessoasVacinadas
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PessoasVacinadasDecorrendo numeric
)

Insert Into #PercentagemPessoasVacinadas
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by 
dea.location, dea.date) as PessoasVacinadasDecorrendo
--, (PessoasVacinadasDecorrendo
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--ORDER BY 2,3


SELECT *, (PessoasVacinadasdecorrendo/population)*100
FROM #PercentagemPessoasVacinadas

-- criar View

CREATE VIEW PessoasVacinadasDecorrendo as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by 
dea.location, dea.date) as PessoasVacinadasDecorrendo
--, (PessoasVacinadasDecorrendo
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null