Rem
Rem chk_repl.sql Michael Kozyr, RDTEX JSC www.rdtex.ru
Rem
Rem    NAME
Rem      chk_repl.sql - ѕроверка требований дл€ репликации.
Rem
Rem    DESCRIPTION
Rem      ѕроверка требований дл€ репликации: параметры инициализации 
Rem
Rem    NOTES
Rem     »спользована NOTE 117434.1
Rem
Rem	Parameter Name 		Recommended Initial Value 
Rem	---------------		------------------------------------------------
Rem	COMPATIBLE 		9.0.1.0.0 minimum. OSS recommends this equate to 
Rem				the server release 
Rem
Rem	SHARED_POOL_SIZE 	Additional 30M (for basic) and an 
Rem				additional 80M or more for most 
Rem				complex configurations
Rem
Rem	PROCESSES 		Add 12 to the current value 
Rem
Rem	GLOBAL_NAMES 		TRUE 
Rem
Rem	DB_DOMAIN 		extension component of the local R
Rem				databases Global Name 
Rem
Rem	OPEN_LINKS 		4 (Add 2 per additional master) 
Rem
Rem	REPLICATION_DEPENDENCY_TRACKING=TRUE 
Rem
Rem	JOB_QUEUE_PROCESSES	3 (Add 1 per additional master) 
Rem
Rem	PARALLEL_MAX_SERVERS 	10 
Rem
Rem	PARALLEL_MIN_SERVERS 	2 
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kozyr	06/10/04 - created
Rem

col name for a40
col value for a15
col valid for a10
set serveroutput on ver off feed off 

select tablespace_name, sum(bytes)/1024/1024 Mb
from dba_free_space
group by tablespace_name
/

CREATE OR REPLACE VIEW chk_repl$tmp
AS
SELECT name, value, recomended, dtype, is_dynamic,
  CASE WHEN dtype = 'COMPATIBLE' THEN
     CASE WHEN replace(value, '.', '') >= replace(recomended, '.', '') THEN
       'VALID'
     ELSE
       'INVALID'
     END
  WHEN dtype = 'BOOLEAN' THEN
     CASE WHEN value=recomended THEN
       'VALID'        
     ELSE
       'INVALID'
     END
  WHEN DTYPE = 'NUMBER' THEN
     CASE WHEN to_number(value) >= to_number(recomended) THEN
       'VALID'
     ELSE
       'INVALID'
     END
  END status
FROM(
SELECT name, value, 
       CASE WHEN substr(recomended, 1, 1) = 'S' THEN
          'N'
       WHEN substr(recomended, 1, 1) = 'D' THEN       
          'Y'
       END IS_DYNAMIC,
       CASE WHEN substr(recomended, 2, 1) = 'N' THEN
          'NUMBER'
       WHEN substr(recomended, 2, 1) = 'T' THEN       
          'BOOLEAN'
       WHEN substr(recomended, 2, 1) = 'C' THEN       
          'COMPATIBLE'
       END dtype,
       substr(recomended, 4) recomended
FROM(
SELECT upper(name) name, value,
       CASE WHEN upper(name)='COMPATIBLE' THEN
          'SC_9.0.1.0.0'
        WHEN upper(name)='SHARED_POOL_SIZE' THEN
          'DN_31457280'
        WHEN upper(name)='PROCESSES' THEN
          'SN_162'
        WHEN upper(name)='GLOBAL_NAMES' THEN
          'DT_TRUE' 
        WHEN upper(name)='OPEN_LINKS' THEN
          'SN_4'
        WHEN upper(name)='REPLICATION_DEPENDENCY_TRACKING' THEN
         'ST_TRUE'
        WHEN upper(name)='JOB_QUEUE_PROCESSES' THEN
          'DN_3'
        WHEN upper(name)='PARALLEL_MAX_SERVERS' THEN
          'SN_10'
        WHEN upper(name)='PARALLEL_MIN_SERVERS' THEN
          'SN_2'
       END recomended
FROM v$parameter
WHERE upper(name) in ( 'COMPATIBLE',
                'SHARED_POOL_SIZE',
                'PROCESSES',
                'GLOBAL_NAMES',
--                'DB_DOMAIN',
                'OPEN_LINKS',
                'REPLICATION_DEPENDENCY_TRACKING',
                'JOB_QUEUE_PROCESSES',
                'PARALLEL_MAX_SERVERS',
                'PARALLEL_MIN_SERVERS'
               )
ORDER BY decode(upper(name), 'COMPATIBLE',1,
                'SHARED_POOL_SIZE',2,
                'PROCESSES',3,
                'GLOBAL_NAMES',4,
                'DB_DOMAIN',5,
                'OPEN_LINKS',6,
                'REPLICATION_DEPENDENCY_TRACKING',7,
                'JOB_QUEUE_PROCESSES',8,
                'PARALLEL_MAX_SERVERS',9,
                'PARALLEL_MIN_SERVERS',10
               )
       )
     )
/

select name, value, recomended, status from chk_repl$tmp;

PROMPT 

accept p_filename char default 'none.lst' prompt 'Please, enter the file name for modification initialization parameters: '

spool &p_filename
set term off

DECLARE
   v_version NUMBER;

   CURSOR C1 IS
     SELECT * 
     FROM chk_repl$tmp
     WHERE status = 'INVALID';
BEGIN
   IF '&p_filename' <> 'none' THEN
      FOR j IN c1 LOOP
         IF j.name = 'COMPATIBLE' THEN
           SELECT substr(banner, 37, 9) 
           INTO v_version
           FROM v$version 
           WHERE rownum = 1;
           DBMS_OUTPUT.PUT_LINE('ALTER SYSTEM SET '||j.name||'=''' || v_version || ''' SCOPE=SPFILE;');
         ELSE
           IF j.is_dynamic = 'Y' THEN
             DBMS_OUTPUT.PUT_LINE('ALTER SYSTEM SET '||j.name||'=' || j.recomended || ';');
           ELSE
             DBMS_OUTPUT.PUT_LINE('ALTER SYSTEM SET '||j.name||'=' || j.recomended || ' SCOPE=SPFILE;');
           END IF;
         END IF;

      END LOOP;
   END IF;
END;
/

spool off
drop view chk_repl$tmp;
host del 'none.lst'

set serveroutput off feed on term on