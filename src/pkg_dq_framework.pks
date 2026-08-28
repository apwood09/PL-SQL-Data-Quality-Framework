-- public specification declaring data quality validation rules 
-- AUTHID CURRENT_USER (invoker's rights): dynamic SQL executes with privileges of user running code 
CREATE OR REPLACE PACKAGE pkg_dq_framework AUTHID CURRENT_USER IS 

-- scans column (FIRST_NAME) find and count missing values 
-- EMPLOYYES: table 
-- FIRST_NAME: column 
    PROCEDURE check_nulls (
        EMPLOYEES IN VARCHAR2, 
        FIRST_NAME IN VARCHAR2
    ); 

-- analyze column (EMPLOYEE_ID) check duplicates 
-- EMPLOYEES: table 
-- EMPLOYEE_ID: column, primary key 
    PROCEDURE check_duplicates (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_ID IN VARCHAR2
    ); 

-- validates numeric data counting values that breach defined bound 
-- EMPLOYEES: table 
-- EMPLOYEE_AGE: column, numeric 
-- P_MIN_VALUE: minimum acceptable value allowed in range 
-- P_MAX_VALUE: maximum aceptable value allowed in range 
    PROCEDURE check_range (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_AGE IN VARCHAR2, 
        P_MIN_VALUE IN NUMBER, 
        P_MAX_VALUE IN NUMBER
    ); 

END pkg_dq_framework; 
/