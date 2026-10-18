-- ============================================================================
-- SmartMess: Smart College Mess Food Management System
-- Script: 02_insert_sample_data.sql
-- Description: Seeds the Oracle database with initial lookup data,
--              realistic user accounts (matching BCrypt hashes),
--              daily menus, attendance, feedback, complaints, and wastage.
-- Target DB: Oracle Database 21c XE / 23ai / 19c Enterprise
-- ============================================================================

SET FEEDBACK ON;

PROMPT ============================================================================
PROMPT Seeding SmartMess Initial Data...
PROMPT ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SEED MEAL TYPES
-- ----------------------------------------------------------------------------
INSERT INTO MEAL_TYPES (MEAL_NAME) VALUES ('Breakfast');
INSERT INTO MEAL_TYPES (MEAL_NAME) VALUES ('Lunch');
INSERT INTO MEAL_TYPES (MEAL_NAME) VALUES ('Dinner');

PROMPT Meal types seeded.

-- ----------------------------------------------------------------------------
-- 2. SEED COMPLAINT CATEGORIES
-- ----------------------------------------------------------------------------
INSERT INTO COMPLAINT_CATEGORIES (CATEGORY_NAME) VALUES ('Food Quality');
INSERT INTO COMPLAINT_CATEGORIES (CATEGORY_NAME) VALUES ('Cleanliness');
INSERT INTO COMPLAINT_CATEGORIES (CATEGORY_NAME) VALUES ('Service');
INSERT INTO COMPLAINT_CATEGORIES (CATEGORY_NAME) VALUES ('Quantity');
INSERT INTO COMPLAINT_CATEGORIES (CATEGORY_NAME) VALUES ('Other');

PROMPT Complaint categories seeded.

-- ----------------------------------------------------------------------------
-- 3. SEED USERS
-- Demo Passwords:
--   admin@smartmess.edu   -> admin123
--   staff@smartmess.edu   -> staff123
--   student@smartmess.edu -> student123
--   rahul@smartmess.edu   -> student123
--   priya@smartmess.edu   -> student123
--   amit@smartmess.edu    -> student123
--   sneha@smartmess.edu   -> student123
-- ----------------------------------------------------------------------------
INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Admin Officer', 
    'admin@smartmess.edu', 
    '$2a$10$M7xe/ppV5Ih2aB5M7geABevLjALvoK5/zj4TM/9UhbyRWywXKxvAK', 
    'ADMIN', 
    'Admin Block', 
    'A-101'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Chef Raman Kumar', 
    'staff@smartmess.edu', 
    '$2a$10$yMMOGBa3p8B0pb6viGjXjuhi8QmDq8anr17sw1AQryrWc8VkXruTq', 
    'STAFF', 
    'Staff Quarters', 
    'SQ-12'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Supervisor Meera Sen', 
    'staff2@smartmess.edu', 
    '$2a$10$yMMOGBa3p8B0pb6viGjXjuhi8QmDq8anr17sw1AQryrWc8VkXruTq', 
    'STAFF', 
    'Staff Quarters', 
    'SQ-15'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Aarav Sharma', 
    'student@smartmess.edu', 
    '$2a$10$DE7Tf1AzOtfID9w3PTizZezhNWkSpnx5fPazRG2ZAWS.KFzusmoAy', 
    'STUDENT', 
    'Kaveri Hostel', 
    'KH-204'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Rahul Verma', 
    'rahul@smartmess.edu', 
    '$2a$10$DE7Tf1AzOtfID9w3PTizZezhNWkSpnx5fPazRG2ZAWS.KFzusmoAy', 
    'STUDENT', 
    'Kaveri Hostel', 
    'KH-205'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Priya Nair', 
    'priya@smartmess.edu', 
    '$2a$10$DE7Tf1AzOtfID9w3PTizZezhNWkSpnx5fPazRG2ZAWS.KFzusmoAy', 
    'STUDENT', 
    'Ganga Hostel', 
    'GH-312'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Amit Patel', 
    'amit@smartmess.edu', 
    '$2a$10$DE7Tf1AzOtfID9w3PTizZezhNWkSpnx5fPazRG2ZAWS.KFzusmoAy', 
    'STUDENT', 
    'Yamuna Hostel', 
    'YH-118'
);

