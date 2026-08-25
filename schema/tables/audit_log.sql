/* track the health of the databases overtime */ 
/* data quality testing */

create AUDIT_LOG table (
   log_id INT INDENITY(1,1) PRIMARY KEY, 
   execution_time DATETIME2 NOT NULL DEFAULT GETDATE(), 
   database_name VARCHAR(128) NOT NULL, 
   table_name VARCHAR(128) NOT NULL, 
   column_name VARCHAR(128) NOT NULL, 
   rule_name VARCHAR(100) NOT NULL, 
   error_count INT NOT NULL, 
   status AS (CASE WHEN error_count = 0 THEN 'PASS' ELSE 'FAIL' END),
   additional_notes VARCHAR(500) NULL, 
); 