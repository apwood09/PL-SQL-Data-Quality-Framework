-- contains runtime logic for data quality rules
-- dynamic SQL (EXECUTE IMMEDIATE) handle arbitrary table & column inputs at runtime

CREATE OR REPLACE PACKAGE BODY pkg_dq_framework IS 

    PROCEDURE log_result (
        p_table_name IN VARCHAR2, 
        p_column_name IN VARCHAR2, 
        p_check_type IN VARCHAR2, 
        p_error_counts IN NUMBER, 
    ) IS 

    -- operate independentaley for this code block 
    PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
    -- logging action 
    INSERT INTO audit_log (p_table_name, p_column_name, p_check_type, p_error_counts) 
    VALUES (p_table_name, p_column_name, p_check_type, p_error_counts);

    COMMIT; 

EXCEPTION
    WHEN OTHERS THEN
        -- finalize transaction -> internal logging error occurs 
        ROLLBACK;      
    
        -- print logging error ot console 
        DBMS_ASSERT.PUT_LINE('Internal Logging Error: ' || SQLERRM); 
END log_result; 

-- counts records where FIRST_NAME value missing 
    PROCEDURE check_nulls (
        p_table_name IN VARCHAR2, 
        p_column_name IN VARCHAR2
    ) IS 
        v_sql           VARCHAR2(4000); 
        v_defect_count NUMBER := 0; 
    BEGIN 
    -- DBMS_ASSERT: verifies input table & column strings valid db object
        v_sql := ' SELECT COUNT(*) FROM ' || DBMS_ASSERT.ENQUOTE_NAME(p_table_name) ||
            ' WHERE ' || DBMS_ASSERT.ENQUOTE_NAME(p_column_name) || ' IS NULL '; 
        
        -- execute dynamically & store result into v_defect_count 
        EXECUTE IMMEDIATE v_sql INTO v_defect_count; 
        
        -- print summary metrics to db derver output console 
        log_result(p_table_name, p_column_name, 'NULL_CHECK', v_defect_count);  
    END check_nulls; 

-- counts how many unique keys have duplicate EMPLOYEE_ID in table 
    PROCEDURE check_duplicates (
        p_table_name IN VARCHAR2, 
        p_column_name IN VARCHAR2
    ) IS 

        v_sql           VARCHAR2(4000); 
        v_dup_count NUMBER := 0; 
    BEGIN 
    -- inline view query groups by target identifier (EMPLOYEE_ID)
    -- HAVING: filters out groups containing more than 1 occurance 
        v_sql := ' SELECT COUNT(*) FROM (SELECT ' || DBMS_ASSERT.ENQUOTE_NAME(p_column_name) ||
                ' FROM '  || DBMS_ASSERT.ENQUOTE_NAME(p_table_name) || 
                ' GROUP BY ' || DBMS_ASSERT.ENQUOTE_NAME(p_column_name) || ' HAVING COUNT(*) > 1) ';  
        
        -- execute query string dynamically & extract count 
        EXECUTE IMMEDIATE v_sql INTO v_dup_count; 

        -- print execute result summary to console 
         log_result(p_table_name, p_column_name, 'CHECK_DUPLICATES', v_dup_count);
    END check_duplicates; 

-- identifies numeric values outside set boundaries 
    PROCEDURE check_range (
        p_table_name IN VARCHAR2, 
        p_column_name IN VARCHAR2, 
        P_MIN_VALUE IN NUMBER, 
        P_MAX_VALUE IN NUMBER
    ) IS 
        v_sql       VARCHAR2(4000); 
        v_out_of_bounds  NUMBER := 0; 
    BEGIN 
        -- build query: structural concatenation for id & :min/:max literals
        -- prevent hardcoding data boundaries & promotes cursor sharing in library cache
        v_sql := ' SELECT COUNT(*) FROM ' || DBMS_ASSERT.ENQUOTE_NAME(p_table_name) ||
            ' WHERE ' || DBMS_ASSERT.ENQUOTE_NAME(p_column_name) || ' NOT BETWEEN  :min AND :max'; 

        -- run query, mapping dynamically to procedural arguments via USING clause 
        EXECUTE IMMEDIATE v_sql INTO v_out_of_bounds USING p_min_value, p_max_value; 

        -- print result summary indicating final defect count to console 
        log_result(p_table_name, p_column_name, 'CHECK_RANGE', v_out_of_bounds); 
    END check_range;

END pkg_dq_framework; 
/