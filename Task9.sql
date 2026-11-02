-- ============================================================
-- DBMS LAB - 09
-- PL/SQL / STORED PROGRAMS USING PlayStoreDB
-- MYSQL WORKBENCH VERSION
-- ============================================================

USE PlayStoreDB;

-- ============================================================
-- DATABASE VERIFICATION
-- ============================================================

SHOW TABLES;

DESC Developers;
DESC Publishers;
DESC Categories;
DESC Apps;

SELECT * FROM Developers;
SELECT * FROM Publishers;
SELECT * FROM Categories;
SELECT * FROM Apps;


-- ============================================================
-- PART A - MEDIUM LEVEL ACTIVITIES
-- ============================================================


-- ------------------------------------------------------------
-- TASK 1: APPLICATION RATING CLASSIFICATION FUNCTION
-- ------------------------------------------------------------
-- Excellent       : Rating >= 4.5
-- Very Good       : Rating >= 4.0
-- Good            : Rating >= 3.0
-- Needs Improvement: Below 3.0
-- Not Rated       : NULL
-- ------------------------------------------------------------

DROP FUNCTION IF EXISTS classify_rating;

DELIMITER //

CREATE FUNCTION classify_rating(p_rating DECIMAL(3,1))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE v_category VARCHAR(30);

    IF p_rating IS NULL THEN
        SET v_category = 'Not Rated';

    ELSEIF p_rating >= 4.5 THEN
        SET v_category = 'Excellent';

    ELSEIF p_rating >= 4.0 THEN
        SET v_category = 'Very Good';

    ELSEIF p_rating >= 3.0 THEN
        SET v_category = 'Good';

    ELSE
        SET v_category = 'Needs Improvement';
    END IF;

    RETURN v_category;
END //

DELIMITER ;

-- Execute and test function

SELECT classify_rating(4.8) AS Result;
SELECT classify_rating(4.2) AS Result;
SELECT classify_rating(3.5) AS Result;
SELECT classify_rating(2.5) AS Result;
SELECT classify_rating(NULL) AS Result;


-- ------------------------------------------------------------
-- TASK 2: INDIVIDUAL APPLICATION DETAILS PROCEDURE
-- ------------------------------------------------------------
-- Display AppID, AppName, Rating, Price, Downloads,
-- DeveloperName, PublisherName and CategoryName.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS application_details;

DELIMITER //

CREATE PROCEDURE application_details(
    IN p_application_id INT
)
BEGIN
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT
        A.AppID,
        A.AppName,
        A.Rating,
        A.Price,
        A.Downloads,
        D.DeveloperName,
        P.PublisherName,
        C.CategoryName
    INTO
        @v_app_id,
        @v_app_name,
        @v_rating,
        @v_price,
        @v_downloads,
        @v_developer,
        @v_publisher,
        @v_category
    FROM Apps A
    JOIN Developers D
        ON A.DeveloperID = D.DeveloperID
    JOIN Publishers P
        ON A.PublisherID = P.PublisherID
    JOIN Categories C
        ON A.CategoryID = C.CategoryID
    WHERE A.AppID = p_application_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSE
        SELECT
            @v_app_id AS AppID,
            @v_app_name AS AppName,
            @v_rating AS Rating,
            @v_price AS Price,
            @v_downloads AS Downloads,
            @v_developer AS DeveloperName,
            @v_publisher AS PublisherName,
            @v_category AS CategoryName;
    END IF;
END //

DELIMITER ;

-- Execute with an existing AppID

CALL application_details(1001);

-- Test with a non-existing AppID

CALL application_details(9999);


-- ------------------------------------------------------------
-- TASK 3: DEVELOPER APPLICATION COUNT FUNCTION
-- ------------------------------------------------------------
-- Return the total number of applications developed
-- by a particular developer.
-- ------------------------------------------------------------

DROP FUNCTION IF EXISTS get_developer_app_count;

DELIMITER //

