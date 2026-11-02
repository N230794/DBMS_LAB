USE playstoredb;

-- Level 0

-- 01
UPDATE Apps
SET Rating = 4.8
WHERE AppID = 1002 ;
COMMIT;

-- 02
UPDATE Apps
SET Price = 10.99
WHERE AppID = 1006;
ROLLBACK;

-- 03
INSERT INTO Apps(AppID,AppName, CategoryID, Price, rating)
VALUES (1109,'New App', 301, 0.00, 4.5);
COMMIT;

-- 04
INSERT INTO Developers(DeveloperID, DeveloperName, Country)
VALUES (1203,'Tech Corp', 'USA');

-- 05
UPDATE Apps
SET Rating = 4.2
WHERE AppID = 1008;
SAVEPOINT after_rating_update;

-- level -1

-- ============================================================
-- LEVEL-1 (INTERMEDIATE)
-- ============================================================


-- ------------------------------------------------------------
-- 01. UPDATE RATINGS OF TWO APPLICATIONS AND CREATE SAVEPOINT
-- ------------------------------------------------------------

START TRANSACTION;

UPDATE Apps
SET Rating = 4.5
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID
        LIMIT 1
    ) AS temp
);

SAVEPOINT after_first_update;

UPDATE Apps
SET Rating = 4.7
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID DESC
        LIMIT 1
    ) AS temp
);

SELECT * FROM Apps;

-- Save the transaction

COMMIT;


-- ------------------------------------------------------------
-- 02. PERFORM ANOTHER UPDATE AND ROLLBACK TO SAVEPOINT
-- ------------------------------------------------------------

START TRANSACTION;

UPDATE Apps
SET Rating = 4.4
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID
        LIMIT 1
    ) AS temp
);

SAVEPOINT rating_checkpoint;

UPDATE Apps
SET Price = 199
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID DESC
        LIMIT 1
    ) AS temp
);

SELECT * FROM Apps;

ROLLBACK TO SAVEPOINT rating_checkpoint;

-- The price update is cancelled.
-- The rating update before the savepoint remains.

SELECT * FROM Apps;

COMMIT;


-- ------------------------------------------------------------
-- 03. INSERT APPLICATION, CREATE SAVEPOINT, UPDATE PRICE,
--     AND ROLLBACK TO SAVEPOINT
-- ------------------------------------------------------------

START TRANSACTION;

SET @savepoint_app_id = (
    SELECT COALESCE(MAX(AppID), 1000) + 1
    FROM Apps
);

INSERT INTO Apps
(
    AppID,
    AppName,
    Rating,
    Price,
    Downloads,
    DeveloperID,
    PublisherID,
    CategoryID
)
VALUES
(
    @savepoint_app_id,
    'Savepoint Test Application',
    4.2,
    50.00,
    50000,
    (SELECT MIN(DeveloperID) FROM Developers),
    (SELECT MIN(PublisherID) FROM Publishers),
    (SELECT MIN(CategoryID) FROM Categories)
);

SAVEPOINT after_app_insert;

UPDATE Apps
SET Price = 199
WHERE AppID = @savepoint_app_id;

SELECT *
FROM Apps
WHERE AppID = @savepoint_app_id;

ROLLBACK TO SAVEPOINT after_app_insert;

-- Application remains, but price returns to 50.00

SELECT *
FROM Apps
WHERE AppID = @savepoint_app_id;

COMMIT;


-- ------------------------------------------------------------
-- 04. GRANT SELECT PRIVILEGE ON APPS TABLE TO A USER
-- ------------------------------------------------------------

-- Replace lab_user with an existing MySQL username.
-- Replace localhost if the user's host is different.

-- GRANT SELECT
-- ON PlayStoreDB.Apps
-- TO 'lab_user'@'localhost';


-- ------------------------------------------------------------
-- 05. GRANT SELECT AND INSERT PRIVILEGES ON APPS TABLE
-- ------------------------------------------------------------

-- GRANT SELECT, INSERT
-- ON PlayStoreDB.Apps
-- TO 'lab_user'@'localhost';


-- ------------------------------------------------------------
-- 06. REVOKE INSERT PRIVILEGE FROM THE USER
-- ------------------------------------------------------------

-- REVOKE INSERT
-- ON PlayStoreDB.Apps
-- FROM 'lab_user'@'localhost';


-- ============================================================
-- LEVEL-2 (PRACTICE)
-- ============================================================


-- ------------------------------------------------------------
-- 01. MULTIPLE UPDATES USING SAVEPOINT AND ROLLBACK TO
-- ------------------------------------------------------------

START TRANSACTION;

