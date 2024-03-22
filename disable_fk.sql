REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTEX
REM    21/06/2005 
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Disable FK constraints reference to specified table. Useful for
REM    TRUNCATE operation. Then constraints will be enable back.
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM   SQL> set serveroutput on
REM   SQL> @disable_fk gxp_business_units
REM   
REM   Table created.
REM   
REM   Constraint TRT_BUN_FK was disabled in table DSS_TRAN_TARIFS
REM   Constraint GAR_BUN_FK was disabled in table GXP_ADMIN_USERS
REM   Constraint GAN_BUN_FK was disabled in table GXP_ADMIN_USER_BUN
REM   
REM   PL/SQL procedure successfully completed.
REM   
REM   
REM   Keys was disabled. Press <ENTER> to enable it
REM   
REM   ...
REM ------------------------------------------------------------------------ 

CREATE GLOBAL TEMPORARY TABLE kozyr$fkd
(table_name VARCHAR2(30), constraint_name VARCHAR2(30))
ON COMMIT PRESERVE ROWS;

DECLARE
   CURSOR c1 IS
      SELECT f.table_name, f.constraint_name, f.status
      FROM user_constraints p, user_constraints f
      WHERE p.constraint_name = f.r_constraint_name
      AND p.table_name = UPPER('&1')
      AND f.status = 'ENABLED';
BEGIN
   FOR j IN c1 LOOP
     INSERT INTO kozyr$fkd(table_name, constraint_name) VALUES(j.table_name, j.constraint_name);   
     EXECUTE IMMEDIATE 'ALTER TABLE ' || j.table_name || ' DISABLE CONSTRAINT ' || j.constraint_name;
     DBMS_OUTPUT.PUT_LINE('Constraint '|| j.constraint_name || ' was disabled in table ' ||j.table_name);
   END LOOP;
END;
/   

prompt 
prompt  Keys was disabled. Press <ENTER> to enable it
pause

DECLARE
   CURSOR c1 IS
      SELECT table_name, constraint_name
      FROM kozyr$fkd;
BEGIN
   FOR j IN c1 LOOP
     DELETE FROM KOZYR$FKD WHERE table_name = j.table_name AND constraint_name = j.constraint_name;   
     EXECUTE IMMEDIATE 'ALTER TABLE ' || j.table_name || ' ENABLE CONSTRAINT ' || j.constraint_name;
     DBMS_OUTPUT.PUT_LINE('Constraint '|| j.constraint_name || ' was enabled in table ' ||j.table_name);
   END LOOP;
END;
/

TRUNCATE TABLE kozyr$fkd;
DROP TABLE kozyr$fkd;