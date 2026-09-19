USE playstoredb;

-- level 0

SELECT CategoryID
FROM Apps
GROUP BY CategoryID
ORDER BY CategoryID;

SELECT CategoryID
FROM Categories
ORDER BY CategoryID;

INSERT INTO Developers
(DeveloperID, DeveloperName, Country, FounderYear)
VALUES
(106,'OpenAI','USA',2015);

INSERT INTO Categories
VALUES
(303,'Music',12),
(306,'Artifical Intelligence',12);


-- 01
ALTER TABLE Apps
ADD CONSTRAINT fk_developer
FOREIGN KEY (DeveloperID)
REFERENCES Developers(DeveloperID);

-- 02
ALTER TABLE Apps
ADD CONSTRAINT fk_publisher
FOREIGN KEY (PublisherID)
REFERENCES Publishers(PublisherID);

-- 03
ALTER TABLE Apps
ADD CONSTRAINT fk_CategoryID
FOREIGN KEY (CategoryID)
REFERENCES Categories(CategoryID);

-- 04 
SELECT *FROM Apps WHERE Rating>4.5;

-- 05
SELECT *FROM Apps WHERE Price = 0;

-- 06
SELECT *FROM Apps WHERE CategoryID = 305;


-- Level 01
-- 01
SELECT *FROM Apps WHERE Downloads>50000000;

-- 02 
SELECT *FROM Apps WHERE Rating BETWEEN 4.3 AND 4.7;

-- 03
SELECT *FROM Apps WHERE Price IN (0,299);

-- 04
SELECT *FROM Apps WHERE AppName LIKE 'G%';

-- 05
SELECT *FROM Apps WHERE AppName LIKE '%Google%';

-- 06
SELECT *FROM Apps WHERE Rating>4.5  AND Downloads>5000000;

-- 07 
SELECT *FROM Apps WHERE CategoryID !=305;

-- Level 02
-- 01
SELECT *FROM Apps WHERE AppName NOT LIKE 'G%';

-- 02
SELECT *FROM Apps WHERE Rating<4.5 OR Downloads>100000000;

-- 03
SELECT *FROM Developers WHERE DeveloperName LIKE '%a%';

-- 4
SELECT * FROM Apps WHERE Price BETWEEN 0 AND 300;

-- 5
SELECT * FROM Apps WHERE PublisherID IN (201, 204);

-- 6
-- Attempt to insert an app with non-existent DeveloperID 999 to demonstrate foreign key enforcement
INSERT INTO Apps (AppID, AppName, DeveloperID, PublisherID, CategoryID, Rating, Downloads, Price)
VALUES (9999, 'Test App', 999, 201, 301, 4.0, 1000, 0);

-- 7
SELECT * FROM Apps WHERE CategoryID <> 305;
