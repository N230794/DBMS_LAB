-- LAB -08
-- INTRODUCTION TO PL/SQL / STORED PROGRAMS

USE PlayStoreDB;

SHOW TABLES;

SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Categories;
SELECT * FROM Apps;


-- LEVEL-0

-- 01
-- Calculate 10% of the price of a specified application

DROP PROCEDURE IF EXISTS calculate_app_discount;

DELIMITER //

CREATE PROCEDURE calculate_app_discount(IN p_app_id INT)
BEGIN
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_discount DECIMAL(6,2);
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT Price
    INTO v_price
    FROM Apps
    WHERE AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSE
        SET v_discount = v_price * 0.10;

        SELECT p_app_id AS AppID,
               v_price AS Application_Price,
               v_discount AS Ten_Percent_Discount;
    END IF;
END //

DELIMITER ;

CALL calculate_app_discount(1001);


-- 02
-- Display application name, rating, price and downloads

DROP PROCEDURE IF EXISTS display_app_details;

DELIMITER //

CREATE PROCEDURE display_app_details(IN p_app_id INT)
BEGIN
    DECLARE v_name VARCHAR(255);
    DECLARE v_rating DECIMAL(3,2);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_downloads INT;
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT AppName, Rating, Price, Downloads
    INTO v_name, v_rating, v_price, v_downloads
    FROM Apps
    WHERE AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSE
        SELECT p_app_id AS AppID,
               v_name AS AppName,
               v_rating AS Rating,
               v_price AS Price,
               v_downloads AS Downloads;
    END IF;
END //

DELIMITER ;

CALL display_app_details(1001);


-- 03
-- Classify application based on rating

DROP PROCEDURE IF EXISTS classify_basic_rating;

DELIMITER //

CREATE PROCEDURE classify_basic_rating(IN p_app_id INT)
BEGIN
    DECLARE v_rating DECIMAL(3,2);
    DECLARE v_category VARCHAR(50);
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT Rating
    INTO v_rating
    FROM Apps
    WHERE AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSEIF v_rating IS NULL THEN
        SET v_category = 'Rating Not Available';
    ELSEIF v_rating >= 4.5 THEN
        SET v_category = 'Highly Rated';
    ELSEIF v_rating >= 3.5 THEN
        SET v_category = 'Moderately Rated';
    ELSE
        SET v_category = 'Low Rated';
    END IF;

    IF v_found = 1 THEN
        SELECT p_app_id AS AppID,
               v_rating AS Rating,
               v_category AS Rating_Category;
    END IF;
END //

DELIMITER ;

CALL classify_basic_rating(1001);


-- 04
-- Function to identify Free or Paid Application

DROP FUNCTION IF EXISTS application_price_type;

DELIMITER //

CREATE FUNCTION application_price_type(p_price DECIMAL(6,2))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_price > 0 THEN
        RETURN 'Paid Application';
    ELSE
        RETURN 'Free Application';
    END IF;
END //

DELIMITER ;

SELECT AppID,
       AppName,
       Price,
       application_price_type(Price) AS Application_Type
FROM Apps;


-- 05
-- Display numbers from 1 to 10 using LOOP

DROP PROCEDURE IF EXISTS display_numbers;

DELIMITER //

CREATE PROCEDURE display_numbers()
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Loop_Result
    (
        Number_Value INT,
        Message VARCHAR(100)
    );

    TRUNCATE TABLE Loop_Result;

    number_loop: LOOP

        INSERT INTO Loop_Result
        VALUES (v_counter, 'PlayStore Application Processing');

        SET v_counter = v_counter + 1;

        IF v_counter > 10 THEN
            LEAVE number_loop;
        END IF;

    END LOOP;

    SELECT * FROM Loop_Result;

    DROP TEMPORARY TABLE Loop_Result;
END //

DELIMITER ;

CALL display_numbers();


-- LEVEL-1

-- 01
-- Classify application rating using AppID

DROP PROCEDURE IF EXISTS classify_application_rating;

DELIMITER //

