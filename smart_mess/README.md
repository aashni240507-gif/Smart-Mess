# SmartMess — Smart College Mess Food Management System
### A Complete Java Servlets + Oracle DBMS Academic Project
SmartMess is a production-grade, college-level web application designed to digitize daily mess operations, meal attendance forecasting, student food feedback, grievance handling, and kitchen food wastage tracking.
Built with **Java 17/21, Jakarta Servlets & JSP, JDBC, Apache Tomcat 10.1, and Oracle Database 21c XE**.
---
## 📑 Table of Contents
1. [Technology Stack](#1-technology-stack)
2. [Prerequisites & System Requirements](#2-prerequisites--system-requirements)
3. [Oracle Database Setup (SQL*Plus)](#3-oracle-database-setup-sqlplus)
4. [Database Scripts Execution Order](#4-database-scripts-execution-order)
5. [Configuring Database Credentials](#5-configuring-database-credentials)
6. [Building the Project with Maven](#6-building-the-project-with-maven)
7. [Deploying & Running on Apache Tomcat 10.1](#7-deploying--running-on-apache-tomcat-101)
8. [Demo Login Credentials](#8-demo-login-credentials)
9. [Feature Walkthrough by Role](#9-feature-walkthrough-by-role)
10. [Troubleshooting Guide](#10-troubleshooting-guide)
11. [Project Structure](#11-project-structure)
---
## 1. Technology Stack
* **Backend:** Java 17+ (JDK 21 LTS verified), Jakarta Servlets 6.0 (`jakarta.servlet.*`), Jakarta Pages (JSP) 3.1, JSTL 3.0.
* **Database Access:** Plain Java Database Connectivity (JDBC) with `PreparedStatement` and Oracle Thin Driver (`ojdbc11`).
* **Database:** Oracle Database 21c XE / 23ai Free (Pluggable Database: `XEPDB1`, Port: `1521`).
* **Security:** BCrypt password hashing (`jbcrypt`) with unique salts.
* **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5.3, Bootstrap Icons, Chart.js.
* **Build System:** Apache Maven (includes Windows wrapper `mvnw.cmd`).
* **Web Server:** Apache Tomcat 10.1 (Jakarta EE 10 compatible).
> **Note:** Spring Boot, Hibernate, JPA, or MySQL are deliberately not used. The architecture uses pure Java Servlets, JSP, JDBC, and Oracle Database for academic clarity and viva defense.
---
## 2. Prerequisites & System Requirements
### Step 2.1: Verify Java Installation
Open PowerShell or Command Prompt:
```powershell
java -version
```
*Required: Java 17 or Java 21.*
### Step 2.2: Verify Maven
This repository includes a pre-configured Windows wrapper:
```powershell
.\mvnw.cmd -v
```
If Maven is installed globally on your machine, `mvn -version` also works.
### Step 2.3: Verify Oracle Database & SQL*Plus
Ensure the Oracle Database service and listener are running:
```powershell
# Check Oracle Windows Services
Get-Service *oracle*
```
You should see `OracleServiceXE` and `OracleOraDB21Home1TNSListener` in the **Running** state.
Check SQL*Plus client:
```powershell
sqlplus -V
```
> **Important:** Oracle SQL*Plus is only a command-line client. You must also have the Oracle Database service (`OracleServiceXE`) actively running.
---
## 3. Oracle Database Setup (SQL*Plus)
In Oracle 21c XE and 23ai Free, application data resides inside the **Pluggable Database (`XEPDB1`)**, not the root container (`CDB$ROOT`).
### Step 3.1: Create the Application User and Tablespace
Connect to Oracle as `SYSDBA`:
```powershell
sqlplus / as sysdba
```
Inside SQL*Plus, run:
```sql
-- Switch to the pluggable database
ALTER SESSION SET CONTAINER = XEPDB1;
-- Create the smartmess schema user
CREATE USER smartmess IDENTIFIED BY smartmess123 
    DEFAULT TABLESPACE users 
    TEMPORARY TABLESPACE temp 
    QUOTA UNLIMITED ON users;
-- Grant required permissions
GRANT CONNECT, RESOURCE, CREATE VIEW TO smartmess;
EXIT;
```
---
## 4. Database Scripts Execution Order
All SQL scripts are in the `database/` folder and must be executed in order:
Connect to the `smartmess` schema:
```powershell
sqlplus smartmess/smartmess123@//localhost:1521/XEPDB1
```
Run each script in order:
```sql
-- 1. Create all 8 tables, sequences, identity columns, checks, and foreign keys
database\01_create_tables.sql
-- 2. Seed initial lookup data, meal schedules, BCrypt hashed users, and logs
database\02_insert_sample_data.sql
-- 3. Create views for today's menu, attendance summaries, and wastage analysis
database\03_views_and_reports.sql
-- 4. Run the 10 demo queries for DBMS viva demonstration
database\04_demo_queries.sql
-- 5. Compile optional triggers (auto-resolve timestamps and constraints)
database\05_optional_triggers.sql
EXIT;
```
---
## 5. Configuring Database Credentials
The application reads database settings from:
`src/main/resources/db.properties`
```properties
db.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
db.username=smartmess
db.password=smartmess123
db.driver=oracle.jdbc.OracleDriver
```
If your Oracle installation uses a different port, hostname, or SID (e.g. `xe` for Oracle 11g/18c), update the `db.url` in this file or configure environment variables:
* `SMARTMESS_DB_URL`
* `SMARTMESS_DB_USER`
* `SMARTMESS_DB_PASSWORD`
---
## 6. Building the Project with Maven
In the project root folder (`smart_mess`):
```powershell
# Clean, compile, and package into target/smartmess.war
.\mvnw.cmd clean package
```
Upon successful build, you will see `BUILD SUCCESS` and the generated WAR file:
`target\smartmess.war`
---
## 7. Deploying & Running on Apache Tomcat 10.1
Tomcat 10.1 uses Jakarta EE 10 (`jakarta.servlet.*`).
### Step 7.1: Deploy the WAR File
Copy `target\smartmess.war` into Tomcat's `webapps` folder:
```powershell
Copy-Item "target\smartmess.war" -Destination "Env: Userprofile\apache-tomcat-10.1.24\webapps\smartmess.war" -Force
```
### Step 7.2: Start Tomcat
```powershell
Env: Java Home = "C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot"
Env: Catalina Home = "Env: Userprofile\apache-tomcat-10.1.24"
& "Env: Catalina Home\bin\catalina.bat" run
```
### Step 7.3: Open in Browser
Open your browser and visit:
👉 **http://localhost:8080/smartmess/**
---
## 8. Demo Login Credentials
The sample seed data creates pre-configured accounts with BCrypt-hashed passwords:
| Role | Email Address | Plain Password | Description |
| :--- | :--- | :--- | :--- |
| **ADMIN** | `admin@smartmess.edu` | `admin123` | System Administrator (Full metrics, User Management, Reports) |
| **STAFF** | `staff@smartmess.edu` | `staff123` | Mess Chef Raman (Menu CRUD, Wastage Logging, Grievance Updates) |
| **STUDENT** | `student@smartmess.edu` | `student123` | Student Aarav Sharma (Mark Attendance, Rate Food, File Tickets) |
| **STUDENT** | `rahul@smartmess.edu` | `student123` | Student Rahul Verma (Kaveri Hostel) |
| **STUDENT** | `priya@smartmess.edu` | `student123` | Student Priya Nair (Ganga Hostel) |
*The login page also provides 1-Click Autofill buttons for each demo role.*
---
## 9. Feature Walkthrough by Role
### A. Student Features
* **Today's Menu Schedule:** View Breakfast, Lunch, and Dinner menus hot off the kitchen.
* **1-Click Attendance:** Click **"I'll Eat"** (`PRESENT`) or **"Skip"** (`ABSENT`) to reserve your plate.
* **Attendance History:** Review past meal records and attendance percentage.
* **Star Ratings & Feedback:** Submit 1 to 5 star ratings on Food Quality, Taste, and Cleanliness.
* **File Grievances:** Submit categorized mess complaints and monitor status (`PENDING` -> `IN_PROGRESS` -> `RESOLVED`).
### B. Mess Staff Features
* **Menu Management:** Add, edit, or remove daily meal schedules. Date filtering supported.
* **Kitchen Food Wastage Logging:** Log food prepared, served, and wasted in kg. Live percentage calculation.
* **Attendance Headcounts:** View expected student counts before cooking.
* **Grievance Resolution:** Review student issues and mark them in-progress or resolved.
### C. Administrator Features
* **Live System Metrics:** Real-time metrics fetched from Oracle (Diners, Wastage, Ratings, Menus).
* **Chart.js Visualizations:** Interactive daily food wastage bars and attendance doughnut charts.
* **User Management:** Create new mess staff accounts with secure BCrypt hashes, inspect students, and update roles.
* **Reports Export:** Printable operational audit reports and trends.
---
## 10. Troubleshooting Guide
| Issue | Likely Cause | Solution |
| :--- | :--- | :--- |
| `ORA-12541: TNS:no listener` | Oracle TNS Listener service is stopped | Start service in PowerShell: `Start-Service *TNSListener*` |
| `ORA-01017: invalid username/password` | Incorrect credentials in `db.properties` | Verify user `smartmess` and password `smartmess123` in SQL*Plus |
| `ORA-28000: the account is locked` | Oracle account locked | Run as SYSDBA: `ALTER USER smartmess ACCOUNT UNLOCK;` |
| `HTTP 404 on /smartmess/` | WAR not deployed or named differently | Ensure WAR file is named `smartmess.war` inside Tomcat's `webapps/` folder |
| `HTTP 403 Forbidden` | Logged-in role lacks permission | Students cannot access `/users` or `/wastage`. Sign in with Staff or Admin account. |
| `mvn not recognized` | Maven path not loaded in shell | Use the included wrapper: `.\mvnw.cmd clean package` |
---
## 11. Project Structure
```
smart_mess/
├── pom.xml                               # Maven project configuration (Jakarta EE 10, Oracle JDBC)
├── mvnw.cmd                              # Windows Maven wrapper
├── README.md                             # Complete setup & deployment guide
├── .gitignore                            # Git ignore rules
│
├── database/                             # Oracle SQL*Plus Scripts
│   ├── 01_create_tables.sql              # Table DDL, constraints, identity columns, indexes
│   ├── 02_insert_sample_data.sql          # Seed data with BCrypt hashes
│   ├── 03_views_and_reports.sql          # Database views (VW_TODAY_MENU, VW_WASTAGE_ANALYSIS)
│   ├── 04_demo_queries.sql               # 10+ explained queries for DBMS viva
│   └── 05_optional_triggers.sql          # PL/SQL triggers and stored procedures
│
├── docs/
│   └── PROJECT_EXPLANATION.md            # Comprehensive viva preparation guide (20 Q&As)
│
├── src/main/resources/
│   ├── db.properties                     # Active Oracle connection credentials
│   └── db.properties.example             # Configuration template
│
├── src/main/java/com/smartmess/
│   ├── model/                            # Entity Data Models
│   │   ├── User.java
│   │   ├── MealType.java
│   │   ├── Menu.java
│   │   ├── Attendance.java
│   │   ├── Feedback.java
│   │   ├── ComplaintCategory.java
│   │   ├── Complaint.java
│   │   ├── Wastage.java
│   │   └── DashboardSummary.java
│   ├── dao/                              # Data Access Objects (JDBC)
│   │   ├── UserDAO.java
│   │   ├── MealTypeDAO.java
│   │   ├── MenuDAO.java
│   │   ├── AttendanceDAO.java
│   │   ├── FeedbackDAO.java
│   │   ├── ComplaintCategoryDAO.java
│   │   ├── ComplaintDAO.java
│   │   ├── WastageDAO.java
│   │   └── ReportDAO.java
│   ├── util/                             # Utility Helpers
│   │   ├── DBConnection.java
│   │   ├── PasswordUtil.java
│   │   └── ValidationUtil.java
│   ├── filter/                           # Security Filters
│   │   └── AuthFilter.java
│   └── controller/                       # Jakarta Servlets
│       ├── AuthServlet.java
│       ├── DashboardServlet.java
│       ├── MenuServlet.java
│       ├── AttendanceServlet.java
│       ├── FeedbackServlet.java
│       ├── ComplaintServlet.java
│       ├── WastageServlet.java
│       ├── UserServlet.java
│       └── ReportServlet.java
│
└── src/main/webapp/                      # Frontend Views & Assets
    ├── index.jsp                         # Landing homepage with demo links
    ├── login.jsp                         # Sign in with 1-click autofill
    ├── register.jsp                      # Student registration
    ├── student-dashboard.jsp             # Student portal
    ├── staff-dashboard.jsp               # Kitchen staff portal
    ├── admin-dashboard.jsp               # Executive admin portal
    ├── menus.jsp                         # Daily menus management
    ├── attendance.jsp                    # Attendance tracking
    ├── feedback.jsp                      # 5-star ratings & reviews
    ├── complaints.jsp                    # Grievance lifecycle tracking
    ├── wastage.jsp                       # Food wastage logging (kg)
    ├── reports.jsp                       # Analytical reports & Chart.js
    ├── users.jsp                         # Admin user directory & staff provisioning
    ├── includes/
    │   ├── header.jsp                    # Common HTML head, Bootstrap, Chart.js
    │   ├── sidebar.jsp                   # Dark navy sidebar navigation
    │   └── footer.jsp                    # Scripts & closing tags
    ├── assets/
    │   ├── css/style.css                 # Custom navy & emerald theme
    │   └── js/app.js                     # Interactive ratings, calculations, charts
    └── WEB-INF/
        └── web.xml                       # Deployment descriptor
```
---
12. Contributing
Contributions that improve SmartMess are welcome. To keep changes easy to review:
1. Create a branch for your change instead of working directly on main.
2. Make one focused improvement, such as fixing a bug, improving validation, or updating documentation.
3. Test the affected feature locally before submitting the change.
4. Do not commit real database passwords, personal data, or other secrets.
5. Open a pull request describing what changed and how it was tested.
Suggested pre-submission checks
From the project root, run:
.\\mvnw.cmd clean package
Confirm that the build succeeds, and manually test any affected page or workflow with the required Oracle Database and Tomcat services running.