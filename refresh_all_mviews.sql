SET ECHO OFF SERVEROUTPUT ON

REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM   connect, resource roles
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Mihail Kozyr
REM    (c)2006 RDTeX JSC
REM    version 1.0 (02/10/2006)
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Script does complete refresh all materialized views in a schema.
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM
REM  @refresh_all_mviews
REM
REM You can see the progress of mview refreshing using follow query
REM 
REM  SELECT username, osuser, MODULE, action
REM      FROM v$session
REM    WHERE MODULE = '@refresh_all_mviews';
REM
REM ------------------------------------------------------------------------ 
REM Main text of script follows: 
 
 
CREATE TABLE rfr_disabled_constraint
   (mview_name VARCHAR2(30),
    table_name VARCHAR2(30),
    constraint_name VARCHAR2(30))
/

DECLARE
  v_tmp NUMBER; 
  counter NUMBER DEFAULT 0;
  PROCEDURE disable_constraint(p_mview_name      IN VARCHAR2,
                               p_table_name      IN VARCHAR2,
                               p_constraint_name IN VARCHAR2 )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table_name || ' DISABLE CONSTRAINT ' 
                            || p_constraint_name;
                            
    EXECUTE IMMEDIATE 'INSERT INTO rfr_disabled_constraint
                               (mview_name, table_name, constraint_name) 
                       VALUES(:x1, :x2, :x3)' 
                       USING p_mview_name, p_table_name, p_constraint_name;
    
    COMMIT WORK;
  END disable_constraint;
BEGIN
   FOR j IN (SELECT * FROM user_mviews) 
   LOOP
     --DBMS_OUTPUT.Put_Line('   Refreshing materialized view ' || j.mview_name);
  	 DBMS_APPLICATION_INFO.set_module('@refresh_all_mviews', 
                                          'Refreshing ' || j.mview_name);
     FOR i IN (SELECT p.table_name AS mview_name, fk.*
                 FROM user_constraints p JOIN user_constraints fk 
                     ON (p.constraint_name = fk.r_constraint_name 
                          AND p.constraint_type = 'P')
                  WHERE p.table_name = j.mview_name)
     LOOP
       disable_constraint(i.mview_name, i.table_name, i.constraint_name);
     END LOOP;
     dbms_mview.refresh(j.mview_name, 'C');
     -- DBMS_OUTPUT.Put_Line('   Materialized view ' || j.mview_name || ' successfully refreshed.');
     counter := counter + 1;
   END LOOP;
   -- Enabling FK constraints which was disabled on the previous step.
   DBMS_APPLICATION_INFO.set_module('@refresh_all_mviews', 
                                          'Enabling constraints.');
   FOR e IN (SELECT *
               FROM RFR_DISABLED_CONSTRAINT)
   LOOP
     EXECUTE IMMEDIATE 'ALTER TABLE ' || e.table_name || ' ENABLE NOVALIDATE CONSTRAINT ' || e.constraint_name;
   END LOOP;
   DBMS_OUTPUT.put_line(TO_CHAR(counter) || ' mviews refreshed.');
   DBMS_APPLICATION_INFO.set_module(NULL, NULL);
END;
/


DROP TABLE rfr_disabled_constraint;