CREATE PROCEDURE classify_application_rating(IN p_app_id INT)
BEGIN
    DECLARE v_rating DECIMAL(3,2);
    DECLARE v_category VARCHAR(50);
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT Rating
    INTO v_rating
    FROM Apps
    WHERE AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSEIF v_rating IS NULL THEN
        SET v_category = 'Rating Not Available';
    ELSEIF v_rating >= 4.5 THEN
        SET v_category = 'Excellent Application';
    ELSEIF v_rating >= 4.0 THEN
        SET v_category = 'Good Application';
    ELSEIF v_rating >= 3.5 THEN
        SET v_category = 'Average Application';
    ELSE
        SET v_category = 'Low Rated Application';
    END IF;

    IF v_found = 1 THEN
        SELECT p_app_id AS AppID,
               v_rating AS Rating,
               v_category AS Rating_Category;
    END IF;
END //

DELIMITER ;

CALL classify_application_rating(1001);


-- 02
-- Function to return application rating using AppID

DROP FUNCTION IF EXISTS get_application_rating;

DELIMITER //

CREATE FUNCTION get_application_rating(p_app_id INT)
RETURNS DECIMAL(3,2)
READS SQL DATA
BEGIN
    DECLARE v_rating DECIMAL(3,2);

    SELECT Rating
    INTO v_rating
    FROM Apps
    WHERE AppID = p_app_id;

    RETURN v_rating;
END //

DELIMITER ;

SELECT AppName,
       get_application_rating(AppID) AS Rating
FROM Apps;


-- 03
-- Display rating classification using CASE

SELECT AppID,
       AppName,
       Rating,
       CASE
           WHEN Rating >= 4.5 THEN 'Excellent Application'
           WHEN Rating >= 4.0 THEN 'Good Application'
           WHEN Rating >= 3.5 THEN 'Average Application'
           WHEN Rating < 3.5 THEN 'Low Rated Application'
           ELSE 'Rating Not Available'
       END AS Rating_Category
FROM Apps;


-- LEVEL-2

-- 01
-- Cursor to process all applications

DROP PROCEDURE IF EXISTS display_applications_cursor;

DELIMITER //

CREATE PROCEDURE display_applications_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(255);
    DECLARE v_rating DECIMAL(3,2);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_downloads INT;

    DECLARE app_cursor CURSOR FOR
        SELECT AppID, AppName, Rating, Price, Downloads
        FROM Apps;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Cursor_Result
    (
        AppID INT,
        AppName VARCHAR(255),
        Rating DECIMAL(3,2),
        Price DECIMAL(6,2),
        Downloads INT
    );

    TRUNCATE TABLE Cursor_Result;

    OPEN app_cursor;

    read_loop: LOOP

        FETCH app_cursor
        INTO v_id, v_name, v_rating, v_price, v_downloads;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO Cursor_Result
        VALUES (v_id, v_name, v_rating, v_price, v_downloads);

    END LOOP;

    CLOSE app_cursor;

    SELECT * FROM Cursor_Result;

    DROP TEMPORARY TABLE Cursor_Result;
END //

DELIMITER ;

CALL display_applications_cursor();


-- 02
-- Procedure to handle application not found

DROP PROCEDURE IF EXISTS find_application;

DELIMITER //

CREATE PROCEDURE find_application(IN p_app_id INT)
BEGIN
    DECLARE v_name VARCHAR(255);
    DECLARE v_rating DECIMAL(3,2);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT AppName, Rating, Price
    INTO v_name, v_rating, v_price
    FROM Apps
    WHERE AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSE
        SELECT v_name AS Application_Name,
               v_rating AS Rating,
               v_price AS Price;
    END IF;
END //

DELIMITER ;

CALL find_application(1001);

CALL find_application(9999);


-- LEVEL-3

-- 01
-- Complete Application Processing

DROP PROCEDURE IF EXISTS process_application;

DELIMITER //

