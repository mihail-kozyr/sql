set linesize 200
set pagesize 200

SELECT *
  FROM TABLE(DBMS_XPLAN.DISPLAY)
/