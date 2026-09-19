USE Playstoredb;

-- Level 0
-- 01
SELECT COUNT(*)
FROM Apps;
-- 02
SELECT AVG(Rating)
FROM Apps;
-- 03
SELECT MAX(Rating)
FROM Apps;
-- 04
SELECT MIN(Rating)
FROM Apps;
-- 05
SELECT SUM(Downloads)
FROM Apps;
-- 06
SELECT *
FROM Apps
ORDER BY Rating ASC;


-- Level 1
-- 01
SELECT CategoryID, COUNT(*)
FROM categories
GROUP BY CategoryID;
-- 02
SELECT CategoryID, AVG(Rating)
FROM Apps
GROUP BY CategoryID;
-- 03
SELECT MAX(Price) AS Max_price, MIN(Price) AS Min_price 
FROM Apps;
-- 04
SELECT *
FROM Apps
ORDER BY Downloads DESC;
-- 05
SELECT DeveloperID, COUNT(*) AS No_of_Applications
FROM Apps
GROUP BY DeveloperID; 
-- 06
SELECT CategoryID, COUNT(*)
FROM Apps
GROUP BY CategoryID
HAVING COUNT(*) > 1;

-- Level 2
-- 01
SELECT DeveloperID, COUNT(Downloads)
FROM Apps
GROUP BY DeveloperID;
-- 02
SELECT PublisherID, AVG(Rating)
FROM Apps
GROUP BY PublisherID;
-- 03
SELECT DeveloperID, COUNT(*)
FROM Apps
GROUP BY DeveloperID
HAVING COUNT(*) > 1;
-- 04
SELECT CategoryID, AVG(Rating)
FROM Apps
GROUP BY CategoryID
HAVING AVG(Rating) > 4.3;
-- 05
SELECT CategoryID, COUNT(*)
FROM Apps
GROUP BY CategoryID
ORDER BY COUNT(*) DESC;
-- 06
SELECT *
FROM Apps
WHERE Rating = (SELECT MAX(Rating) FROM Apps);
-- 07
SELECT developerID, SUM(Price) AS Total_Peice
FROM Apps
GROUP BY DeveloperID;
