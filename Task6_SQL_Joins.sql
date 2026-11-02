-- LAB -06
USE playstoredb;
USE PlayStoreDB;
SHOW TABLES;

SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Categories;
SELECT * FROM Apps;

-- LEVEL-0
-- 01
SELECT A.AppName, D.DeveloperName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID;

-- 02
SELECT A.AppName, P.PublisherName
FROM Apps A
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID;

-- 03
SELECT A.AppName, C.CategoryName
FROM Apps A
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

-- 04
SELECT A.AppName,
       D.DeveloperName,
       P.PublisherName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID;

-- 05
SELECT A.AppName,
       D.DeveloperName,
       C.CategoryName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

-- 06
SELECT P.PublisherName, A.AppName
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID;

-- 07
SELECT C.CategoryName, A.AppName
FROM Categories C
LEFT JOIN Apps A
ON C.CategoryID = A.CategoryID;

-- LEVEL -1
-- 01
SELECT P.PublisherName, A.AppName
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID;

-- 02
SELECT A.AppName, P.PublisherName
FROM Apps A
RIGHT JOIN Publishers P
ON A.PublisherID = P.PublisherID;

-- 03
SELECT C.CategoryName, A.AppName
FROM Categories C
LEFT JOIN Apps A
ON C.CategoryID = A.CategoryID;

-- 04
SELECT A.AppName,
       D.DeveloperName,
       D.Country
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID;

-- 05
SELECT A.AppName,
       D.DeveloperName,
       P.PublisherName,
       C.CategoryName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

-- 06
SELECT A.AppName,
       D.DeveloperName,
       D.Country
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
WHERE D.Country = 'USA';

-- 07
SELECT A.AppName,
       C.CategoryName,
       P.PublisherName
FROM Apps A
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
WHERE C.CategoryName = 'Gaming';

-- 08
SELECT A.AppName,
       A.Rating,
       D.DeveloperName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
WHERE A.Rating > 4.5;

-- LEVEL -02

-- 01
SELECT P.PublisherID,
       P.PublisherName,
       A.AppName
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID;

-- 02
SELECT P.PublisherID,
       P.PublisherName
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID
WHERE A.AppID IS NULL;

-- 03
SELECT A.AppName,
       C.CategoryName
FROM Apps A
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID
ORDER BY C.CategoryName ASC;

-- 04
SELECT A.AppName,
       D.DeveloperName,
       P.PublisherName,
       C.CategoryName,
       A.Rating
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID;

-- 05
SELECT A.AppName,
       D.DeveloperName,
       D.Country,
       P.PublisherName
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
WHERE D.Country = 'USA'
AND P.PublisherName = 'Google Play';

-- 06
SELECT D.DeveloperName,
       D.Country,
       A.AppName
FROM Developers D
LEFT JOIN Apps A
ON D.DeveloperID = A.DeveloperID;

-- 07
SELECT D1.DeveloperName AS Developer1,
       D2.DeveloperName AS Developer2,
       D1.Country
FROM Developers D1
INNER JOIN Developers D2
ON D1.Country = D2.Country
AND D1.DeveloperID < D2.DeveloperID;

-- 08
SELECT P.PublisherName,
       C.CategoryName
FROM Publishers P
CROSS JOIN Categories C;

-- 09
SELECT P.PublisherID,
       P.PublisherName,
       A.AppName
FROM Publishers P
LEFT JOIN Apps A
ON P.PublisherID = A.PublisherID

UNION

SELECT P.PublisherID,
       P.PublisherName,
       A.AppName
FROM Publishers P
RIGHT JOIN Apps A
ON P.PublisherID = A.PublisherID;

-- 10
SELECT A.AppName,
       C.CategoryName,
       D.DeveloperName,
       P.PublisherName
FROM Apps A
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Publishers P
ON A.PublisherID = P.PublisherID
WHERE C.CategoryName IN ('Gaming', 'Social');

-- 11
SELECT A.AppName,
       D.DeveloperName,
       C.CategoryName,
       A.Rating
FROM Apps A
INNER JOIN Developers D
ON A.DeveloperID = D.DeveloperID
INNER JOIN Categories C
ON A.CategoryID = C.CategoryID
WHERE A.Rating BETWEEN 4.3 AND 4.7;

-- 12
SELECT D.DeveloperName,
       D.Country,
       A.AppName
FROM Developers D
INNER JOIN Apps A
ON D.DeveloperID = A.DeveloperID
WHERE D.Country <> 'India';