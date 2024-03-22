set linesize 300
 
col osuser 	format a20      heading 'OS user'  
col username 	format a10      heading 'Username'  
col spid                        heading 'Process'
col v_sql	format a70      heading 'SQL for kill'  




SELECT s.machine, s.osuser, s.username, s.sid, s.serial#, p.spid, TO_CHAR(logon_time, 'dd.mm.yyyy hh24:mi') logon
    FROM v$session s, v$process p 
  WHERE s.username is not null
    AND s.paddr = p.addr
ORDER BY s.osuser, s.username
/


