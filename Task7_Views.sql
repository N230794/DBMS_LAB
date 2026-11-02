-- LAB -07
USE PlayStoreDB;
SHOW TABLES;

SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Categories;
SELECT * FROM Apps;


-- LEVEL-0

-- 01
CREATE OR REPLACE VIEW V_All_Apps AS
SELECT *
FROM Apps;

SELECT * FROM V_All_Apps;


-- 02
CREATE OR REPLACE VIEW V_App_Basic_Details AS
SELECT AppID, AppName, Rating, Price
FROM Apps;

SELECT * FROM V_App_Basic_Details;


-- 03
CREATE OR REPLACE VIEW V_Highly_Rated_Apps AS
SELECT *
FROM Apps
WHERE Rating >= 4.5;

SELECT * FROM V_Highly_Rated_Apps;


-- 04
CREATE OR REPLACE VIEW V_Free_Apps AS
SELECT AppID, AppName, Rating, Downloads, Price
FROM Apps
WHERE Price = 0;

SELECT * FROM V_Free_Apps;


-- 05
SELECT *
FROM V_Highly_Rated_Apps;


-- 06
SHOW FULL TABLES
WHERE Table_type = 'VIEW';


-- LEVEL-1

-- 01
CREATE OR REPLACE VIEW V_App_Developer AS
SELECT A.AppName,
       D.DeveloperName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID;

SELECT * FROM V_App_Developer;


-- 02
CREATE OR REPLACE VIEW V_App_Publisher AS
SELECT A.AppName,
       P.PublisherName
FROM Apps A
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID;

SELECT * FROM V_App_Publisher;


-- 03
CREATE OR REPLACE VIEW V_App_Category AS
SELECT A.AppName,
       C.CategoryName
FROM Apps A
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

SELECT * FROM V_App_Category;


-- 04
CREATE OR REPLACE VIEW V_App_Developer_Details AS
SELECT A.AppID,
       A.AppName,
       A.Rating,
       A.Downloads,
       A.Price,
       D.DeveloperName,
       D.Country
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID;

SELECT * FROM V_App_Developer_Details;


-- 05
CREATE OR REPLACE VIEW V_Category_App_Count AS
SELECT CategoryID,
       COUNT(*) AS Total_Applications
FROM Apps
GROUP BY CategoryID;

SELECT * FROM V_Category_App_Count;


-- 06
CREATE OR REPLACE VIEW V_Developer_App_Count AS
SELECT DeveloperID,
       COUNT(*) AS Total_Applications
FROM Apps
GROUP BY DeveloperID;

SELECT * FROM V_Developer_App_Count;


-- 07
CREATE OR REPLACE VIEW V_Category_Avg_Rating AS
SELECT CategoryID,
       AVG(Rating) AS Average_Rating
FROM Apps
GROUP BY CategoryID;

SELECT * FROM V_Category_Avg_Rating;


-- 08
CREATE OR REPLACE VIEW V_Rated_Apps_Developer AS
SELECT A.AppName,
       A.Rating,
       D.DeveloperName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
WHERE A.Rating > 4.3;

SELECT * FROM V_Rated_Apps_Developer;


-- 09
SELECT AppName,
       DeveloperName,
       Rating
FROM V_Rated_Apps_Developer
WHERE Rating >= 4.5;


-- 10
SHOW CREATE VIEW V_App_Developer;


-- LEVEL-02

-- 01
CREATE OR REPLACE VIEW V_Category_Total_Count AS
SELECT C.CategoryName,
       COUNT(A.AppID) AS Total_Applications
FROM Categories C
LEFT JOIN Apps A
ON C.CategoryID = A.CategoryID
GROUP BY C.CategoryID, C.CategoryName;

SELECT * FROM V_Category_Total_Count;


-- 02
CREATE OR REPLACE VIEW V_Developers_Multiple_Apps AS
SELECT D.DeveloperID,
       D.DeveloperName,
       COUNT(A.AppID) AS Total_Applications
FROM Developers D
INNER JOIN Apps A
ON D.DeveloperID = A.DeveloperID
GROUP BY D.DeveloperID, D.DeveloperName
HAVING COUNT(A.AppID) > 1;

SELECT * FROM V_Developers_Multiple_Apps;


-- 03
CREATE OR REPLACE VIEW V_Category_Rating_Range AS
SELECT C.CategoryName,
       MAX(A.Rating) AS Highest_Rating,
       MIN(A.Rating) AS Lowest_Rating
FROM Categories C
INNER JOIN Apps A
ON C.CategoryID = A.CategoryID
GROUP BY C.CategoryID, C.CategoryName;

SELECT * FROM V_Category_Rating_Range;


-- 04
CREATE OR REPLACE VIEW V_Developer_Total_Apps AS
SELECT D.DeveloperName,
       COUNT(A.AppID) AS Total_Applications
