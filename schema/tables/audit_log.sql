/* track the health of the databases overtime */ 
/* data quality testing */

create AUDIT_LOG table (
   -- auto incrments by 1, unique id each log entry
   log_id INT INDENITY(1,1) PRIMARY KEY, 
   -- timestamp: when audit execution occured, default current date & time 
   execution_time DATETIME2 NOT NULL DEFAULT GETDATE(), 
   -- db name being audited 
   database_name VARCHAR(128) NOT NULL, 
   -- specific table name being audited 
   table_name VARCHAR(128) NOT NULL,
   -- specific column name being audited  
   column_name VARCHAR(128) NOT NULL, 
   -- name or description validation rule applied
   rule_name VARCHAR(100) NOT NULL, 
   -- number errors detected during rule_execution
   error_count INT NOT NULL, 
   -- computed column auto returns 'PASS' errors = 0, otherwise 'FAIL'
   status AS (CASE WHEN error_count = 0 THEN 'PASS' ELSE 'FAIL' END),
   -- extra details or context regarding audit execution 
   additional_notes VARCHAR(500) NULL, 
); 