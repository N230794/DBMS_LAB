USE playstoredb;

-- Level 0

SELECT UPPER(DeveloperName) FROM Developers;
SELECT LOWER(DeveloperName) FROM Developers;
SELECT LENGTH(AppName) FROM Apps;
SELECT CategoryName, LENGTH(categoryName) FROM Categories;
SELECT CURRENT_DATE();
SELECT CURRENT_TIME();
SELECT ROUND(Rating, 0) FROM Apps;

-- Level 1

SELECT AppName,SUBSTRING(AppName,1,5) AS First5Characters FROM Apps;
SELECT CONCAT(DeveloperName,' ',Country) AS DeveloperCountry FROM Developers;
SELECT AppName,ROUND(Rating,1) AS RoundedRating FROM Apps;
SELECT AppName,CEIL(Price) AS CeilPrice FROM Apps;
SELECT DeveloperName,FounderYear FROM Developers;
SELECT AppName, CAST(Downloads AS CHAR) AS DownloadsText FROM Apps;

-- Level 2

SELECT UPPER(AppName) AS AppName, Rating FROM Apps;
SELECT SUBSTRING(CategoryName,1,3) AS First3Characters FROM Categories ;
SELECT ABS(Price-200) FROM Apps;
SELECT DeveloperName, LENGTH(DeveloperName) FROM Developers;
SELECT CURRENT_TIMESTAMP();
SELECT DeveloperNAme, CAST(FounderYear AS CHAR) AS FoundedYearText FROM Developers;