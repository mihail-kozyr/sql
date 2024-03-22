set pagesize 0
set feed off
set term off
set echo off

spool c:\temp\rename.sql

select 'alter database rename file ''' || name || ''' to '''||
  replace(name, 'C:\', 'D:\')||''';'
from v$datafile
union all
select 'alter database rename file ''' || member || ''' to '''||
  replace(member, 'C:\', 'D:\')||''';'
from v$logfile
/

spool off
set feed on
set pagesize 24