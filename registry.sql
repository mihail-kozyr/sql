SET LINESIZE 120
COL comp_name for A40

SELECT * FROM v$version;

SELECT comp_name, version
  FROM dba_registry;
  