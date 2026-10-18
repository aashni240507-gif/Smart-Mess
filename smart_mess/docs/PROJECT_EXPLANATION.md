# SmartMess: Smart College Mess Food Management System
## Technical Project Explanation & DBMS / Java Viva Guide

---

## 1. Project Overview & Problem Statement

### The Problem in College Dining Halls
In typical engineering colleges and university hostels:
1. **Food Overproduction & Wastage:** The kitchen prepares food based on guesswork. When students eat outside or skip meals, huge amounts of food are discarded.
2. **Lack of Menu Visibility:** Students often do not know what is being served until they arrive at the mess hall.
3. **Unrecorded Meal Attendance:** No advance headcount exists to estimate daily cooking quantities.
4. **Unheard Student Grievances:** Complaints regarding hygiene or food quality are scribbled on registers and ignored.
5. **No Data-Driven Decisions:** Mess committees lack historical feedback and wastage percentages to optimize catering budgets.

### The SmartMess Solution
**SmartMess** is a lightweight, academic-standard web application developed using **Java Servlets, JSP, JDBC, and Oracle Database 21c**. It digitizes:
* **Menu Schedules:** Daily publication of Breakfast, Lunch, and Dinner.
* **Meal Attendance Headcount:** Students confirm attendance (`PRESENT` or `ABSENT`) in advance, generating an expected headcount for mess chefs.
* **Food Wastage Analytics:** Staff logs food prepared, served, and wasted in kilograms (kg) to track the wastage percentage:
  $$\text{Wastage Percentage} = \frac{\text{Food Wasted (kg)}}{\text{Food Prepared (kg)}} \times 100$$
* **Feedback & Rating System:** Multi-attribute 5-star ratings (Quality, Taste, Cleanliness) to hold mess contractors accountable.
* **Grievance Redressal:** Transparent ticketing system tracking complaints from `PENDING` to `IN_PROGRESS` to `RESOLVED`.

---

## 2. Architecture & Design Pattern (MVC)

SmartMess is designed using the classic **Model-View-Controller (MVC)** architecture without complex enterprise frameworks:

```
[ Browser / Client ]
        │  ▲
        │  │ HTTP (HTML / JSON)
        ▼  │
┌──────────────────────────────────────────────┐
│  CONTROLLERS (Java Servlets)                 │
│  - AuthServlet, DashboardServlet             │
│  - MenuServlet, AttendanceServlet            │
│  - FeedbackServlet, ComplaintServlet         │
│  - WastageServlet, UserServlet, ReportServlet│
└───────┬──────────────────────────────▲───────┘
        │ (Processes Request)          │ (Forwards Model)
        ▼                              │
┌──────────────────────────────┐  ┌────┴─────────────────────────┐
│  DAO LAYER (JDBC)            │  │  VIEWS (JSP & Bootstrap 5)   │
│  - UserDAO, MenuDAO          │  │  - *.jsp pages               │
│  - AttendanceDAO, FeedbackDAO│  │  - JSTL Core tags            │
│  - ComplaintDAO, WastageDAO  │  │  - Chart.js visualizations   │
│  - ReportDAO                 │  └──────────────────────────────┘
└───────┬──────────────────────┘
        │ PreparedStatement / SQL Queries
        ▼
┌──────────────────────────────────────────────┐
│  DATABASE (Oracle 21c XE / XEPDB1)           │
│  - 8 Relational Tables                       │
│  - Constraints, Indexes, Views, Triggers     │
└──────────────────────────────────────────────┘
```

* **Model (`com.smartmess.model`):** Plain Old Java Objects (POJOs) representing domain entities (`User`, `Menu`, `Attendance`, `Feedback`, `Complaint`, `Wastage`, `DashboardSummary`).
* **View (`src/main/webapp/*.jsp`):** Renders clean, responsive HTML using Bootstrap 5, JSTL (`jakarta.tags.core`), and Chart.js.
* **Controller (`com.smartmess.controller`):** Java Servlets handling HTTP requests, performing authorization, invoking DAOs, and forwarding data to JSPs.
* **Data Access Object (`com.smartmess.dao`):** Encapsulates all SQL execution, PreparedStatement binding, and ResultSet mapping.
* **Database (Oracle Database 21c XE):** Relational storage enforcing referential integrity, constraints, sequences, and views.

---

## 3. Package Structure & Responsibilities