INSERT INTO USERS (NAME, EMAIL, PASSWORD_HASH, ROLE, HOSTEL, ROOM_NO) 
VALUES (
    'Sneha Reddy', 
    'sneha@smartmess.edu', 
    '$2a$10$DE7Tf1AzOtfID9w3PTizZezhNWkSpnx5fPazRG2ZAWS.KFzusmoAy', 
    'STUDENT', 
    'Ganga Hostel', 
    'GH-315'
);

PROMPT Users seeded.

-- ----------------------------------------------------------------------------
-- 4. SEED MENUS (Past, Today, and Tomorrow)
-- Meal Type IDs: 1 = Breakfast, 2 = Lunch, 3 = Dinner
-- ----------------------------------------------------------------------------
-- Yesterday's Menu (TRUNC(SYSDATE) - 1)
INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE) - 1, 1, 'Idli, Medu Vada, Sambar, Coconut Chutney, Tea/Coffee', 'South Indian Special');

INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE) - 1, 2, 'Steamed Rice, Dal Tadka, Paneer Butter Masala, Roti, Curd, Salad', 'Paneer Feast');

INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE) - 1, 3, 'Veg Dum Biryani, Mirchi Ka Salan, Onion Raita, Gulab Jamun', 'Weekend Special Dinner');

-- Today's Menu (TRUNC(SYSDATE))
INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE), 1, 'Masala Dosa, Tomato Chutney, Sambar, Boiled Eggs / Banana, Filter Coffee', 'Fresh crispy dosas served hot');

INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE), 2, 'Jeera Rice, Punjabi Rajma Masala, Aloo Gobi Dry, Phulka, Boondi Raita, Papad', 'North Indian Thali');

INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE), 3, 'Chapati, Mixed Veg Kurma, Dal Fry, Steamed Rice, Rasam, Fresh Fruit Custard', 'Balanced dinner menu');

-- Tomorrow's Menu (TRUNC(SYSDATE) + 1)
INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE) + 1, 1, 'Indori Poha, Sev, Jalebi, Sprouts Salad, Tea/Coffee', 'Breakfast classic');

INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE) + 1, 2, 'Lemon Rice, Sambar, Bhindi Fry, Curd Rice, Pickle, Appalam', 'Traditional lunch');

INSERT INTO MENU (MENU_DATE, MEAL_TYPE_ID, FOOD_ITEMS, NOTES) 
VALUES (TRUNC(SYSDATE) + 1, 3, 'Pav Bhaji, Veg Pulao, Cucumber Raita, Rasgulla', 'Student favorite combo');

PROMPT Menus seeded.

-- ----------------------------------------------------------------------------
-- 5. SEED ATTENDANCE
-- Link students to yesterday and today menus
-- ----------------------------------------------------------------------------
-- Look up IDs dynamically or by subquery for absolute safety
INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'student@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 1;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'student@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 2;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'student@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 3;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'rahul@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 2;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'ABSENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'rahul@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 3;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'priya@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) AND m.MEAL_TYPE_ID = 1;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'student@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) AND m.MEAL_TYPE_ID = 1;

INSERT INTO ATTENDANCE (USER_ID, MENU_ID, STATUS)
SELECT u.USER_ID, m.MENU_ID, 'PRESENT'
FROM USERS u, MENU m
WHERE u.EMAIL = 'amit@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) AND m.MEAL_TYPE_ID = 1;

PROMPT Attendance records seeded.

-- ----------------------------------------------------------------------------
-- 6. SEED FEEDBACK
-- ----------------------------------------------------------------------------
INSERT INTO FEEDBACK (USER_ID, MENU_ID, FOOD_QUALITY, TASTE, CLEANLINESS, COMMENTS)
SELECT u.USER_ID, m.MENU_ID, 5, 4, 5, 'Idli and Vada were very fresh and crispy!'
FROM USERS u, MENU m
WHERE u.EMAIL = 'student@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 1;

INSERT INTO FEEDBACK (USER_ID, MENU_ID, FOOD_QUALITY, TASTE, CLEANLINESS, COMMENTS)
SELECT u.USER_ID, m.MENU_ID, 4, 5, 4, 'Paneer butter masala was delicious!'
FROM USERS u, MENU m
WHERE u.EMAIL = 'rahul@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 2;

INSERT INTO FEEDBACK (USER_ID, MENU_ID, FOOD_QUALITY, TASTE, CLEANLINESS, COMMENTS)
SELECT u.USER_ID, m.MENU_ID, 5, 5, 5, 'Biryani and Gulab Jamun was an awesome combo.'
FROM USERS u, MENU m
WHERE u.EMAIL = 'priya@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 3;

