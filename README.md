# PL-SQL-Data-Quality-Framework

## 📋 Project Overview 
Build reusable database procedures to check data integrity. Contains a production-grade, reusable **Data Quality. The framework dynamically evaluates data assets for risk.

### ⚙️ Core Capabilities Architecture 
1. **Dynamic Evaluation Engine:** Oracle Dynamic SQL ('EXECUTE IMEDIATE') combined with sanitization policies ('DBMS_ASSERT') to programmatically assess structural metadata attributes without hardcoding object configuration. 
2. **Transactional Logging Pipiline:** Implements private logger blocks isolated via 'PRAGMA AUTONOMOUS_TRANSACTION', ensures operational logs are commited safely, even if adjacent main pipelines suffer a rollback crash. 
3. **Core Testing Dimensions:** 
    * **Null Value Scanner:** scans data parameters to locate and count fields containing missing values. 
    * **Duplicate Constraint Identifier:** groups logical primary identifiers using programmatic aggregations to detect semantic duplicates. 
    * **Range Compliance Auditor:** Validates numerical ranges against safe thresholds utilizing efficient performance bind variables ('USING'). 

---

## 🗄️ Respiratory File Tree 
```text
PL-SQL-Data-Quality-Framework/
├── README.md                   # project overview, docker setup, & usage instructions 
├── schema/
|   ├── tables 
|   |   ├── audit_log.sql       # centralized metadata audit log table 
|   |   └── mock_source.sql     # test schema (MOCK_EMPLOYEES table)
|   └── mock_data.sql           # insertion scripts loaded with intentional structure defects
├── src/ 
|   ├── pkg_dq_frameworks.pks   # package specification (declare public API interfaces)
|   └── pkg_dq_frameworks.pkb   # package body (dynamic queries & autonomous logs)
└── tests/ 
    └── run_tests.sql           # automated QA verification test block script
```

---

## 🐳 Docker Setup (Environment Provisioning)

Follow below steps to run a containerized **Oracle 23ai DB engine** directly on your personal computer (Mac or Windows). 