CREATE PROCEDURE process_application(IN p_application_id INT)
BEGIN
    DECLARE v_app_id INT;
    DECLARE v_app_name VARCHAR(255);
    DECLARE v_rating DECIMAL(3,2);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_downloads INT;

    DECLARE v_developer VARCHAR(255);
    DECLARE v_publisher VARCHAR(255);
    DECLARE v_category VARCHAR(255);

    DECLARE v_rating_category VARCHAR(50);
    DECLARE v_price_category VARCHAR(50);

    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT A.AppID,
           A.AppName,
           A.Rating,
           A.Price,
           A.Downloads,
           D.DeveloperName,
           P.PublisherName,
           C.CategoryName
    INTO v_app_id,
         v_app_name,
         v_rating,
         v_price,
         v_downloads,
         v_developer,
         v_publisher,
         v_category
    FROM Apps A
    INNER JOIN Developers D
        ON A.DeveloperID = D.DeveloperID
    INNER JOIN Publishers P
        ON A.PublisherID = P.PublisherID
    INNER JOIN Categories C
        ON A.CategoryID = C.CategoryID
    WHERE A.AppID = p_application_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSE

        -- Rating Classification

        IF v_rating IS NULL THEN
            SET v_rating_category = 'Not Rated';
        ELSEIF v_rating >= 4.5 THEN
            SET v_rating_category = 'Excellent';
        ELSEIF v_rating >= 4.0 THEN
            SET v_rating_category = 'Very Good';
        ELSEIF v_rating >= 3.0 THEN
            SET v_rating_category = 'Good';
        ELSE
            SET v_rating_category = 'Needs Improvement';
        END IF;

        -- Price Classification

        IF v_price = 0 THEN
            SET v_price_category = 'Free Application';
        ELSEIF v_price <= 100 THEN
            SET v_price_category = 'Budget Application';
        ELSEIF v_price <= 500 THEN
            SET v_price_category = 'Premium Application';
        ELSE
            SET v_price_category = 'High Premium Application';
        END IF;

        -- Application Details Report

        SELECT
            v_app_id AS Application_ID,
            v_app_name AS Application_Name,
            v_developer AS Developer_Name,
            v_publisher AS Publisher_Name,
            v_category AS Category_Name,
            v_rating AS Rating,
            v_rating_category AS Rating_Category,
            v_price AS Price,
            v_price_category AS Price_Category,
            v_downloads AS Downloads;

    END IF;
END //

DELIMITER ;

CALL process_application(1001);


-- 02
-- Developer Application Cursor Processing

DROP PROCEDURE IF EXISTS developer_application_cursor;

DELIMITER //

CREATE PROCEDURE developer_application_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(255);
    DECLARE v_count INT;
    DECLARE v_average DECIMAL(4,2);
    DECLARE v_downloads BIGINT;

    DECLARE developer_cursor CURSOR FOR
        SELECT D.DeveloperID,
               D.DeveloperName,
               COUNT(A.AppID),
               AVG(A.Rating),
               SUM(A.Downloads)
        FROM Developers D
        INNER JOIN Apps A
            ON D.DeveloperID = A.DeveloperID
        GROUP BY D.DeveloperID, D.DeveloperName;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Developer_Result
    (
        DeveloperID INT,
        DeveloperName VARCHAR(255),
        Application_Count INT,
        Average_Rating DECIMAL(4,2),
        Total_Downloads BIGINT
    );

    TRUNCATE TABLE Developer_Result;

    OPEN developer_cursor;

    developer_loop: LOOP

        FETCH developer_cursor
        INTO v_id, v_name, v_count, v_average, v_downloads;

        IF v_done = 1 THEN
            LEAVE developer_loop;
        END IF;

        INSERT INTO Developer_Result
        VALUES (v_id, v_name, v_count, v_average, v_downloads);

    END LOOP;

    CLOSE developer_cursor;

    SELECT * FROM Developer_Result;

    DROP TEMPORARY TABLE Developer_Result;
END //

DELIMITER ;

CALL developer_application_cursor();


-- 03
-- Combined Function and Cursor

DROP FUNCTION IF EXISTS get_developer_app_count;

DELIMITER //