| Package | Purpose | Key Classes |
| :--- | :--- | :--- |
| `com.smartmess.model` | Entity data models / Transfer objects | `User`, `Menu`, `Attendance`, `Feedback`, `Complaint`, `Wastage`, `DashboardSummary` |
| `com.smartmess.dao` | JDBC queries & database persistence | `UserDAO`, `MenuDAO`, `AttendanceDAO`, `FeedbackDAO`, `ComplaintDAO`, `WastageDAO`, `ReportDAO` |
| `com.smartmess.controller` | HTTP request routing & presentation logic | `AuthServlet`, `DashboardServlet`, `MenuServlet`, `AttendanceServlet`, `FeedbackServlet`, `ComplaintServlet`, `WastageServlet`, `UserServlet`, `ReportServlet` |
| `com.smartmess.util` | Reusable utilities & security helpers | `DBConnection` (Oracle connection factory), `PasswordUtil` (BCrypt hashing), `ValidationUtil` (XSS sanitization & input validation) |
| `com.smartmess.filter` | Request filtering & authorization | `AuthFilter` (session validation, role permissions) |

---

## 4. End-to-End Request Flow (How a Request Works)

1. **Browser Request:** A student clicks "Mark Present" on the dashboard.
2. **Filter Interception:** `AuthFilter` intercepts the request. It checks `session.getAttribute("user")`. If logged in as `STUDENT`, the request is permitted down the chain.
3. **Servlet Handling:** `AttendanceServlet` receives the HTTP POST request.
   - Extracts parameters: `menuId` and `status = "PRESENT"`.
   - Validates parameters via `ValidationUtil`.
4. **DAO Invocation:** The servlet calls `attendanceDAO.markAttendance(userId, menuId, status)`.
5. **JDBC Execution:** `AttendanceDAO` borrows an active `Connection` from `DBConnection.getConnection()`. It executes an Oracle `MERGE` PreparedStatement.
6. **Oracle Persistence:** Oracle executes the statement, checking foreign keys and unique constraints (`UQ_ATTENDANCE_USER_MENU`).
7. **Response Redirection:** The servlet redirects the browser with a status message: `resp.sendRedirect("/attendance?msg=Attendance marked as PRESENT")`.
8. **JSP Rendering:** The browser issues a GET request to `/attendance`. `AttendanceServlet` retrieves updated records and forwards to `attendance.jsp`.

---

## 5. Database Schema & Relational Design

The database schema is fully normalized into **3NF (Third Normal Form)** across 8 tables:

### Entity Relationship Summary

```
   ┌──────────────┐                  ┌──────────────┐
   │  MEAL_TYPES  │                  │  COMPLAINT_  │
   │              │                  │  CATEGORIES  │
   └──────┬───────┘                  └──────┬───────┘
          │ 1:N                             │ 1:N
          ▼                                 ▼
   ┌──────────────┐       1:N        ┌──────────────┐
   │     MENU     │◄─────────────────┤  COMPLAINTS  ├─────────┐
   └──────┬───────┘                  └──────────────┘         │
          │                                                   │
          ├──────────────┬──────────────┐                     │
          │ 1:N          │ 1:N          │ 1:N                 │ N:1
          ▼              ▼              ▼                     ▼
   ┌──────────────┐┌──────────────┐┌──────────────┐    ┌──────────────┐
   │  ATTENDANCE  ││   FEEDBACK   ││   WASTAGE    ├───►│    USERS     │
   └──────┬───────┘└──────┬───────┘└──────────────┘N:1 └──────────────┘
          │               │                               ▲
          └───────────────┴───────────────────────────────┘
                                     N:1
```

### Table Descriptions & Constraints

1. **`USERS`:**
   - Primary Key: `USER_ID NUMBER GENERATED BY DEFAULT AS IDENTITY`
   - Constraints: `EMAIL UNIQUE`, `ROLE CHECK (ROLE IN ('STUDENT', 'STAFF', 'ADMIN'))`
   - Security: Stores salted **BCrypt** hashes in `PASSWORD_HASH`, never plain text.

2. **`MEAL_TYPES`:**
   - Lookup table: Breakfast, Lunch, Dinner.
   - Ensures consistency and prevents spelling discrepancies.

3. **`MENU`:**
   - Primary Key: `MENU_ID`
   - Foreign Key: `MEAL_TYPE_ID REFERENCES MEAL_TYPES`
   - Unique Constraint: `UQ_MENU_DATE_MEAL (MENU_DATE, MEAL_TYPE_ID)` ensures at most one menu per meal per day.

4. **`ATTENDANCE`:**
   - Primary Key: `ATTENDANCE_ID`
   - Foreign Keys: `USER_ID REFERENCES USERS`, `MENU_ID REFERENCES MENU`
   - Unique Constraint: `UQ_ATTENDANCE_USER_MENU (USER_ID, MENU_ID)` enforces that a student cannot have duplicate attendance rows for the same meal.
   - Check Constraint: `STATUS CHECK (STATUS IN ('PRESENT', 'ABSENT'))`.

