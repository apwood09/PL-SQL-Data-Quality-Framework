-- Quality Assurance (QA) 
-- intentionaly feed bad data -> test alerts & result logging 

SET SERVEROUTPUT ON; 
-- data quality framework tests 
BEGIN 
    -- missing first names
    pkg_dq_framework.check_nulls(
        p_table_name => 'MOCK_EMPLOYEES', 
        p_column_name => 'FIRST_NAME'
    );
    -- duplicate employee id 
    pkg_dq_framework.check_duplicates(
        p_table_name => 'MOCK_EMPLOYEES', 
        p_column_name => 'EMPLOYEE_ID'
    ); 
    -- employee under 18 or over 65
    pkg_dq_framework.check_range(
        p_table_name => 'MOCK_EMPLOYEES', 
        p_column_name => 'EMPLOYEE_AGE', 
        p_min_value => 18, 
        p_max_value => 65
    );
END; 
/

-- verify results -> metadata log table 
-- query audit history to prove framework safelt logged data
SELECT 
    log_id, 
    TO_CHART(run_date, 'YYY-MM-DD HH24:MI:SS') AS test_time, 
    table_name, 
    column_name, 
    check_type, 
    error_count, 
    status
FROM audit_log
ORDER BY run_date DESC; 