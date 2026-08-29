/* mix of "good data" & "bad data" */
/* test framework's limits */

-- 1. NULL first_name -> test NULL count 
INSERT INTO MOCK_EMPLOYEES (employee_id, first_name, email, age)
VALUES (4, NULL, '', 30); 

-- 2. age -27 -> test range validation 
INSERT INTO MOCK_EMPLOYEES (employee_id, first_name, email, age)
VALUES (2, 'Sarah', '', -27); 

-- 3. employee_id 4 -> test duplicate key 
INSERT INTO MOCK_EMPLOYEES (employee_id, first_name, email, age)
VALUES (4, 'Jaine', '', 20); 

-- save all three inserts permanetly to db 
COMMIT; 