5. **`FEEDBACK`:**
   - Primary Key: `FEEDBACK_ID`
   - Ratings: `FOOD_QUALITY`, `TASTE`, `CLEANLINESS` each have `CHECK (rating BETWEEN 1 AND 5)`.

6. **`COMPLAINT_CATEGORIES`:**
   - Lookup table: Food Quality, Cleanliness, Service, Quantity, Other.

7. **`COMPLAINTS`:**
   - Primary Key: `COMPLAINT_ID`
   - Lifecycle Status: `STATUS CHECK (STATUS IN ('PENDING', 'IN_PROGRESS', 'RESOLVED'))`.
   - `RESOLVED_AT` timestamp is recorded when status transitions to `RESOLVED`.

8. **`WASTAGE`:**
   - Records: `FOOD_PREPARED`, `FOOD_SERVED`, `FOOD_WASTED` in kilograms.
   - Constraints:
     - All quantities must be $\ge 0$.
     - `FOOD_SERVED <= FOOD_PREPARED`
     - `FOOD_WASTED <= FOOD_PREPARED`

---

## 6. Key Security Decisions

1. **BCrypt Password Hashing:** Plain-text passwords are never stored. BCrypt automatically generates a cryptographic salt and slow key derivation function (`$2a$10$...`), making offline rainbow table and brute-force attacks infeasible.
2. **Session Authentication & Role Authorization:** `AuthFilter` intercepts every incoming request. Roles (`STUDENT`, `STAFF`, `ADMIN`) are verified on the server side using the authenticated session, preventing privilege escalation.
3. **SQL Injection Prevention:** Every query with user input uses JDBC `PreparedStatement` with bind variables (`?`), ensuring user inputs are treated as data, not executable SQL.
4. **XSS (Cross-Site Scripting) Defense:** User input is sanitized via `ValidationUtil.escapeHtml()`, converting HTML characters (`<`, `>`, `&`, `"`, `'`) to HTML entities before database insertion and rendering.

---

## 7. 20 Likely DBMS & Java Viva Questions and Answers

### Q1: What is the architecture of this project?
**Answer:** It follows the Model-View-Controller (MVC) pattern. Servlets act as Controllers handling HTTP requests, JSPs act as Views rendering HTML, POJO classes represent Models, and DAOs use JDBC to communicate with Oracle Database.

### Q2: Why did you use JDBC PreparedStatement instead of Statement?
**Answer:** Two main reasons:
1. **Security:** `PreparedStatement` uses parameterized queries with bind variables (`?`), completely preventing SQL Injection attacks.
2. **Performance:** Precompiled SQL statements are parsed, compiled, and optimized by the Oracle SQL engine once and can be executed multiple times with different parameters.

### Q3: Why is BCrypt preferred for password storage over MD5 or SHA-256?
**Answer:** MD5 and SHA-256 are fast hash algorithms vulnerable to modern GPU brute-force and rainbow table attacks. BCrypt includes a built-in cryptographic salt and a configurable work factor (iteration count), making it slow and resistant to brute-force cracking.

### Q4: What is 1NF, 2NF, and 3NF, and how is your database normalized?
**Answer:**
* **1NF (First Normal Form):** Each column contains atomic (indivisible) values, and each record is unique. Meal items and student reviews are split into atomic columns rather than comma-separated lists.
* **2NF (Second Normal Form):** It is in 1NF and all non-key attributes are fully functionally dependent on the entire primary key (no partial dependencies).
* **3NF (Third Normal Form):** It is in 2NF and has no transitive dependencies (non-key columns do not depend on other non-key columns). Meal types and complaint categories are factored into separate lookup tables.

### Q5: How do you prevent duplicate attendance records for the same student and meal?
**Answer:** We enforce a database-level composite unique constraint: `CONSTRAINT UQ_ATTENDANCE_USER_MENU UNIQUE (USER_ID, MENU_ID)`. In the Java DAO, we use an atomic Oracle `MERGE INTO` statement (UPSERT) so a second submission safely updates the status instead of throwing an error.

### Q6: What does the Oracle `MERGE` statement do?
**Answer:** `MERGE` (also known as UPSERT) conditionally inserts or updates rows in a single atomic SQL statement. If a row matching the ON clause exists, it executes `UPDATE`; if not found, it executes `INSERT`.

### Q7: What is a Foreign Key constraint and what is `ON DELETE CASCADE`?
**Answer:** A Foreign Key ensures referential integrity between two tables by requiring values to match a Primary Key in the referenced table. `ON DELETE CASCADE` automatically deletes dependent child rows (e.g. attendance records) when the parent row (e.g. user or menu) is deleted.

### Q8: What is the difference between `TRUNC(SYSDATE)` and `SYSDATE` in Oracle?
**Answer:** `SYSDATE` returns the current date and time down to seconds. `TRUNC(SYSDATE)` removes the time component, resetting it to midnight (00:00:00). We use `TRUNC` to compare menu dates with the current calendar day regardless of the time an action is taken.

