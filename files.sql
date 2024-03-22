REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM   NONE 
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTEX
REM    (c)2005 RDTEX 
REM
REM CREATED:
REM    04.01.2005
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    List data files, control files, redo logs. Useful for backup.
REM    Change a dir_sep depending on platform
REM ------------------------------------------------------------------------ 


set linesize 300
col dir for a50
col file_name for a20
column dir_sep noprint new_value dir_sep format a1000
break on  dir skip 1
compute sum of mb on dir
compute sum of mb on report

SELECT CASE WHEN VALUE LIKE '%:\%' THEN '\' ELSE '/' END AS dir_sep 
   FROM v$parameter
  WHERE NAME = 'user_dump_dest';
  
SELECT SUBSTR(NAME, 1, INSTR (NAME, '&dir_sep', -1)) dir, 
       SUBSTR(NAME, INSTR (NAME, '&dir_sep', -1)+1)  file_name,
       file_type, ROUND(MB) MB
 FROM (SELECT NAME, bytes/1024/1024 MB, 'DATA' file_type
         FROM v$datafile
      UNION ALL
      SELECT NAME, 0 MB, 'CONTROL' file_type
        FROM v$controlfile
      UNION ALL
      SELECT NAME, bytes/1024/1024 MB, 'TEMP' file_type
        FROM v$tempfile      
      UNION ALL
      SELECT MEMBER, bytes/1024/1024 MB, 'REDO' file_type
        FROM v$logfile JOIN v$log ON (v$logfile.group#=v$log.group#)
     )
ORDER BY 1
/
