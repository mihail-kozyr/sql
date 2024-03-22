
Rem =======================================================================
Rem Display instance name
Rem =======================================================================
select instance_name, status from v$instance;

Rem =======================================================================
Rem Display instance version
Rem =======================================================================
select * from v$version;

Rem =======================================================================
Rem Display new versions and status
Rem =======================================================================
column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version from dba_registry;
