/* simple test table */
/* NOT NULL not used -> allow bad data for testing */

create EMPLOYEES table (
    employee_id NUMBER, 
    first_name VARCHAR2, 
    email VARCHAR2, 
    age NUMBER, 
); 