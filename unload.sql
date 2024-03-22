REM ------------------------------------------------------------------------ 
REM PAREMETERS: 
REM   1 - name of PL/SQL program unit
REM   2 - type of PL/SQL program unit (FUNCTION, PACKAGE, PACKAGE BODY)
REM   3 - file name to unload CREATE statement
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTEX
REM    (c)2006 RDTEX
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Unload stored PL/SQL program unit. 
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM
REM  @unload find package find
REM  
REM ------------------------------------------------------------------------ 





set pagesize 0
set ver off
set feed off
set echo off
set term off

spool &3..sql

SELECT 'CREATE OR REPLACE ' FROM dual
UNION ALL
SELECT text 
FROM (SELECT text 
      FROM user_source 
      WHERE NAME = UPPER('&1') 
      AND TYPE = UPPER('&2') 
      ORDER BY line)
UNION ALL
SELECT '/' FROM dual;

spool off