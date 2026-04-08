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

> [Nota: Optei por essa estrutura, utilizando repetidamente UNION ALL em vez de Window Functions (ROW_NUMBER).
O ideal seria utilizar Window Functions, mas farei isso em outro projeto.]
```

| Decada | Ano | Nome | Platforma | Venda Global |
| :--- | :--- | :--- | :--- | ---: |
| 1980 | 1982 | Pac-Man | 2600 | 7.81 |
| 1980 | 1988 | Super Mario Bros. 2 | NES | 7.46 |
| 1980 | 1986 | The Legend of Zelda | NES | 6.51 |
| 1980 | 1988 | Tetris | NES | 5.58 |
| 1980 | 1989 | Dr. Mario | GB | 5.34 |

[Tabela completa aqui](https://github.com/amdreh/Vendas-Video-Games/blob/main/exports/top_10_jogos_por_decada.csv)

### 2. Filtro de Relevância: Plataformas com Maior Volume
**Objetivo:** Analisar quais hardwares dominaram o mercado global com as maiores vendas de consoles, ignorando assim plataformas de nicho ou baixo desempenho.

* **Lógica Técnica:** Além da agregação simples com `SUM`, utilizei a cláusula **`HAVING`**.
* **Critério de Sucesso:** O filtro `Total_de_vendas > 275` foi aplicado para garantir que apenas consoles com alto impacto histórico fossem listados.

```
SELECT Platform as Plataforma, SUM(Global_Sales) as Total_de_Vendas from Vendas
    GROUP BY plataforma
    HAVING Total_de_vendas > 275 
    ORDER BY Total_de_vendas DESC
```

| Plataforma | Venda Total |
| :--- | ---: |
| PS2 | 1255.64 |
| X360 | 979.96 |
| PS3 | 957.84 |
| Wii | 926.71 |
| DS | 822.49 |

[Tabela completa aqui](https://github.com/amdreh/Vendas-Video-Games/blob/main/exports/plataformas%20que%20mais%20venderam%20jogos.csv)

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
| Década | América do Norte | % NA | Japão |  % JP | Europa | % EU | Outros | % OU | Global |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1980 | 235.66 | 62.58% | 102.49 | 27.22% | 31.2 | 8.29% | 7.13 | 1.89% | 376.58 |
| 1990 | 576.11 | 45.05% | 372.33 | 29.11% | 282.87 | 22.12% | 47.42 | 3.71% | 1278.91 |
| 2000 | 2408.91 | 51.87% | 510.69 | 11.0% | 1256.18 | 27.05% | 464.73 | 10.01% | 4644.02 |
| 2010 | 1112.48 | 44.14% | 298.79 | 11.85% | 838.87 | 33.28% | 269.71 | 10.7% | 2520.56 |

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
| Rank | Platforma | Nome | Ano | Gênero | Publisher | Venda NA | Venda EU | Venda JP | Venda Outros | Venda Global |
| :--- | :--- | :--- | :--- | :--- | :--- | ---: | ---: | ---: | ---: | ---: |
| 18 | PS2 | Grand Theft Auto: San Andreas | 2004 | Action | Take-Two Interactive | 9.43 | 0.4 | 0.41 | 10.57 | 20.81 |
| 25 | PS2 | Grand Theft Auto: Vice City | 2002 | Action | Take-Two Interactive | 8.41 | 5.49 | 0.47 | 1.78 | 16.15 |
| 29 | PS2 | Gran Turismo 3: A-Spec | 2001 | Racing | Sony Computer Entertainment | 6.85 | 5.09 | 1.87 | 1.16 | 14.98 |
| 39 | PS2 | Grand Theft Auto III | 2001 | Action | Take-Two Interactive | 6.99 | 4.51 | 0.3 | 1.3 | 13.1 |
| 48 | PS2 | Gran Turismo 4 | 2004 | Racing | Sony Computer Entertainment | 3.01 | 0.01 | 1.1 | 7.53 | 11.66 |

[Tabela completa aqui](https://github.com/amdreh/Vendas-Video-Games/blob/main/exports/jogos%20por%20plataforma%20mais%20vendida.csv)

