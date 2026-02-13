--Query para obter os 10 jogos mais vendidos por década 
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

--Quanto vendeu cada mercado por década?
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

