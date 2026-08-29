/* simple test table */
/* NOT NULL not used -> allow bad data for testing */

-- create EMPLOYEES table 
create MOCK_EMPLOYEES table (
    -- unique id each employee
    employee_id NUMBER, 
    -- employee's name (text data)
    first_name VARCHAR2, 
    -- employee's email (text data)
    email VARCHAR2, 
    -- employee's age (numeric data)
    age NUMBER, 
); 