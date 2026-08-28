-- contains runtime logic for data quality rules
-- dynamic SQL (EXECUTE IMMEDIATE) handle arbitrary table & column inputs at runtime

CREATE OR REPLACE PACKAGE BODY pkg_dq_framework IS 

-- counts records where FIRST_NAME value missing 
    PROCEDURE check_nulls (
        EMPLOYEES IN VARCHAR2, 
        FIRST_NAME IN VARCHAR2
    ) IS 
        v_sql           VARCHAR2(4000); 
        v_defect_count NUMBER := 0; 
    BEGIN 
    -- DBMS_ASSERT: verifies input table & column strings valid db object
        v_sql := ' SELECT COUNT(*) FROM ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEES) ||
            ' WHERE ' || DBMS_ASSERT.ENQUOTE_NAME(FIRST_NAME) || ' IS NULL '; 
        
        -- execute dynamically & store result into v_defect_count 
        EXECUTE IMMEDIATE v_sql INTO v_defect_count; 
        
        -- print summary metrics to db derver output console 
        DBMS_OUTPUT.PUT_LINE('Null check on ' || EMPLOYEES || '.' || FIRST_NAME || ': ' || v_defect_count || ' errors.'); 
    END check_nulls; 

-- counts how many unique keys have duplicate EMPLOYEE_ID in table 
    PROCEDURE check_duplicates (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_ID IN VARCHAR2
    ) IS 

        v_sql           VARCHAR2(4000); 
        v_dup_count NUMBER := 0; 
    BEGIN 
    -- inline view query groups by target identifier (EMPLOYEE_ID)
    -- HAVING: filters out groups containing more than 1 occurance 
        v_sql := ' SELECT COUNT(*) FROM (SELECT ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEE_ID) ||
                ' FROM '  || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEES) || 
                ' GROUP BY ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEE_ID) || ' HAVING COUNT(*) > 1) ';  
        
        -- execute query string dynamically & extract count 
        EXECUTE IMMEDIATE v_sql INTO v_dup_count; 

        -- print execute result summary to console 
        DBMS_OUTPUT.PUT_LINE('Duplicate check on ' || EMPLOYEES || '.' || EMPLOYEE_ID || ': ' || v_dup_count || ' duplicates.'); 
    END check_duplicates; 

-- identifies numeric values outside set boundaries 
    PROCEDURE check_range (
        EMPLOYEES IN VARCHAR2, 
        EMPLOYEE_AGE IN VARCHAR2, 
        P_MIN_VALUE IN NUMBER, 
        P_MAX_VALUE IN NUMBER
    ) IS 
        v_sql       VARCHAR2(4000); 
        v_out_of_bounds  NUMBER := 0; 
    BEGIN 
        -- build query: structural concatenation for id & :min/:max literals
        -- prevent hardcoding data boundaries & promotes cursor sharing in library cache
        v_sql := ' SELECT COUNT(*) FROM ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEES) ||
            ' WHERE ' || DBMS_ASSERT.ENQUOTE_NAME(EMPLOYEE_AGE) || ' NOT BETWEEN  :min AND :max'; 

        -- run query, mapping dynamically to procedural arguments via USING clause 
        EXECUTE IMMEDIATE v_sql INTO v_out_of_bounds USING p_min_value, p_max_value; 

        -- print result summary indicating final defect count to console 
        DBMS_OUTPUT.PUT_LINE('Range check on ' || EMPLOYEES || '.' || EMPLOYEE_AGE || ': ' || v_out_of_bounds || ' defetcs.');  
    END check_range;

END pkg_dq_framework; 
/