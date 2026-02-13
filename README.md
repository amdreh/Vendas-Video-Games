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
> *Nota: Optei por essa estrutura em vez de Window Functions (ROW_NUMBER) para explorar melhor Window Functions em outro projeto.*

### 2. Filtro de Relevância: Plataformas com Maior Volume
**Objetivo:** Analisar quais hardwares realmente dominaram o mercado global, ignorando plataformas de nicho ou baixo desempenho.

* **Lógica Técnica:** Além da agregação simples com `SUM`, utilizei a cláusula **`HAVING`**.
* **Critério de Sucesso:** O filtro `Total_de_vendas > 275` foi aplicado para garantir que apenas consoles com alto impacto histórico fossem listados.

### 3. Market Share: Vendas Regionais e Percentuais
**Objetivo:** Compreender a relevância de cada mercado e como essa fatia de mercado mudou com o passar das décadas.

* **Lógica Técnica:** Realizei cálculos matemáticos dentro do `SELECT` para gerar a participação percentual de cada região em relação ao total global.
* **Formatação:** Utilizei as funções **`ROUND`** para precisão decimal e o operador de concatenação **`|| '%'`** para entregar os dados formatados para leitura direta.

### 4. Análise Direcionada: Top 5 Consoles Históricos
**Objetivo:** Extrair a biblioteca completa de jogos das cinco plataformas líderes (PS2, X360, PS3, Wii, DS).

* **Lógica Técnica:** Utilizei o operador **`IN`** para filtragem múltipla e eficiente.
* **Ordenação Customizada:** Apliquei a estrutura **`ORDER BY CASE`**, técnica que permite definir uma ordem de exibição manual, garantindo que os dados sejam apresentados na hierarquia de importância definida pela análise.

<?-- Lembrete para mim mesmo, como mostrar blocos de código:

```sql
--SELECT Name, Global_Sales 
//FROM Vendas 
//WHERE Year = 2010;
//```?>