### Q9: What is the purpose of an Index in Oracle?
**Answer:** An index is an auxiliary data structure (typically a B-Tree) that accelerates data retrieval queries by allowing the database engine to find rows without performing an expensive full table scan. In SmartMess, we created indexes on `MENU(MENU_DATE)`, `ATTENDANCE(USER_ID)`, and `COMPLAINTS(STATUS)`.

### Q10: What is a Database View, and why did you create views in Oracle?
**Answer:** A View is a virtual table defined by a stored SQL query. We created views like `VW_TODAY_MENU`, `VW_ATTENDANCE_SUMMARY`, and `VW_FOOD_WASTAGE_ANALYSIS` to simplify complex multi-table joins, encapsulate business calculations, and improve reusability across dashboards.

### Q11: What is the difference between `HAVING` and `WHERE` clauses in SQL?
**Answer:** The `WHERE` clause filters individual rows *before* any grouping occurs. The `HAVING` clause filters aggregated groups *after* the `GROUP BY` operation has been evaluated. In Query 5, we use `HAVING COUNT(FEEDBACK_ID) > 0` to filter meals with at least one review.

### Q12: What is the difference between `INNER JOIN` and `LEFT JOIN`?
**Answer:**
* `INNER JOIN` returns rows only when there is a match in both tables.
* `LEFT JOIN` returns all rows from the left table, and matched rows from the right table. If there is no match, the right side returns `NULL`. We use `LEFT JOIN` in attendance summaries so meals with zero attendance still appear with a count of 0.

### Q13: How does the Servlet Life Cycle work?
**Answer:**
1. **Loading and Instantiation:** The servlet class is loaded and an instance is created.
2. **Initialization (`init`):** Invoked once when the servlet is first loaded to allocate resources (e.g. instantiating DAOs).
3. **Request Handling (`service` / `doGet` / `doPost`):** Invoked for each HTTP request inside a separate thread.
4. **Destruction (`destroy`):** Invoked once when the application is undeployed or the server shuts down.

### Q14: What is the role of `AuthFilter` in your application?
**Answer:** `AuthFilter` implements `jakarta.servlet.Filter`. It intercepts all HTTP requests before they reach the servlets to verify session state and enforce role-based access control. Students cannot access `/wastage`, `/reports`, or `/users`, and unauthenticated users are redirected to `/login`.

### Q15: How is food wastage percentage calculated? How do you prevent division by zero?
**Answer:**
$$\text{Wastage \%} = \frac{\text{Food Wasted}}{\text{Food Prepared}} \times 100$$
To prevent division by zero when `Food Prepared` is 0, both the Oracle SQL and the Java DAO check `IF (FOOD_PREPARED > 0)` or use `CASE WHEN FOOD_PREPARED > 0 THEN ... ELSE 0 END`.

### Q16: How does Java connect to Oracle Database?
**Answer:** Through JDBC using the Oracle Thin Driver (`oracle.jdbc.OracleDriver`). The driver communicates over TCP/IP directly to Oracle's TNS listener on port 1521 using the JDBC URL format:
`jdbc:oracle:thin:@//localhost:1521/XEPDB1`.

### Q17: What is the difference between an Oracle Pluggable Database (PDB) and a Container Database (CDB)?
**Answer:** Introduced in Oracle 12c, multitenant architecture consists of a root Container Database (`CDB$ROOT`) that can host multiple isolated Pluggable Databases (`PDBs`). In Oracle 21c XE, `XEPDB1` is the user pluggable database where application schemas and tables reside.

### Q18: Why do we use try-with-resources in JDBC?
**Answer:** In Java 7 and later, `Connection`, `PreparedStatement`, and `ResultSet` implement `AutoCloseable`. Using try-with-resources guarantees that database resources are closed automatically when the block finishes, even if an exception occurs, preventing database connection leaks.

### Q19: What is an Oracle Database Trigger?
**Answer:** A trigger is a named PL/SQL block stored in the database that automatically executes (fires) in response to a specific event (e.g., BEFORE/AFTER INSERT, UPDATE, or DELETE on a table). We implemented `TRG_COMPLAINT_RESOLVE_TIMESTAMP` to auto-stamp `RESOLVED_AT` when a complaint is marked `RESOLVED`.

### Q20: What is a Database Transaction, and why is `COMMIT` important?
**Answer:** A transaction is a logical unit of work that satisfies the ACID properties (Atomicity, Consistency, Isolation, Durability). `COMMIT` permanently saves all changes made by the transaction to disk in the Oracle redo logs and datafiles. `ROLLBACK` undoes all changes since the last commit if an error occurs.
