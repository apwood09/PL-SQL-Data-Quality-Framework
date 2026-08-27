CREATE [OR REPLACE] PACKAGE pkg_dq_framework
[AUTHID {CURRENT_USER | DEFINER}] 
{IS | AS}

    PROCEDURE check_nulls (
        EMPLOYEES IN VARCHAR2, 
        FIRST_NAME IN VARCHAR2
    ); 

    PROCEDURE check_duplicates (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_ID IN VARCHAR2
    ); 

    PROCEDURE check_range (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_AGE IN VARCHAR2, 
        P_MIN_VALUE IN NUMBER, 
        P_MAX_VALUE IN NUMBER
    ); 

END pkg_dq_framework; 
/