UPDATE Apps
SET Rating = 4.6
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID
        LIMIT 1
    ) AS temp
);

SAVEPOINT first_update;

UPDATE Apps
SET Price = 150
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID DESC
        LIMIT 1
    ) AS temp
);

SAVEPOINT second_update;

UPDATE Apps
SET Downloads = Downloads + 1000
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID
        LIMIT 1
    ) AS temp
);

SELECT * FROM Apps;

-- Cancel only the changes after second_update

ROLLBACK TO SAVEPOINT second_update;

SELECT * FROM Apps;

COMMIT;


-- ------------------------------------------------------------
-- 02. INSERT TWO CATEGORIES, CREATE SAVEPOINT,
--     AND ROLLBACK TO SAVEPOINT
-- ------------------------------------------------------------

-- Assumed Categories columns:
-- CategoryID, CategoryName, MinAge.
-- Verify DESC Categories before execution.

START TRANSACTION;

SET @category_id_1 = (
    SELECT COALESCE(MAX(CategoryID), 300) + 1
    FROM Categories
);

INSERT INTO Categories
(
    CategoryID,
    CategoryName,
    MinAge
)
VALUES
(
    @category_id_1,
    'Temporary Category One',
    12
);

SAVEPOINT after_first_category;

SET @category_id_2 = @category_id_1 + 1;

INSERT INTO Categories
(
    CategoryID,
    CategoryName,
    MinAge
)
VALUES
(
    @category_id_2,
    'Temporary Category Two',
    12
);

SELECT * FROM Categories;

ROLLBACK TO SAVEPOINT after_first_category;

-- First category remains; second category is cancelled.

SELECT * FROM Categories;

ROLLBACK;

-- Cancel the remaining first category insertion too.

SELECT * FROM Categories;


-- ------------------------------------------------------------
-- 03. GRANT SELECT, INSERT AND UPDATE PRIVILEGES ON APPS
-- ------------------------------------------------------------

-- GRANT SELECT, INSERT, UPDATE
-- ON PlayStoreDB.Apps
-- TO 'lab_user'@'localhost';


-- ------------------------------------------------------------
-- 04. REVOKE UPDATE PRIVILEGE FROM THE USER
-- ------------------------------------------------------------

-- REVOKE UPDATE
-- ON PlayStoreDB.Apps
-- FROM 'lab_user'@'localhost';


-- ------------------------------------------------------------
-- 05. GRANT SELECT PRIVILEGE ON DEVELOPERS AND REVOKE IT
-- ------------------------------------------------------------

-- GRANT SELECT
-- ON PlayStoreDB.Developers
-- TO 'lab_user'@'localhost';

-- REVOKE SELECT
-- ON PlayStoreDB.Developers
-- FROM 'lab_user'@'localhost';


-- ------------------------------------------------------------
-- 06. MULTIPLE OPERATIONS AND PERMANENTLY SAVE USING COMMIT
-- ------------------------------------------------------------

START TRANSACTION;

UPDATE Apps
SET Rating = 4.5
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID
        LIMIT 1
    ) AS temp
);

UPDATE Apps
SET Price = 199
WHERE AppID = (
    SELECT AppID
    FROM (
        SELECT AppID
        FROM Apps
        ORDER BY AppID DESC
        LIMIT 1
    ) AS temp
);

SELECT * FROM Apps;

COMMIT;

-- Verify permanently saved changes

SELECT * FROM Apps;


-- ------------------------------------------------------------
-- 07. VERIFY THE EFFECT OF COMMIT AND ROLLBACK
-- ------------------------------------------------------------

-- Verify committed records

SELECT *
FROM Apps
WHERE AppName IN (
    'Google Keep',
    'Lab5 Demo Application'
);

-- Verify rolled-back developer insertion

SELECT *
FROM Developers
WHERE DeveloperName = 'Lab5 Temporary Developer';

-- Verify application records

SELECT * FROM Apps;

-- Verify developer records

SELECT * FROM Developers;

-- Verify category records

SELECT * FROM Categories;


-- ============================================================
-- DCL VERIFICATION
-- ============================================================

-- Display current MySQL user

SELECT CURRENT_USER();

-- Display privileges of the current user

SHOW GRANTS;

-- To inspect privileges of another user, replace username
-- and host with the actual MySQL account.

-- SHOW GRANTS FOR 'lab_user'@'localhost';


-- ============================================================
-- FINAL VERIFICATION
-- ============================================================

SELECT * FROM Developers;

SELECT * FROM Publishers;

SELECT * FROM Categories;

SELECT * FROM Apps;

SET autocommit = 1;