INSERT INTO FEEDBACK (USER_ID, MENU_ID, FOOD_QUALITY, TASTE, CLEANLINESS, COMMENTS)
SELECT u.USER_ID, m.MENU_ID, 4, 4, 4, 'Dosas were warm and coconut chutney was great.'
FROM USERS u, MENU m
WHERE u.EMAIL = 'student@smartmess.edu' 
  AND m.MENU_DATE = TRUNC(SYSDATE) AND m.MEAL_TYPE_ID = 1;

PROMPT Feedback records seeded.

-- ----------------------------------------------------------------------------
-- 7. SEED COMPLAINTS
-- ----------------------------------------------------------------------------
INSERT INTO COMPLAINTS (USER_ID, CATEGORY_ID, DESCRIPTION, STATUS, RESOLVED_AT)
SELECT u.USER_ID, c.CATEGORY_ID, 
       'Water cooler in the second floor dining area is not cooling properly.', 
       'RESOLVED', CURRENT_TIMESTAMP - INTERVAL '1' DAY
FROM USERS u, COMPLAINT_CATEGORIES c
WHERE u.EMAIL = 'student@smartmess.edu' AND c.CATEGORY_NAME = 'Service';

INSERT INTO COMPLAINTS (USER_ID, CATEGORY_ID, DESCRIPTION, STATUS)
SELECT u.USER_ID, c.CATEGORY_ID, 
       'Need additional serving counter during lunch peak hours between 1:00 PM and 1:30 PM.', 
       'IN_PROGRESS'
FROM USERS u, COMPLAINT_CATEGORIES c
WHERE u.EMAIL = 'rahul@smartmess.edu' AND c.CATEGORY_NAME = 'Quantity';

INSERT INTO COMPLAINTS (USER_ID, CATEGORY_ID, DESCRIPTION, STATUS)
SELECT u.USER_ID, c.CATEGORY_ID, 
       'Please check the dining hall handwash liquid dispensers, they ran out at dinner yesterday.', 
       'PENDING'
FROM USERS u, COMPLAINT_CATEGORIES c
WHERE u.EMAIL = 'priya@smartmess.edu' AND c.CATEGORY_NAME = 'Cleanliness';

PROMPT Complaints seeded.

-- ----------------------------------------------------------------------------
-- 8. SEED FOOD WASTAGE
-- ----------------------------------------------------------------------------
INSERT INTO WASTAGE (MENU_ID, FOOD_PREPARED, FOOD_SERVED, FOOD_WASTED, RECORDED_BY)
SELECT m.MENU_ID, 85.00, 78.50, 6.50, u.USER_ID
FROM MENU m, USERS u
WHERE m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 1 AND u.EMAIL = 'staff@smartmess.edu';

INSERT INTO WASTAGE (MENU_ID, FOOD_PREPARED, FOOD_SERVED, FOOD_WASTED, RECORDED_BY)
SELECT m.MENU_ID, 140.00, 125.00, 15.00, u.USER_ID
FROM MENU m, USERS u
WHERE m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 2 AND u.EMAIL = 'staff@smartmess.edu';

INSERT INTO WASTAGE (MENU_ID, FOOD_PREPARED, FOOD_SERVED, FOOD_WASTED, RECORDED_BY)
SELECT m.MENU_ID, 130.00, 118.00, 12.00, u.USER_ID
FROM MENU m, USERS u
WHERE m.MENU_DATE = TRUNC(SYSDATE) - 1 AND m.MEAL_TYPE_ID = 3 AND u.EMAIL = 'staff@smartmess.edu';

INSERT INTO WASTAGE (MENU_ID, FOOD_PREPARED, FOOD_SERVED, FOOD_WASTED, RECORDED_BY)
SELECT m.MENU_ID, 90.00, 84.00, 6.00, u.USER_ID
FROM MENU m, USERS u
WHERE m.MENU_DATE = TRUNC(SYSDATE) AND m.MEAL_TYPE_ID = 1 AND u.EMAIL = 'staff@smartmess.edu';

PROMPT Food wastage records seeded.

-- Commit transaction
COMMIT;

PROMPT ============================================================================
PROMPT SmartMess sample data successfully seeded and committed!
PROMPT ============================================================================