CREATE FUNCTION get_developer_app_count(
    p_developer_id INT
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_count
    FROM Apps
    WHERE DeveloperID = p_developer_id;

    RETURN v_count;
END //

DELIMITER ;

-- Display application count for all developers

SELECT
    D.DeveloperID,
    D.DeveloperName,
    get_developer_app_count(D.DeveloperID) AS Number_Of_Applications
FROM Developers D;


-- ============================================================
-- LEVEL 1 - INTERMEDIATE QUESTIONS
-- ============================================================


-- ------------------------------------------------------------
-- QUESTION 1: APPLICATION CATEGORY SUMMARY
-- ------------------------------------------------------------
-- Procedure: category_application_summary
-- Display CategoryName, TotalApplications, FreeApplications,
-- PaidApplications and AverageRating.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS category_application_summary;

DELIMITER //

CREATE PROCEDURE category_application_summary(
    IN p_category_id INT
)
BEGIN
    DECLARE v_category_name VARCHAR(255);
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_free INT DEFAULT 0;
    DECLARE v_paid INT DEFAULT 0;
    DECLARE v_average DECIMAL(5,2);
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT CategoryName
    INTO v_category_name
    FROM Categories
    WHERE CategoryID = p_category_id;

    IF v_found = 0 THEN
        SELECT 'Category not found' AS Message;
    ELSE
        SELECT
            COUNT(*),
            SUM(CASE WHEN Price = 0 THEN 1 ELSE 0 END),
            SUM(CASE WHEN Price > 0 THEN 1 ELSE 0 END),
            AVG(Rating)
        INTO
            v_total,
            v_free,
            v_paid,
            v_average
        FROM Apps
        WHERE CategoryID = p_category_id;

        SELECT
            v_category_name AS CategoryName,
            v_total AS TotalApplications,
            v_free AS FreeApplications,
            v_paid AS PaidApplications,
            v_average AS AverageRating;
    END IF;
END //

DELIMITER ;

-- Execute

CALL category_application_summary(301);

-- Test with a non-existing CategoryID

CALL category_application_summary(9999);


-- ------------------------------------------------------------
-- QUESTION 2: APPLICATION PRICE CLASSIFICATION FUNCTION
-- ------------------------------------------------------------
-- Free       : Price = 0
-- Budget     : Price > 0 and <= 100
-- Premium    : Price > 100 and <= 500
-- High Premium: Price > 500
-- ------------------------------------------------------------

DROP FUNCTION IF EXISTS classify_app_price;

DELIMITER //

CREATE FUNCTION classify_app_price(
    p_price DECIMAL(6,2)
)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE v_category VARCHAR(30);

    IF p_price = 0 THEN
        SET v_category = 'Free';

    ELSEIF p_price > 0 AND p_price <= 100 THEN
        SET v_category = 'Budget';

    ELSEIF p_price > 100 AND p_price <= 500 THEN
        SET v_category = 'Premium';

    ELSEIF p_price > 500 THEN
        SET v_category = 'High Premium';

    ELSE
        SET v_category = 'Invalid Price';
    END IF;

    RETURN v_category;
END //

DELIMITER ;

-- Display price category for all applications

SELECT
    AppID,
    AppName,
    Price,
    classify_app_price(Price) AS Price_Category
FROM Apps;


-- ------------------------------------------------------------
-- QUESTION 3: APPLICATION RATING DECISION
-- ------------------------------------------------------------
-- >= 4.5 : Highly Rated Application
-- >= 4.0 : Good Application
-- >= 3.0 : Average Application
-- <  3.0 : Low Rated Application
-- NULL   : Rating Not Available
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS application_rating_decision;

DELIMITER //

CREATE PROCEDURE application_rating_decision(
    IN p_app_id INT
)
BEGIN
    DECLARE v_rating DECIMAL(3,1);
    DECLARE v_found INT DEFAULT 1;
    DECLARE v_message VARCHAR(50);

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT Rating
    INTO v_rating
    FROM Apps
    WHERE AppID = p_app_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;

    ELSEIF v_rating IS NULL THEN
        SET v_message = 'Rating Not Available';

    ELSEIF v_rating >= 4.5 THEN
        SET v_message = 'Highly Rated Application';

    ELSEIF v_rating >= 4.0 THEN
        SET v_message = 'Good Application';

    ELSEIF v_rating >= 3.0 THEN
        SET v_message = 'Average Application';

    ELSE
        SET v_message = 'Low Rated Application';
    END IF;

    IF v_found = 1 THEN
        SELECT
            p_app_id AS AppID,
            v_rating AS Rating,
            v_message AS Rating_Decision;
    END IF;
END //

DELIMITER ;

-- Execute

CALL application_rating_decision(1001);


-- ============================================================
-- LEVEL 2 - PRACTICE QUESTIONS
-- ============================================================


-- ------------------------------------------------------------
-- QUESTION 1: LOOPING CONSTRUCTS
-- ------------------------------------------------------------
-- Display numbers from 1 to 10 using:
-- A. LOOP
-- B. WHILE LOOP
-- C. REPEAT LOOP
-- ------------------------------------------------------------


-- A. LOOP

DROP PROCEDURE IF EXISTS application_loop;

DELIMITER //

CREATE PROCEDURE application_loop()
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Loop_Output (
        Number_Value INT,
        Message VARCHAR(100)
    );

    TRUNCATE TABLE Loop_Output;

    simple_loop: LOOP

        INSERT INTO Loop_Output
        VALUES (
            v_counter,
            CONCAT('Processing Application ', v_counter)
        );

        SET v_counter = v_counter + 1;

        IF v_counter > 10 THEN
            LEAVE simple_loop;
        END IF;

    END LOOP;

    SELECT * FROM Loop_Output;
    DROP TEMPORARY TABLE Loop_Output;
END //

DELIMITER ;

-- Execute

CALL application_loop();


-- B. WHILE LOOP

DROP PROCEDURE IF EXISTS application_while_loop;

DELIMITER //

CREATE PROCEDURE application_while_loop()
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS While_Output (
        Number_Value INT,
        Message VARCHAR(100)
    );

    TRUNCATE TABLE While_Output;

    WHILE v_counter <= 10 DO

        INSERT INTO While_Output
        VALUES (
            v_counter,
            CONCAT('Application Number ', v_counter)
        );

        SET v_counter = v_counter + 1;

    END WHILE;

    SELECT * FROM While_Output;
    DROP TEMPORARY TABLE While_Output;
END //

DELIMITER ;

-- Execute

CALL application_while_loop();


-- C. REPEAT LOOP

DROP PROCEDURE IF EXISTS application_repeat_loop;

DELIMITER //

CREATE PROCEDURE application_repeat_loop()
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Repeat_Output (
        Number_Value INT,
        Message VARCHAR(100)
    );

    TRUNCATE TABLE Repeat_Output;

    REPEAT

        INSERT INTO Repeat_Output
        VALUES (
            v_counter,
            CONCAT('PlayStore Application ', v_counter)
        );

        SET v_counter = v_counter + 1;

    UNTIL v_counter > 10
    END REPEAT;

    SELECT * FROM Repeat_Output;
    DROP TEMPORARY TABLE Repeat_Output;
END //

DELIMITER ;

-- Execute

CALL application_repeat_loop();


-- ------------------------------------------------------------
-- QUESTION 2: CURSOR-BASED APPLICATION PROCESSING
-- ------------------------------------------------------------
-- Display AppID, AppName, Rating, Price and Downloads
-- for all applications.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS application_cursor_processing;

DELIMITER //

CREATE PROCEDURE application_cursor_processing()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_app_id INT;
    DECLARE v_app_name VARCHAR(60);
    DECLARE v_rating DECIMAL(2,1);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_downloads INT;

    DECLARE app_cursor CURSOR FOR
        SELECT AppID, AppName, Rating, Price, Downloads
        FROM Apps;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Cursor_Output (
        AppID INT,
        AppName VARCHAR(60),
        Rating DECIMAL(2,1),
        Price DECIMAL(6,2),
        Downloads INT
    );

    TRUNCATE TABLE Cursor_Output;

    OPEN app_cursor;

    read_loop: LOOP

        FETCH app_cursor
        INTO
            v_app_id,
            v_app_name,
            v_rating,
            v_price,
            v_downloads;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO Cursor_Output
        VALUES (
            v_app_id,
            v_app_name,
            v_rating,
            v_price,
            v_downloads
        );

    END LOOP;

    CLOSE app_cursor;

    SELECT * FROM Cursor_Output;

    DROP TEMPORARY TABLE Cursor_Output;
END //

DELIMITER ;

-- Execute

CALL application_cursor_processing();


-- ------------------------------------------------------------
-- QUESTION 3: PROCEDURE WITH UPDATE
-- ------------------------------------------------------------
-- Procedure: update_app_rating
-- Validate application existence and rating range (0 to 5).
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS update_app_rating;

DELIMITER //

CREATE PROCEDURE update_app_rating(
    IN p_application_id INT,
    IN p_new_rating DECIMAL(3,1)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_count
    FROM Apps
    WHERE AppID = p_application_id;

    IF v_count = 0 THEN
        SELECT 'Application not found' AS Message;

    ELSEIF p_new_rating IS NULL
        OR p_new_rating < 0
        OR p_new_rating > 5 THEN

        SELECT 'Invalid application rating' AS Message;

    ELSE
        UPDATE Apps
        SET Rating = p_new_rating
        WHERE AppID = p_application_id;

        SELECT
            AppID,
            AppName,
            Rating
        FROM Apps
        WHERE AppID = p_application_id;
    END IF;
END //

DELIMITER ;

-- Execute with valid rating

CALL update_app_rating(1001, 4.7);

-- Test invalid rating

CALL update_app_rating(1001, 6.5);

-- Test non-existing AppID

CALL update_app_rating(9999, 4.5);


-- ------------------------------------------------------------
-- QUESTION 4: INOUT PARAMETER PROCEDURE
-- ------------------------------------------------------------
-- Procedure: update_download_count
-- Retrieve existing downloads, add additional downloads,
-- update the table and return the total through INOUT.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS update_download_count;

DELIMITER //

CREATE PROCEDURE update_download_count(
    IN p_application_id INT,
    IN p_additional_downloads INT,
    INOUT p_total_downloads BIGINT
)
BEGIN
    DECLARE v_existing_downloads BIGINT DEFAULT 0;
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT Downloads
    INTO v_existing_downloads
    FROM Apps
    WHERE AppID = p_application_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;

    ELSEIF p_additional_downloads < 0 THEN
        SELECT 'Additional downloads cannot be negative' AS Message;

    ELSE
        SET p_total_downloads =
            v_existing_downloads + p_additional_downloads;

        UPDATE Apps
        SET Downloads = p_total_downloads
        WHERE AppID = p_application_id;

        SELECT
            p_application_id AS AppID,
            v_existing_downloads AS Previous_Downloads,
            p_additional_downloads AS Additional_Downloads,
            p_total_downloads AS Total_Downloads;
    END IF;
END //

DELIMITER ;

-- Execute INOUT procedure

SET @total_downloads = 0;

CALL update_download_count(1001, 1000, @total_downloads);

SELECT @total_downloads AS Updated_Total_Downloads;


-- ------------------------------------------------------------
-- QUESTION 5: APPLICATION EXCEPTION HANDLING
-- ------------------------------------------------------------
-- Handle NOT FOUND and SQLEXCEPTION.
-- Display AppName, Rating, Price and Downloads.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS application_exception_handling;

DELIMITER //

CREATE PROCEDURE application_exception_handling(
    IN p_application_id INT
)
BEGIN
    DECLARE v_app_name VARCHAR(60);
    DECLARE v_rating DECIMAL(2,1);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_downloads INT;
    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'An SQL error occurred while processing the application'
        AS Error_Message;
    END;

    SELECT
        AppName,
        Rating,
        Price,
        Downloads
    INTO
        v_app_name,
        v_rating,
        v_price,
        v_downloads
    FROM Apps
    WHERE AppID = p_application_id;

    IF v_found = 0 THEN
        SELECT 'Application not found' AS Message;
    ELSE
        SELECT
            v_app_name AS AppName,
            v_rating AS Rating,
            v_price AS Price,
            v_downloads AS Downloads;
    END IF;
END //

DELIMITER ;

-- Execute with existing AppID

CALL application_exception_handling(1001);

-- Execute with non-existing AppID

CALL application_exception_handling(9999);


-- ============================================================
-- LEVEL 3 - ADVANCED QUESTIONS
-- ============================================================


-- ------------------------------------------------------------
-- QUESTION 1: COMPLETE APPLICATION PROCESSING
-- ------------------------------------------------------------
-- Procedure: process_application
--
-- Retrieve application details with Developer, Publisher,
-- and Category information.
--
-- Rating Classification:
-- >= 4.5 : Excellent
-- >= 4.0 : Very Good
-- >= 3.0 : Good
-- <  3.0 : Needs Improvement
-- NULL   : Not Rated
--
-- Price Classification:
-- 0       : Free Application
-- 0-100   : Budget Application
-- 100-500 : Premium Application
-- > 500   : High Premium Application
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS process_application;

DELIMITER //

CREATE PROCEDURE process_application(
    IN p_application_id INT
)
BEGIN
    DECLARE v_app_id INT;
    DECLARE v_app_name VARCHAR(60);
    DECLARE v_rating DECIMAL(2,1);
    DECLARE v_price DECIMAL(6,2);
    DECLARE v_downloads INT;

    DECLARE v_developer VARCHAR(255);
    DECLARE v_publisher VARCHAR(255);
    DECLARE v_category VARCHAR(255);

    DECLARE v_rating_category VARCHAR(30);
    DECLARE v_price_category VARCHAR(30);

    DECLARE v_found INT DEFAULT 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_found = 0;

    SELECT
        A.AppID,
        A.AppName,
        A.Rating,
        A.Price,
        A.Downloads,
        D.DeveloperName,
        P.PublisherName,
        C.CategoryName
    INTO
        v_app_id,
        v_app_name,
        v_rating,
        v_price,
        v_downloads,
        v_developer,
        v_publisher,
        v_category
    FROM Apps A
    JOIN Developers D
        ON A.DeveloperID = D.DeveloperID
    JOIN Publishers P
        ON A.PublisherID = P.PublisherID
    JOIN Categories C
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

        ELSEIF v_price > 0 AND v_price <= 100 THEN
            SET v_price_category = 'Budget Application';

        ELSEIF v_price > 100 AND v_price <= 500 THEN
            SET v_price_category = 'Premium Application';

        ELSE
            SET v_price_category = 'High Premium Application';
        END IF;

        -- Complete Application Report

        SELECT 'APPLICATION DETAILS REPORT' AS Report_Title;

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

-- Execute

CALL process_application(1001);

-- Test missing application

CALL process_application(9999);


-- ------------------------------------------------------------
-- QUESTION 2: DEVELOPER APPLICATION CURSOR PROCESSING
-- ------------------------------------------------------------
-- Display:
-- DeveloperID
-- DeveloperName
-- Number of Applications
-- Average Application Rating
-- Total Downloads
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS developer_application_cursor;

DELIMITER //

CREATE PROCEDURE developer_application_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;

    DECLARE v_developer_id INT;
    DECLARE v_developer_name VARCHAR(255);
    DECLARE v_app_count INT;
    DECLARE v_average_rating DECIMAL(5,2);
    DECLARE v_total_downloads BIGINT;

    DECLARE developer_cursor CURSOR FOR
        SELECT
            D.DeveloperID,
            D.DeveloperName,
            COUNT(A.AppID),
            AVG(A.Rating),
            COALESCE(SUM(A.Downloads), 0)
        FROM Developers D
        JOIN Apps A
            ON D.DeveloperID = A.DeveloperID
        GROUP BY D.DeveloperID, D.DeveloperName;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Developer_Report (
        DeveloperID INT,
        DeveloperName VARCHAR(255),
        Number_Of_Applications INT,
        Average_Rating DECIMAL(5,2),
        Total_Downloads BIGINT
    );

    TRUNCATE TABLE Developer_Report;

    OPEN developer_cursor;

    developer_loop: LOOP

        FETCH developer_cursor
        INTO
            v_developer_id,
            v_developer_name,
            v_app_count,
            v_average_rating,
            v_total_downloads;

        IF v_done = 1 THEN
            LEAVE developer_loop;
        END IF;

        INSERT INTO Developer_Report
        VALUES (
            v_developer_id,
            v_developer_name,
            v_app_count,
            v_average_rating,
            v_total_downloads
        );

    END LOOP;

    CLOSE developer_cursor;

    SELECT * FROM Developer_Report;

    DROP TEMPORARY TABLE Developer_Report;
END //

DELIMITER ;

-- Execute

CALL developer_application_cursor();


-- ------------------------------------------------------------
-- QUESTION 3: COMBINED FUNCTION AND CURSOR
-- ------------------------------------------------------------
-- Use get_developer_app_count() function inside a cursor.
--
-- 0 Applications : No Applications
-- 1-2 Applications: Small Portfolio
-- More than 2    : Large Portfolio
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS developer_portfolio_cursor;

DELIMITER //

CREATE PROCEDURE developer_portfolio_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;

    DECLARE v_developer_id INT;
    DECLARE v_developer_name VARCHAR(255);
    DECLARE v_app_count INT;
    DECLARE v_portfolio_category VARCHAR(30);

    DECLARE developer_cursor CURSOR FOR
        SELECT DeveloperID, DeveloperName
        FROM Developers;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    CREATE TEMPORARY TABLE IF NOT EXISTS Portfolio_Report (
        DeveloperID INT,
        DeveloperName VARCHAR(255),
        Application_Count INT,
        Developer_Application_Category VARCHAR(30)
    );

    TRUNCATE TABLE Portfolio_Report;

    OPEN developer_cursor;

    portfolio_loop: LOOP

        FETCH developer_cursor
        INTO v_developer_id, v_developer_name;

        IF v_done = 1 THEN
            LEAVE portfolio_loop;
        END IF;

        -- Call the function for every developer

        SET v_app_count =
            get_developer_app_count(v_developer_id);

        -- Portfolio Classification

        IF v_app_count = 0 THEN
            SET v_portfolio_category = 'No Applications';

        ELSEIF v_app_count <= 2 THEN
            SET v_portfolio_category = 'Small Portfolio';

        ELSE
            SET v_portfolio_category = 'Large Portfolio';
        END IF;

        INSERT INTO Portfolio_Report
        VALUES (
            v_developer_id,
            v_developer_name,
            v_app_count,
            v_portfolio_category
        );

    END LOOP;

    CLOSE developer_cursor;

    SELECT * FROM Portfolio_Report;

    DROP TEMPORARY TABLE Portfolio_Report;
END //

DELIMITER ;

-- Execute

CALL developer_portfolio_cursor();


-- ============================================================
-- FINAL VERIFICATION
-- ============================================================

-- Verify all applications

SELECT * FROM Apps;

-- Verify all developers

SELECT * FROM Developers;

-- Verify all publishers

SELECT * FROM Publishers;

-- Verify all categories

SELECT * FROM Categories;

-- Verify created procedures

SHOW PROCEDURE STATUS
WHERE Db = 'PlayStoreDB';

-- Verify created functions

SHOW FUNCTION STATUS
WHERE Db = 'PlayStoreDB';


