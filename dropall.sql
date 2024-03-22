rem *********************************************************************
rem
rem   DROP_ALL.SQL: Drops ALL objects for a current user.
rem
rem *********************************************************************

rem USAGE: invoke SQLPLUS as user, type START drop_all.sql
rem 
rem BE CAREFULL
 
show user

prompt 
prompt  All user's objects will be droped
prompt  Press <Del> to cancel 
pause

set verify off
set linesize 200
set trimspool on
set heading off
set pagesize 0
set feedback off

spool drop2.sql
select  'alter table '||TABLE_NAME||' drop constraint  '|| CONSTRAINT_NAME ||' cascade;'
from    USER_CONSTRAINTS
where   CONSTRAINT_TYPE IN ('U', 'P');
select  'drop ' || OBJECT_TYPE|| ' ' || OBJECT_NAME ||';'
from    USER_OBJECTS
where   OBJECT_TYPE NOT IN ('INDEX', 'PACKAGE BODY', 'TRIGGER');
spool off

set feedback on
set termout on
set heading on
set pagesize 45

