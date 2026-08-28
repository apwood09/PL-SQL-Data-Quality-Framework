CREATE OR REPLACE PACKAGE BODY pkg_dq_framework IS 

    PROCEDURE check_nulls (
        EMPLOYEES IN VARCHAR2, 
        FIRST_NAME IN VARCHAR2
    ) IS 
        v_sql           VARCHAR2(4000); 
        v_defect_count NUMBER := 0; 
    BEGIN 
        v_sql := ' SELECT COUNT(*) FROM ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEES) ||
            ' WHERE ' || DBMS_ASSERT.ENQUOTE_NAME(FIRST_NAME) || ' IS NULL '; 
        
        EXECUTE IMMEDIATE v_sql INTO v_defect_count; 
        
        DBMS_OUTPUT.PUT_LINE('Null check on ' || EMPLOYEES || '.' || FIRST_NAME || ': ' || v_defect_count || ' errors.'); 
    END check_nulls; 

    PROCEDURE check_duplicates (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_ID IN VARCHAR2
    ) IS 

        v_sql           VARCHAR2(4000); 
        v_dup_count NUMBER := 0; 
    BEGIN 
        v_sql := ' SELECT COUNT(*) FROM (SELECT ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEE_ID) ||
                ' FROM '  || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEES) || 
                ' GROUP BY ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEE_ID) || ' HAVING COUNT(*) > 1) ';  
        
        EXECUTE IMMEDIATE v_sql INTO v_dup_count; 

        DBMS_OUTPUT.PUT_LINE('Duplicate check on ' || EMPLOYEES || '.' || EMPLOYEE_ID || ': ' || v_dup_count || ' duplicates.'); 
    END check_duplicates; 

    PROCEDURE check_range (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_AGE IN VARCHAR2, 
        P_MIN_VALUE IN NUMBER, 
        P_MAX_VALUE IN NUMBER
    ) IS 
        v_sql       VARCHAR2(4000); 
        v_out_of_bounds  NUMBER := 0; 
    BEGIN 

        v_sql := ' SELECT COUNT(*) FROM ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEES) ||
            ' WHERE ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEE_AGE) || ' NOT BETWEEN  :min AND :max'; 

        EXECUTE IMMEDIATE v_sql INTO v_out_of_bounds USING p_min_value, p_max_value; 

        DBMS_OUTPUT.PUT_LINE('Range check on ' || EMPLOYEES || '.' || EMPLOYEE_AGE || ': ' || v_out_of_bounds || ' defetcs.');  
    END check_range;

END pkg_dq_framework; 
/