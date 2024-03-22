SET ECHO off 
REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM SELECT on V$LOG and V$LOGFILE 
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTEX
REM    (c)2004 RDTEX
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Provide sessions information from v$sessions. 
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM
REM   OS user    Username     SID  SERIAL# SQL for kill
REM   ---------- ------------ ---- ------- ---------------------------------
REM   andredok   FSP          17    14659  ALTER SYSTEM KILL SESSION '17,14659';
REM   kozyr      FSP          20    2032   ALTER SYSTEM KILL SESSION '20,2032';
REM  
REM ------------------------------------------------------------------------ 
 

set linesize 300
 
col osuser 	format a20      heading 'OS user'  
col username 	format a10      heading 'Username'  
col spid                        heading 'Process'
col v_sql	format a70      heading 'SQL for kill'  




SELECT s.osuser, s.username, s.sid, s.serial#, p.spid, TO_CHAR(logon_time, 'dd.mm.yyyy hh24:mi') logon,
  DECODE(UPPER('&1'), 'KILL', 'ALTER SYSTEM KILL SESSION ''' || s.sid ||','||s.serial#||''';'
             , 'TRC', 'exec SYS.DBMS_SYSTEM.SET_EV(' || s.sid || ', ' || s.serial# ||', 10046, 12, '''');'
             , 'NULL')  v_sql
    FROM v$session s  JOIN v$process p ON (s.paddr=p.addr)
  WHERE s.username is not null
ORDER BY s.osuser, s.username
/


