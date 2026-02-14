<?Este arquivo ainda será revisado, e incluirei os códigos das queries e os prints dos retornos delas.?>
# 🎮 Análise de Dados: Mercado Global de Games (SQL)

Neste projeto, apresento as queries que elaborei para transformar dados brutos em informações estratégicas sobre a indústria dos games ao longo de sua história.

## 🛠️ Tecnologias e Ferramentas
* **Banco de Dados:** SQLite
* **Ferramenta de Gerenciamento:** SQLiteStudio
* **Linguagem:** SQL (DQL - Data Query Language)

## 📂 Estrutura do Repositório
* **/script**: Arquivos `.sql` contendo a lógica de extração e os filtros por décadas.
* **/data**: Base de dados original (`vgsales.csv`). Fonte: [Kaggle](https://www.kaggle.com/datasets/gregorut/videogamesales)
* **/export**: Resultados das análises exportados em formato `.csv`, organizados por categoria de pedido.

## 🧹 Tratamento de Dados (Data Cleaning)
Durante a exploração da base, foi identificada a presença de mais de **200 registros** com a informação `N/A` na coluna `Year`. 

**Decisão técnica:** Como o objetivo era uma análise cronológica, esses registros com ano N/A foram desconsiderados nos cálculos que utilizam a coluna `Year`. Em um cenário real, seria solicitada uma base de dados mais completa para aumentar a amostragem. Para este projeto, a ausência do ano de lançamento será tratada futuramente na etapa de análise e visualização utilizando o **Microsoft Power BI**.

## 🔍 Etapas da Análise
O projeto foi estruturado para responder a três perguntas principais e realizar uma exportação técnica:
1. **Ranking de Elite:** Top 10 jogos mais vendidos por década.
2. **Filtro de Relevância:** Identificação das plataformas com maior volume de vendas globais.
3. **Market Share Regional:** Comparação do desempenho de vendas entre os principais mercados globais por década.
4. **Análise Direcionada:** Exportação da base completa de jogos dos 5 consoles líderes identificados na análise do item 2.

---

## 🔍 Detalhamento das Consultas SQL

### 1. Ranking de Elite: Top 10 por Década
**Objetivo:** Identificar os títulos que definiram cada geração, isolando os 10 maiores sucessos de cada período.

* **Lógica Técnica:** Utilizei **Subqueries** (subconsultas) para permitir que cada década tivesse seu próprio `LIMIT 10` de forma independente.
* **Agrupamento Cronológico:** Apliquei a função `FLOOR(Year/10)*10` para normalizar anos individuais em blocos de décadas.
* **Consolidação:** Usei o comando `UNION ALL` para empilhar os resultados e gerar um relatório único. 
```
SELECT * FROM (
    SELECT FLOOR(Year/10)*10 AS Decada, Name, Platform, Global_Sales 
    FROM Vendas
    WHERE Year BETWEEN 1980 AND 1989 
    ORDER BY Global_Sales DESC 
    LIMIT 10) AS d80

UNION ALL

SELECT * FROM (
    SELECT FLOOR(Year/10)*10 AS Decada, Name, Platform, Global_Sales 
    FROM Vendas
    WHERE Year BETWEEN 1990 AND 1999 
    ORDER BY Global_Sales DESC 
    LIMIT 10) AS d90
    
UNION ALL

SELECT * FROM (
    SELECT FLOOR(Year/10)*10 AS Decada, Name, Platform, Global_Sales 
    FROM Vendas
    WHERE Year BETWEEN 2000 AND 2009 
    ORDER BY Global_Sales DESC 
    LIMIT 10) AS d2000
    
UNION ALL

SELECT * FROM (
    SELECT FLOOR(Year/10)*10 AS Decada, Name, Platform, Global_Sales 
    FROM Vendas
    WHERE Year BETWEEN 2010 AND 2019 
    ORDER BY Global_Sales DESC 
    LIMIT 10) AS d2010

--Obter as plataformas que mais venderam jogos
SELECT Platform as Plataforma, SUM(Global_Sales) as Total_de_Vendas from Vendas
    GROUP BY plataforma
    HAVING Total_de_vendas > 275 
    ORDER BY Total_de_vendas DESC
```
> *Nota: Optei por essa estrutura, usando o UNION ALL em vez de Window Functions (ROW_NUMBER) como seria o ideal para explorar melhor Window Functions em outro projeto.*

### 2. Filtro de Relevância: Plataformas com Maior Volume
**Objetivo:** Analisar quais hardwares realmente dominaram o mercado global, ignorando plataformas de nicho ou baixo desempenho.

* **Lógica Técnica:** Além da agregação simples com `SUM`, utilizei a cláusula **`HAVING`**.
* **Critério de Sucesso:** O filtro `Total_de_vendas > 275` foi aplicado para garantir que apenas consoles com alto impacto histórico fossem listados.

```
SELECT Platform as Plataforma, SUM(Global_Sales) as Total_de_Vendas from Vendas
    GROUP BY plataforma
    HAVING Total_de_vendas > 275 
    ORDER BY Total_de_vendas DESC
```

### 3. Market Share: Vendas Regionais e Percentuais
**Objetivo:** Compreender a relevância de cada mercado e como eles mudaram com o passar das décadas.

* **Lógica Técnica:** Realizei cálculos matemáticos dentro do `SELECT` para gerar a participação percentual de cada região em relação ao total global.
* **Formatação:** Utilizei as funções **`ROUND`** para precisão decimal e o operador de concatenação **`|| '%'`** para entregar os dados formatados para leitura direta.

```
SELECT 
    (Year / 10) * 10 AS Década,
    SUM(NA_Sales) AS América_do_Norte, ROUND((SUM(NA_Sales)/SUM(Global_Sales))*100.0, 2) || '%' as Per_NA,
    SUM(JP_Sales) AS Japão, ROUND((SUM(JP_Sales)/SUM(Global_Sales))*100.0, 2) || '%' as Per_JP,
    SUM(EU_Sales) AS Europa, ROUND((SUM(EU_Sales)/SUM(Global_Sales))*100.0, 2) || '%' as Per_EU,
    SUM(Other_Sales) AS Outros, ROUND((SUM(Other_Sales)/SUM(Global_Sales))*100.0, 2) || '%' as Per_OU,
    SUM(Global_Sales) AS Global from Vendas
    WHERE Year BETWEEN 1979 AND 2019
    GROUP BY Década
    ORDER BY Década ASC
```

### 4. Análise Direcionada: Top 5 Consoles Históricos
**Objetivo:** Extrair a biblioteca completa de jogos das cinco plataformas líderes (PS2, X360, PS3, Wii, DS).

* **Lógica Técnica:** Utilizei o operador **`IN`** para filtragem múltipla e eficiente.
* **Ordenação Customizada:** Apliquei a estrutura **`ORDER BY CASE`**, técnica que permite definir uma ordem de exibição manual, garantindo que os dados sejam apresentados na hierarquia de importância definida pela análise.

```
SELECT 
    Rank, Platform, Name, Year, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales from Vendas
    WHERE Platform IN ('PS2', 'X360', 'PS3', 'Wii', 'DS')
    ORDER BY CASE platform 
        WHEN 'PS2' THEN 1
        WHEN 'X360' THEN 2
        WHEN 'PS3' THEN 3
        WHEN'Wii' THEN 4
        WHEN'DS' THEN 5
        END
```



