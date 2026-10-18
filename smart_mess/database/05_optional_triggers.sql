-- ============================================================================
-- SmartMess: Smart College Mess Food Management System
-- Script: 05_optional_triggers.sql
-- Description: PL/SQL Triggers and Stored Procedures for academic demonstration.
--              Demonstrates row-level triggers (:NEW and :OLD pseudorecords),
--              conditional business rule enforcement, and stored procedures.
-- Target DB: Oracle Database 21c XE / 23ai / 19c Enterprise
-- ============================================================================

SET SERVEROUTPUT ON;
SET FEEDBACK ON;
SET DEFINE OFF;

PROMPT ============================================================================
PROMPT Creating Optional Oracle Triggers and Stored Procedures...
PROMPT ============================================================================

-- ----------------------------------------------------------------------------
-- TRIGGER 1: TRG_COMPLAINT_RESOLVE_TIMESTAMP
-- Type: BEFORE UPDATE ON COMPLAINTS FOR EACH ROW
-- Purpose: Automatically stamps RESOLVED_AT timestamp when status changes
--          to 'RESOLVED', and clears it if reopened.
-- Viva Explanation: Demonstrates state machine tracking in database layer.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_COMPLAINT_RESOLVE_TIMESTAMP
BEFORE UPDATE OF STATUS ON COMPLAINTS
FOR EACH ROW
BEGIN
    IF :NEW.STATUS = 'RESOLVED' AND (:OLD.STATUS IS NULL OR :OLD.STATUS <> 'RESOLVED') THEN
        :NEW.RESOLVED_AT := CURRENT_TIMESTAMP;
    ELSIF :NEW.STATUS <> 'RESOLVED' THEN
        :NEW.RESOLVED_AT := NULL;
    END IF;
END;
/

PROMPT Trigger TRG_COMPLAINT_RESOLVE_TIMESTAMP created.

-- ----------------------------------------------------------------------------
-- TRIGGER 2: TRG_VALIDATE_WASTAGE_QUANTITIES
-- Type: BEFORE INSERT OR UPDATE ON WASTAGE FOR EACH ROW
-- Purpose: Enforces that food wasted and served cannot exceed prepared.
--          Raises Oracle user application error (-20001) if violated.
-- Viva Explanation: Demonstrates RAISE_APPLICATION_ERROR in PL/SQL.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_VALIDATE_WASTAGE_QUANTITIES
BEFORE INSERT OR UPDATE ON WASTAGE
FOR EACH ROW
BEGIN
    IF :NEW.FOOD_PREPARED < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Food prepared cannot be negative.');
    END IF;

    IF :NEW.FOOD_SERVED > :NEW.FOOD_PREPARED THEN
        RAISE_APPLICATION_ERROR(-20002, 'Food served cannot exceed total food prepared.');
    END IF;

    IF :NEW.FOOD_WASTED > :NEW.FOOD_PREPARED THEN
        RAISE_APPLICATION_ERROR(-20003, 'Food wasted cannot exceed total food prepared.');
    END IF;
END;
/

PROMPT Trigger TRG_VALIDATE_WASTAGE_QUANTITIES created.

-- ----------------------------------------------------------------------------
-- PROCEDURE 1: PRC_RECORD_STUDENT_ATTENDANCE
-- Purpose: Stored procedure demonstrating IN parameters and MERGE (UPSERT)
--          operation to safely mark or update meal attendance.
-- Viva Explanation: Demonstrates atomic UPSERT (MERGE INTO) in Oracle SQL.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_RECORD_STUDENT_ATTENDANCE (
    p_user_id   IN NUMBER,
    p_menu_id   IN NUMBER,
    p_status    IN VARCHAR2,
    p_result    OUT VARCHAR2
) AS
BEGIN
    MERGE INTO ATTENDANCE a
    USING (SELECT p_user_id AS u_id, p_menu_id AS m_id FROM dual) src
    ON (a.USER_ID = src.u_id AND a.MENU_ID = src.m_id)
    WHEN MATCHED THEN
        UPDATE SET a.STATUS = p_status, a.MARKED_AT = CURRENT_TIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (USER_ID, MENU_ID, STATUS, MARKED_AT)
        VALUES (p_user_id, p_menu_id, p_status, CURRENT_TIMESTAMP);

    COMMIT;
    p_result := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_result := 'ERROR: ' || SQLERRM;
END;
/

PROMPT Procedure PRC_RECORD_STUDENT_ATTENDANCE created.

-- ----------------------------------------------------------------------------
-- PROCEDURE 2: PRC_MONTHLY_WASTAGE_METRICS
-- Purpose: Demonstrates OUT parameters calculating total metrics for a given month.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_MONTHLY_WASTAGE_METRICS (
    p_year_month       IN  VARCHAR2,
    p_total_prepared   OUT NUMBER,
    p_total_served     OUT NUMBER,
    p_total_wasted     OUT NUMBER,
    p_wastage_percent  OUT NUMBER
) AS
BEGIN
    SELECT 
        NVL(SUM(w.FOOD_PREPARED), 0),
        NVL(SUM(w.FOOD_SERVED), 0),
        NVL(SUM(w.FOOD_WASTED), 0),
        CASE 
            WHEN NVL(SUM(w.FOOD_PREPARED), 0) > 0 
            THEN ROUND((NVL(SUM(w.FOOD_WASTED), 0) / SUM(w.FOOD_PREPARED)) * 100, 2)
            ELSE 0 
        END
    INTO 
        p_total_prepared,
        p_total_served,
        p_total_wasted,
        p_wastage_percent
    FROM WASTAGE w
    JOIN MENU m ON w.MENU_ID = m.MENU_ID
    WHERE TO_CHAR(m.MENU_DATE, 'YYYY-MM') = p_year_month;
END;
/

PROMPT Procedure PRC_MONTHLY_WASTAGE_METRICS created.
PROMPT ============================================================================
PROMPT All triggers and procedures compiled successfully!
PROMPT ============================================================================
