-- ============================================================================
-- SmartMess: Smart College Mess Food Management System
-- Script: 04_demo_queries.sql
-- Description: 10+ Comprehensive SQL Queries demonstrating DBMS concepts:
--              SELECT, WHERE, JOINs (INNER/LEFT), Aggregate Functions (COUNT, SUM, AVG),
--              GROUP BY, HAVING, Subqueries, Date functions, and Ratio Calculations.
-- Suitable for Lab Exam, Viva Defense, and Project Demonstration.
-- Target DB: Oracle Database 21c XE / 23ai / 19c Enterprise
-- ============================================================================

SET LINESIZE 200;
SET PAGESIZE 100;
SET FEEDBACK ON;
SET DEFINE OFF;
SET SQLBLANKLINES ON;

PROMPT ============================================================================
PROMPT SMARTMESS DEMO QUERIES FOR DBMS VIVA AND EVALUATION
PROMPT ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: Display all registered students with hostel room details
-- DBMS Concepts Demonstrated: Basic SELECT, WHERE filtering, ORDER BY
-- Viva Explanation: Retrieves all rows where ROLE is 'STUDENT', sorted by name.
-- ----------------------------------------------------------------------------
PROMPT --- Query 1: Display All Students ---
COLUMN USER_ID FORMAT 999;
COLUMN NAME FORMAT A20;
COLUMN EMAIL FORMAT A25;
COLUMN HOSTEL FORMAT A15;
COLUMN ROOM_NO FORMAT A10;

SELECT USER_ID, NAME, EMAIL, HOSTEL, ROOM_NO, CREATED_AT
FROM USERS
WHERE ROLE = 'STUDENT'
ORDER BY NAME ASC;

-- ----------------------------------------------------------------------------
-- QUERY 2: Display the full menu schedule for today
-- DBMS Concepts Demonstrated: INNER JOIN, Date truncation (TRUNC(SYSDATE))
-- Viva Explanation: Joins MENU with MEAL_TYPES on primary-foreign key match,
-- matching only the current date regardless of time component.
-- ----------------------------------------------------------------------------
PROMPT --- Query 2: Display Today's Menu Schedule ---
COLUMN MEAL_NAME FORMAT A12;
COLUMN FOOD_ITEMS FORMAT A45;
COLUMN NOTES FORMAT A25;

SELECT 
    m.MENU_ID,
    TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS MENU_DATE,
    mt.MEAL_NAME,
    m.FOOD_ITEMS,
    m.NOTES
FROM MENU m
INNER JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
WHERE TRUNC(m.MENU_DATE) = TRUNC(SYSDATE)
ORDER BY mt.MEAL_TYPE_ID ASC;

-- ----------------------------------------------------------------------------
-- QUERY 3: Count expected meal attendance (Present vs Absent) per meal
-- DBMS Concepts Demonstrated: LEFT JOIN, COUNT, Conditional Aggregation (CASE WHEN), GROUP BY
-- Viva Explanation: Uses LEFT JOIN so meals with 0 attendance still appear.
-- Summarizes headcount marked PRESENT vs ABSENT.
-- ----------------------------------------------------------------------------
PROMPT --- Query 3: Count Expected Attendance by Meal ---
COLUMN TOTAL_MARKED FORMAT 999;
COLUMN PRESENT_COUNT FORMAT 999;
COLUMN ABSENT_COUNT FORMAT 999;

SELECT 
    TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS MEAL_DATE,
    mt.MEAL_NAME,
    COUNT(a.ATTENDANCE_ID) AS TOTAL_MARKED,
    SUM(CASE WHEN a.STATUS = 'PRESENT' THEN 1 ELSE 0 END) AS PRESENT_COUNT,
    SUM(CASE WHEN a.STATUS = 'ABSENT' THEN 1 ELSE 0 END) AS ABSENT_COUNT
FROM MENU m
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
LEFT JOIN ATTENDANCE a ON m.MENU_ID = a.MENU_ID
GROUP BY m.MENU_DATE, mt.MEAL_TYPE_ID, mt.MEAL_NAME
ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC;

-- ----------------------------------------------------------------------------
-- QUERY 4: Display attendance history for a specific student
-- DBMS Concepts Demonstrated: Multi-table JOIN (ATTENDANCE, USERS, MENU, MEAL_TYPES)
-- Viva Explanation: Demonstrates 4-table relational navigation from student to meal.
-- ----------------------------------------------------------------------------
PROMPT --- Query 4: Display Student Attendance History (Aarav Sharma) ---
COLUMN STUDENT_NAME FORMAT A18;
COLUMN STATUS FORMAT A10;
COLUMN MARKED_TIME FORMAT A20;

