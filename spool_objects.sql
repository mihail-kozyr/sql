REM PL/SQL objects in the Shared Pool
COL owner FOR A20
COL NAME FOR A20
COL DB_LINK FOR A20
SET LINESIZE 2000
SELECT *
   FROM v$db_object_cache
  WHERE TYPE IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
ORDER BY sharable_mem desc  
/