### 1. Download Docker Desktop 
download & install the visual client runtime matching your computer's chip architecture: 
* **Download Client Tool:** [Docker Desktop Official Installer](https://docker.com)
* Run installer, launch app, & wait for the status indicator icon to turn **green** ("Engine Running). 

### 2. Wipe Previous Refrences 
Avoid container name collisions, run this cleanup command in your terminal: 
```bash
docker rm -f oracle23ai
```

### 3. Spin Up Database Container 
Run this execution block to launch the db & securely map your current folder respiratory path into the workspace filesystem of the container: 

```bash
docker run -d --name oracle23ai -p 1521:1521 -e ORACLE_PWD=YourSecurePassword123 -v "$(pwd)":/workspace ://oracle.com
```

### 4. Verify Boot Completion 
DB engine takes about 2 minutes to initialize metadata files. Monitor the boot status logs using:
```bash
docker logs -f oracle23ai
```
Wait until the consile logs explicitly displays **`DATABASE IS READY TO USE!`** Once seen, press `Ctrl + C` to exit log-viewing mode safely. 

---

## 👟 Step-by-step Code Execution

To bypass local clipbaord line-mashing anomalies or operating system permissions blocks, utilize this foolproof **Terminal Straming Injection**. Copy & paste directly into your terminal to deploy, build, compile & run the pipeline end-to-end: 

```bash
docker exec -i oracle23ai sqlplus -s system/YourSecurePassword123@FREEPDB1 << 'EOF'
SET FEEDBACK OFF;
SET HEADING ON;
SET PAGESIZE 50;
SET LINESIZE 120;
SET SERVEROUTPUT ON;

PROMPT Deploying Structural Database Tables...
DROP TABLE audit_log CASCADE CONSTRAINTS;
DROP TABLE mock_employees CASCADE CONSTRAINTS;

CREATE TABLE audit_log (
    log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    run_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    table_name  VARCHAR2(100),
    column_name VARCHAR2(100),
    check_type  VARCHAR2(50),
    error_count NUMBER,
    status      VARCHAR2(10),
    log_message VARCHAR2(4000)
);

CREATE TABLE mock_employees (
    employee_id NUMBER,
    first_name  VARCHAR2(100),
    age         NUMBER
);

PROMPT Inserting Intentional Semantic Defects...
INSERT INTO mock_employees VALUES (101, 'Alice', 30);
INSERT INTO mock_employees VALUES (102, NULL, 25);
INSERT INTO mock_employees VALUES (101, 'Bob', 45);
INSERT INTO mock_employees VALUES (103, 'Charlie', -5);
COMMIT;

PROMPT Compiling Package Specification Interface...
CREATE OR REPLACE PACKAGE pkg_dq_framework AS
    PROCEDURE check_nulls(t IN VARCHAR2, c IN VARCHAR2);
    PROCEDURE check_duplicates(t IN VARCHAR2, k IN VARCHAR2);
    PROCEDURE check_range(t IN VARCHAR2, c IN VARCHAR2, mn IN NUMBER, mx IN NUMBER);
END pkg_dq_framework;
/

PROMPT Compiling Logic Package Body and Autonomous Logger...
CREATE OR REPLACE PACKAGE BODY pkg_dq_framework IS 
    PROCEDURE log_result(t IN VARCHAR2, c IN VARCHAR2, r IN VARCHAR2, e IN NUMBER, s IN VARCHAR2, m IN VARCHAR2) IS 
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN 
        INSERT INTO audit_log (table_name, column_name, check_type, error_count, status, log_message) 
        VALUES (UPPER(t), UPPER(c), UPPER(r), e, UPPER(s), m);
        COMMIT;
    EXCEPTION WHEN OTHERS THEN ROLLBACK;
    END log_result;

    PROCEDURE check_nulls(t IN VARCHAR2, c IN VARCHAR2) IS 
        v VARCHAR2(4000); cnt NUMBER := 0; 
    BEGIN 
        v := 'SELECT COUNT(*) FROM '||DBMS_ASSERT.ENQUOTE_NAME(t)||' WHERE '||DBMS_ASSERT.ENQUOTE_NAME(c)||' IS NULL'; 
        EXECUTE IMMEDIATE v INTO cnt; 
        IF cnt = 0 THEN log_result(t, c, 'NULL_CHECK', cnt, 'PASS', 'Clean');
        ELSE log_result(t, c, 'NULL_CHECK', cnt, 'FAIL', 'Flaws'); END IF;
    END check_nulls; 

    PROCEDURE check_duplicates(t IN VARCHAR2, k IN VARCHAR2) IS 
        v VARCHAR2(4000); cnt NUMBER := 0; 
    BEGIN 
        v := 'SELECT COUNT(*) FROM (SELECT '||DBMS_ASSERT.ENQUOTE_NAME(k)||' FROM '||DBMS_ASSERT.ENQUOTE_NAME(t)||' GROUP BY '||DBMS_ASSERT.ENQUOTE_NAME(k)||' HAVING COUNT(*) > 1)'; 
        EXECUTE IMMEDIATE v INTO cnt; 
        IF cnt = 0 THEN log_result(t, k, 'DUP_CHECK', cnt, 'PASS', 'Clean');
        ELSE log_result(t, k, 'DUP_CHECK', cnt, 'FAIL', 'Flaws'); END IF;
    END check_duplicates; 

    PROCEDURE check_range(t IN VARCHAR2, c IN VARCHAR2, mn IN NUMBER, mx IN NUMBER) IS 
        v VARCHAR2(4000); cnt NUMBER := 0; 
    BEGIN 
        v := 'SELECT COUNT(*) FROM '||DBMS_ASSERT.ENQUOTE_NAME(t)||' WHERE '||DBMS_ASSERT.ENQUOTE_NAME(c)||' NOT BETWEEN :1 AND :2'; 
        EXECUTE IMMEDIATE v INTO cnt USING mn, mx; 
        IF cnt = 0 THEN log_result(t, c, 'RANGE_CHECK', cnt, 'PASS', 'Clean');
        ELSE log_result(t, c, 'RANGE_CHECK', cnt, 'FAIL', 'Flaws'); END IF;
    END check_range;
END pkg_dq_framework;
/

PROMPT Executing Automated Verification Test Block Suite...
BEGIN 
    pkg_dq_framework.check_nulls('MOCK_EMPLOYEES', 'FIRST_NAME');
    pkg_dq_framework.check_duplicates('MOCK_EMPLOYEES', 'EMPLOYEE_ID');
    pkg_dq_framework.check_range('MOCK_EMPLOYEES', 'AGE', 18, 65);
END;
/

PROMPT Fetching Centralized Log Results...
COLUMN table_name FORMAT A16;
COLUMN column_name FORMAT A14;
COLUMN check_type FORMAT A12;
COLUMN status FORMAT A8;

SELECT table_name, column_name, check_type, error_count, status FROM audit_log;
EOF
```

---

## 📊 Verification & Test Result Output 
Running stream sequence command above, terminal will instantly complete the automated database processing. It will print out a structured data table gridd view confirming your code engine intercepted every data quality issue: 

```text
TABLE_NAME       COLUMN_NAME    CHECK_TYPE   ERROR_COUNT STATUS  
---------------- -------------- ------------ ----------- --------
MOCK_EMPLOYEES   FIRST_NAME     NULL_CHECK             1 FAIL    
MOCK_EMPLOYEES   EMPLOYEE_ID    DUP_CHECK              1 FAIL    
MOCK_EMPLOYEES   AGE            RANGE_CHECK            1 FAIL  
```

--- 

## 🧽 Teardown & Environment Cleanup 

Safely stop local db environment & recover your system's RAM?CPU resources via your terminall, execute the commands below: 

### 1. Stop the DB Container 
Safely stops all running db transactions inside the isolated architecture without deleting your project configuration parameters: 
```bash
docker stop oracle23ai
```

### 2. Kill the Docker Desktop Application Process 
Close the core desktop engine completely and reclaim full computer memory space, run the command matching your operating system: 

* **For macOS (zsh / bash):**
  ```bash
  osascript -e 'quit app "Docker"'
  ```
* **For Windows (PowerShell / Command Prompt):**
  ```bash
  taskkill /F /IM "Docker Desktop.exe"
  ```

  ### 3. Verify Stopped Status 
  Confirm that your backgrounbd daemons are fully inactive, execute: 
  ```bash
    docker ps
  ```