SELECT 
    u.NAME AS STUDENT_NAME,
    TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS MEAL_DATE,
    mt.MEAL_NAME,
    a.STATUS,
    TO_CHAR(a.MARKED_AT, 'YYYY-MM-DD HH24:MI:SS') AS MARKED_TIME
FROM ATTENDANCE a
JOIN USERS u ON a.USER_ID = u.USER_ID
JOIN MENU m ON a.MENU_ID = m.MENU_ID
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
WHERE u.EMAIL = 'student@smartmess.edu'
ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC;

-- ----------------------------------------------------------------------------
-- QUERY 5: Calculate average food ratings (Quality, Taste, Cleanliness) by meal
-- DBMS Concepts Demonstrated: Aggregate AVG(), ROUND(), GROUP BY, HAVING clause
-- Viva Explanation: Aggregates student star ratings, rounding to 2 decimal places.
-- HAVING filters only meals that have at least 1 review.
-- ----------------------------------------------------------------------------
PROMPT --- Query 5: Average Food Ratings by Meal ---
COLUMN AVG_QUALITY FORMAT 9.99;
COLUMN AVG_TASTE FORMAT 9.99;
COLUMN AVG_CLEANLINESS FORMAT 9.99;
COLUMN OVERALL_RATING FORMAT 9.99;
COLUMN REVIEWS_COUNT FORMAT 999;

SELECT 
    TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS MEAL_DATE,
    mt.MEAL_NAME,
    COUNT(f.FEEDBACK_ID) AS REVIEWS_COUNT,
    ROUND(AVG(f.FOOD_QUALITY), 2) AS AVG_QUALITY,
    ROUND(AVG(f.TASTE), 2) AS AVG_TASTE,
    ROUND(AVG(f.CLEANLINESS), 2) AS AVG_CLEANLINESS,
    ROUND(AVG((f.FOOD_QUALITY + f.TASTE + f.CLEANLINESS) / 3.0), 2) AS OVERALL_RATING
FROM MENU m
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
JOIN FEEDBACK f ON m.MENU_ID = f.MENU_ID
GROUP BY m.MENU_DATE, mt.MEAL_TYPE_ID, mt.MEAL_NAME
HAVING COUNT(f.FEEDBACK_ID) > 0
ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC;

-- ----------------------------------------------------------------------------
-- QUERY 6: List pending complaints requiring staff / admin action
-- DBMS Concepts Demonstrated: WHERE with multiple conditions, JOIN with lookup table
-- Viva Explanation: Identifies urgent grievances not yet resolved.
-- ----------------------------------------------------------------------------
PROMPT --- Query 6: List Pending / In-Progress Complaints ---
COLUMN COMPLAINT_ID FORMAT 999;
COLUMN CATEGORY_NAME FORMAT A15;
COLUMN DESCRIPTION FORMAT A40;
COLUMN STATUS FORMAT A12;

SELECT 
    c.COMPLAINT_ID,
    u.NAME AS STUDENT_NAME,
    u.ROOM_NO,
    cat.CATEGORY_NAME,
    c.DESCRIPTION,
    c.STATUS,
    TO_CHAR(c.CREATED_AT, 'YYYY-MM-DD HH24:MI') AS FILED_ON
FROM COMPLAINTS c
JOIN USERS u ON c.USER_ID = u.USER_ID
JOIN COMPLAINT_CATEGORIES cat ON c.CATEGORY_ID = cat.CATEGORY_ID
WHERE c.STATUS IN ('PENDING', 'IN_PROGRESS')
ORDER BY c.CREATED_AT ASC;

-- ----------------------------------------------------------------------------
-- QUERY 7: Count complaints grouped by category and status
-- DBMS Concepts Demonstrated: Multi-column GROUP BY, Aggregate COUNT()
-- Viva Explanation: Allows administration to see which mess department receives
-- the most complaints and how many remain unresolved.
-- ----------------------------------------------------------------------------
PROMPT --- Query 7: Complaint Counts by Category and Status ---
COLUMN COMPLAINT_COUNT FORMAT 999;

SELECT 
    cat.CATEGORY_NAME,
    c.STATUS,
    COUNT(c.COMPLAINT_ID) AS COMPLAINT_COUNT