CREATE FUNCTION get_developer_app_count(p_developer_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM Apps
    WHERE DeveloperID = p_developer_id;

    RETURN v_count;
END //

DELIMITER ;


-- Process all developers using Cursor

DROP PROCEDURE IF EXISTS developer_portfolio_cursor;

DELIMITER //

CREATE PROCEDURE developer_portfolio_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(255);
    DECLARE v_count INT;
    DECLARE v_category VARCHAR(50);

    DECLARE developer_cursor CURSOR FOR
        SELECT DeveloperID, DeveloperName
        FROM Developers;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Portfolio_Result
    (
        DeveloperID INT,
        DeveloperName VARCHAR(255),
        Application_Count INT,
        Developer_Category VARCHAR(50)
    );

    TRUNCATE TABLE Portfolio_Result;

    OPEN developer_cursor;

    developer_loop: LOOP

        FETCH developer_cursor
        INTO v_id, v_name;

        IF v_done = 1 THEN
            LEAVE developer_loop;
        END IF;

        SET v_count = get_developer_app_count(v_id);

        IF v_count = 0 THEN
            SET v_category = 'No Applications';
        ELSEIF v_count <= 2 THEN
            SET v_category = 'Small Portfolio';
        ELSE
            SET v_category = 'Large Portfolio';
        END IF;

        INSERT INTO Portfolio_Result
        VALUES (v_id, v_name, v_count, v_category);

    END LOOP;

    CLOSE developer_cursor;

    SELECT * FROM Portfolio_Result;

    DROP TEMPORARY TABLE Portfolio_Result;
END //

DELIMITER ;

CALL developer_portfolio_cursor();


-- OPTIONAL PRACTICE

-- 01
-- Update application rating after checking AppID

DROP PROCEDURE IF EXISTS update_app_rating;

DELIMITER //

CREATE PROCEDURE update_app_rating(
    IN p_application_id INT,
    IN p_new_rating DECIMAL(3,2)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_exists
    FROM Apps
    WHERE AppID = p_application_id;

    IF v_exists = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSEIF p_new_rating IS NULL
        OR p_new_rating < 0
        OR p_new_rating > 5 THEN
        SELECT 'Invalid application rating' AS Message;
    ELSE
        UPDATE Apps
        SET Rating = p_new_rating
        WHERE AppID = p_application_id;

        SELECT *
        FROM Apps
        WHERE AppID = p_application_id;
    END IF;
END //

DELIMITER ;

CALL update_app_rating(1001, 4.8);


-- 02
-- CASE Based Application Rating Classification

SELECT AppID,
       AppName,
       Rating,
       CASE
           WHEN Rating >= 4.5 THEN 'Excellent'
           WHEN Rating >= 4.0 THEN 'Good'
           WHEN Rating >= 3.5 THEN 'Average'
           WHEN Rating < 3.5 THEN 'Low Rated'
           ELSE 'Not Rated'
       END AS Rating_Category
FROM Apps;


-- 03
-- Application and Developer Details

DROP PROCEDURE IF EXISTS application_developer_details;

DELIMITER //

CREATE PROCEDURE application_developer_details(IN p_app_id INT)
BEGIN
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT A.AppID,
           A.AppName,
           A.Rating,
           A.Price,
           A.DeveloperID,
           D.DeveloperName,
           D.Country
    FROM Apps A
    INNER JOIN Developers D
        ON A.DeveloperID = D.DeveloperID
    WHERE A.AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    END IF;
END //

DELIMITER ;

CALL application_developer_details(1001);


-- 04
-- Cursor Processing of All Applications

CALL display_applications_cursor();


-- 05
-- Function with Application Classification Logic

DROP FUNCTION IF EXISTS classify_application;

DELIMITER //

CREATE FUNCTION classify_application(p_rating DECIMAL(3,2))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF p_rating IS NULL THEN
        RETURN 'Not Rated';
    ELSEIF p_rating >= 4.5 THEN
        RETURN 'Excellent';
    ELSEIF p_rating >= 4.0 THEN
        RETURN 'Good';
    ELSEIF p_rating >= 3.5 THEN
        RETURN 'Average';
    ELSE
        RETURN 'Low Rated';
    END IF;
END //

DELIMITER ;

SELECT AppID,
       AppName,
       Rating,
       classify_application(Rating) AS Rating_Category
FROM Apps;


-- FINAL VERIFICATION

SELECT * FROM Apps;
SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Categories;