FROM Developers D
LEFT JOIN Apps A
ON D.DeveloperID = A.DeveloperID
GROUP BY D.DeveloperID, D.DeveloperName;

SELECT * FROM V_Developer_Total_Apps;


-- 05
CREATE OR REPLACE VIEW V_Complete_App_Details AS
SELECT A.AppID,
       A.AppName,
       D.DeveloperName,
       P.PublisherName,
       C.CategoryName,
       A.Rating,
       A.Downloads,
       A.Price
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

SELECT * FROM V_Complete_App_Details;


-- 06
CREATE OR REPLACE VIEW V_High_Rated_App_Details AS
SELECT A.AppName,
       D.DeveloperName,
       C.CategoryName,
       A.Rating
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID
WHERE A.Rating >= 4.5;

SELECT * FROM V_High_Rated_App_Details;


-- 07
CREATE OR REPLACE VIEW V_Publisher_Statistics AS
SELECT P.PublisherName,
       COUNT(A.AppID) AS Total_Applications,
       COALESCE(SUM(A.Downloads), 0) AS Total_Downloads
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID
GROUP BY P.PublisherID, P.PublisherName;

SELECT * FROM V_Publisher_Statistics;


-- 08
SELECT *
FROM V_Complete_App_Details
WHERE Rating >= 4.5
ORDER BY Downloads DESC;


-- 09
CREATE OR REPLACE VIEW V_App_Rating_Update AS
SELECT AppID,
       AppName,
       Rating
FROM Apps;

UPDATE V_App_Rating_Update
SET Rating = 4.8
WHERE AppID = 1008;

SELECT * FROM V_App_Rating_Update
WHERE AppID = 1008;

SELECT * FROM Apps
WHERE AppID = 1008;


-- 10
DROP VIEW V_Free_Apps;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';


-- REAL-WORLD GOOGLE PLAY STORE ANALYSIS
-- OPTIONAL PRACTICE

-- 01
CREATE OR REPLACE VIEW V_Real_High_Rated_Apps AS
SELECT *
FROM Apps
WHERE Rating >= 4.5;

SELECT * FROM V_Real_High_Rated_Apps;


-- 02
CREATE OR REPLACE VIEW V_Real_Category_Statistics AS
SELECT C.CategoryName,
       COUNT(A.AppID) AS Total_Applications,
       AVG(A.Rating) AS Average_Rating
FROM Categories C
LEFT JOIN Apps A
ON C.CategoryID = A.CategoryID
GROUP BY C.CategoryID, C.CategoryName;

SELECT * FROM V_Real_Category_Statistics;


-- 03
CREATE OR REPLACE VIEW V_Real_Developer_Statistics AS
SELECT D.DeveloperName,
       COUNT(A.AppID) AS Total_Applications,
       AVG(A.Rating) AS Average_Rating
FROM Developers D
LEFT JOIN Apps A
ON D.DeveloperID = A.DeveloperID
GROUP BY D.DeveloperID, D.DeveloperName;

SELECT * FROM V_Real_Developer_Statistics;


-- 04
CREATE OR REPLACE VIEW V_Real_Publisher_Statistics AS
SELECT P.PublisherName,
       COUNT(A.AppID) AS Total_Applications,
       COALESCE(SUM(A.Downloads), 0) AS Total_Downloads
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID
GROUP BY P.PublisherID, P.PublisherName;

SELECT * FROM V_Real_Publisher_Statistics;


-- 05
CREATE OR REPLACE VIEW V_Real_Complete_Apps AS
SELECT A.AppName,
       D.DeveloperName,
       P.PublisherName,
       C.CategoryName,
       A.Rating,
       A.Downloads,
       A.Price
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

SELECT * FROM V_Real_Complete_Apps;


-- 06
CREATE OR REPLACE VIEW V_Above_Average_Apps AS
SELECT AppID,
       AppName,
       Rating,
       Downloads
FROM Apps
WHERE Rating > (
    SELECT AVG(Rating)
    FROM Apps
);

SELECT * FROM V_Above_Average_Apps;


-- 07
CREATE OR REPLACE VIEW V_Most_Downloaded_Per_Category AS
SELECT A.AppID,
       A.AppName,
       C.CategoryName,
       A.Downloads
FROM Apps A
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID
WHERE A.Downloads = (
    SELECT MAX(A2.Downloads)
    FROM Apps A2
    WHERE A2.CategoryID = A.CategoryID
);

SELECT * FROM V_Most_Downloaded_Per_Category;


-- 08
CREATE OR REPLACE VIEW V_PlayStore_Dashboard AS
SELECT A.AppName AS Application_Name,
       D.DeveloperName,
       P.PublisherName,
       C.CategoryName,
       A.Rating,
       A.Downloads,
       A.Price
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

SELECT * FROM V_PlayStore_Dashboard;


-- FINAL VERIFICATION

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SELECT * FROM Apps;
SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Categories;

-- END OF LAB -07