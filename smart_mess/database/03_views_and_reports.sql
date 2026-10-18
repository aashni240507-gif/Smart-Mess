-- ============================================================================
-- SmartMess: Smart College Mess Food Management System
-- Script: 03_views_and_reports.sql
-- Description: Creates Oracle Database views for operational dashboards,
--              attendance summaries, feedback analysis, and food wastage tracking.
-- Target DB: Oracle Database 21c XE / 23ai / 19c Enterprise
-- ============================================================================

SET FEEDBACK ON;

PROMPT ============================================================================
PROMPT Creating SmartMess Database Views...
PROMPT ============================================================================

-- ----------------------------------------------------------------------------
-- VIEW 1: VW_TODAY_MENU
-- Fetches today's breakfast, lunch, and dinner menus.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_TODAY_MENU AS
SELECT 
    m.MENU_ID,
    m.MENU_DATE,
    mt.MEAL_TYPE_ID,
    mt.MEAL_NAME,
    m.FOOD_ITEMS,
    m.NOTES
FROM MENU m
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
WHERE TRUNC(m.MENU_DATE) = TRUNC(SYSDATE);

PROMPT View VW_TODAY_MENU created.

-- ----------------------------------------------------------------------------
-- VIEW 2: VW_ATTENDANCE_SUMMARY
-- Aggregates student meal headcount per date and meal type.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_ATTENDANCE_SUMMARY AS
SELECT 
    m.MENU_ID,
    m.MENU_DATE,
    mt.MEAL_NAME,
    COUNT(a.ATTENDANCE_ID) AS TOTAL_RESPONSES,
    SUM(CASE WHEN a.STATUS = 'PRESENT' THEN 1 ELSE 0 END) AS PRESENT_COUNT,
    SUM(CASE WHEN a.STATUS = 'ABSENT' THEN 1 ELSE 0 END) AS ABSENT_COUNT
FROM MENU m
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
LEFT JOIN ATTENDANCE a ON m.MENU_ID = a.MENU_ID
GROUP BY m.MENU_ID, m.MENU_DATE, mt.MEAL_NAME;

PROMPT View VW_ATTENDANCE_SUMMARY created.

-- ----------------------------------------------------------------------------
-- VIEW 3: VW_MEAL_FEEDBACK_STATS
-- Calculates average quality, taste, and cleanliness ratings per meal.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_MEAL_FEEDBACK_STATS AS
SELECT 
    m.MENU_ID,
    m.MENU_DATE,
    mt.MEAL_NAME,
    COUNT(f.FEEDBACK_ID) AS TOTAL_REVIEWS,
    ROUND(AVG(f.FOOD_QUALITY), 2) AS AVG_QUALITY,
    ROUND(AVG(f.TASTE), 2) AS AVG_TASTE,
    ROUND(AVG(f.CLEANLINESS), 2) AS AVG_CLEANLINESS,
    ROUND(AVG((f.FOOD_QUALITY + f.TASTE + f.CLEANLINESS) / 3.0), 2) AS OVERALL_RATING
FROM MENU m
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
LEFT JOIN FEEDBACK f ON m.MENU_ID = f.MENU_ID
GROUP BY m.MENU_ID, m.MENU_DATE, mt.MEAL_NAME;

PROMPT View VW_MEAL_FEEDBACK_STATS created.

-- ----------------------------------------------------------------------------
-- VIEW 4: VW_COMPLAINT_DETAILS
-- Enriched complaint records joining student user and category info.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_COMPLAINT_DETAILS AS
SELECT 
    c.COMPLAINT_ID,
    c.USER_ID,
    u.NAME AS STUDENT_NAME,
    u.EMAIL AS STUDENT_EMAIL,
    u.HOSTEL,
    u.ROOM_NO,
    c.CATEGORY_ID,
    cat.CATEGORY_NAME,
    c.DESCRIPTION,
    c.STATUS,
    c.CREATED_AT,
    c.RESOLVED_AT
FROM COMPLAINTS c
JOIN USERS u ON c.USER_ID = u.USER_ID
JOIN COMPLAINT_CATEGORIES cat ON c.CATEGORY_ID = cat.CATEGORY_ID;

PROMPT View VW_COMPLAINT_DETAILS created.

-- ----------------------------------------------------------------------------
-- VIEW 5: VW_FOOD_WASTAGE_ANALYSIS
-- Daily food preparation, served, wasted amounts and wastage percentage.
-- Wastage % = (Food Wasted / Food Prepared) * 100
-- Uses DECODE/NULLIF to safely prevent division by zero.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_FOOD_WASTAGE_ANALYSIS AS
SELECT 
    w.WASTAGE_ID,
    m.MENU_ID,
    m.MENU_DATE,
    mt.MEAL_NAME,
    w.FOOD_PREPARED,
    w.FOOD_SERVED,
    w.FOOD_WASTED,
    ROUND(
        CASE 
            WHEN w.FOOD_PREPARED > 0 THEN (w.FOOD_WASTED / w.FOOD_PREPARED) * 100 
            ELSE 0 
        END, 2
    ) AS WASTAGE_PERCENTAGE,
    u.NAME AS RECORDED_BY_NAME,
    w.RECORDED_AT
FROM WASTAGE w
JOIN MENU m ON w.MENU_ID = m.MENU_ID
JOIN MEAL_TYPES mt ON m.MEAL_TYPE_ID = mt.MEAL_TYPE_ID
JOIN USERS u ON w.RECORDED_BY = u.USER_ID;

PROMPT View VW_FOOD_WASTAGE_ANALYSIS created.

-- ----------------------------------------------------------------------------
-- VIEW 6: VW_MONTHLY_WASTAGE_SUMMARY
-- Monthly aggregated summary of mess food efficiency.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_MONTHLY_WASTAGE_SUMMARY AS
SELECT 
    TO_CHAR(m.MENU_DATE, 'YYYY-MM') AS YEAR_MONTH,
    COUNT(w.WASTAGE_ID) AS MEAL_COUNT,
    SUM(w.FOOD_PREPARED) AS TOTAL_PREPARED_KG,
    SUM(w.FOOD_SERVED) AS TOTAL_SERVED_KG,
    SUM(w.FOOD_WASTED) AS TOTAL_WASTED_KG,
    ROUND(
        CASE 
            WHEN SUM(w.FOOD_PREPARED) > 0 
            THEN (SUM(w.FOOD_WASTED) / SUM(w.FOOD_PREPARED)) * 100 
            ELSE 0 
        END, 2
    ) AS MONTHLY_WASTAGE_PERCENTAGE
FROM WASTAGE w
JOIN MENU m ON w.MENU_ID = m.MENU_ID
GROUP BY TO_CHAR(m.MENU_DATE, 'YYYY-MM');

PROMPT View VW_MONTHLY_WASTAGE_SUMMARY created.
PROMPT ============================================================================
PROMPT All database views created successfully!
PROMPT ============================================================================