FROM COMPLAINT_CATEGORIES cat
LEFT JOIN COMPLAINTS c ON cat.CATEGORY_ID = c.CATEGORY_ID
GROUP BY cat.CATEGORY_NAME, c.STATUS
ORDER BY cat.CATEGORY_NAME, c.STATUS;

-- ----------------------------------------------------------------------------
-- QUERY 8: Calculate overall food metrics: Total Prepared, Served, and Wasted
-- DBMS Concepts Demonstrated: Global SUM() aggregates, mathematical difference check
-- Viva Explanation: Provides macro mess logistics totals across all recorded meals.
-- ----------------------------------------------------------------------------
PROMPT --- Query 8: Overall Food Preparation and Wastage Totals (KG) ---
COLUMN TOTAL_PREPARED_KG FORMAT 9,999.99;
COLUMN TOTAL_SERVED_KG FORMAT 9,999.99;
COLUMN TOTAL_WASTED_KG FORMAT 9,999.99;
COLUMN LEFTOVER_KG FORMAT 9,999.99;

SELECT 
    SUM(FOOD_PREPARED) AS TOTAL_PREPARED_KG,
    SUM(FOOD_SERVED)   AS TOTAL_SERVED_KG,
    SUM(FOOD_WASTED)   AS TOTAL_WASTED_KG,
    SUM(FOOD_PREPARED - FOOD_SERVED) AS LEFTOVER_KG
FROM WASTAGE;

-- ----------------------------------------------------------------------------
-- QUERY 9: Calculate food wastage percentage by meal
-- DBMS Concepts Demonstrated: Arithmetic expressions in SELECT, CASE statement, ROUND()
-- Viva Explanation: Wastage % = (Food Wasted / Food Prepared) * 100.
-- Handles division by zero gracefully using CASE WHEN.
-- ----------------------------------------------------------------------------
PROMPT --- Query 9: Food Wastage Percentage per Meal ---
COLUMN PREPARED FORMAT 999.9;
COLUMN SERVED FORMAT 999.9;
COLUMN WASTED FORMAT 999.9;
COLUMN WASTAGE_PCT FORMAT 990.99;

SELECT 
    TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS MEAL_DATE,
    mt.MEAL_NAME,
    w.FOOD_PREPARED AS PREPARED,
    w.FOOD_SERVED AS SERVED,
    w.FOOD_WASTED AS WASTED,
    ROUND(
        CASE 
            WHEN w.FOOD_PREPARED > 0 THEN (w.FOOD_WASTED / w.FOOD_PREPARED) * 100 
            ELSE 0 
        END, 2
    ) AS WASTAGE_PCT,
    u.NAME AS RECORDED_BY
FROM WASTAGE w
JOIN MENU m ON w.MENU_ID = m.MENU_ID
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
JOIN USERS u ON w.RECORDED_BY = u.USER_ID
ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC;

-- ----------------------------------------------------------------------------
-- QUERY 10: Operational Daily Summary (Menu, Attendance Headcount, Wastage)
-- DBMS Concepts Demonstrated: Multiple LEFT JOINs across core entities, Subqueries
-- Viva Explanation: Correlates daily attendance headcount directly with food wasted.
-- ----------------------------------------------------------------------------
PROMPT --- Query 10: Daily Operational Summary ---
COLUMN OPERATION_DATE FORMAT A14;
COLUMN MEAL_NAME FORMAT A12;
COLUMN STUDENTS_ATE FORMAT 999;
COLUMN KG_PREPARED FORMAT 999.9;
COLUMN KG_WASTED FORMAT 999.9;

SELECT TO_CHAR(m.MENU_DATE, 'YYYY-MM-DD') AS OPERATION_DATE,
       mt.MEAL_NAME,
       NVL(att.PRESENT_STUDENTS, 0) AS STUDENTS_ATE,
       NVL(w.FOOD_PREPARED, 0) AS KG_PREPARED,
       NVL(w.FOOD_WASTED, 0) AS KG_WASTED
FROM MENU m
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
LEFT JOIN (
    SELECT MENU_ID, COUNT(*) AS PRESENT_STUDENTS
    FROM ATTENDANCE
    WHERE STATUS = 'PRESENT'
    GROUP BY MENU_ID
) att ON m.MENU_ID = att.MENU_ID
LEFT JOIN WASTAGE w ON m.MENU_ID = w.MENU_ID
ORDER BY m.MENU_DATE DESC, mt.MEAL_TYPE_ID ASC;

PROMPT ============================================================================
PROMPT End of Demo Queries. All queries executed successfully!
PROMPT ============================================================================
