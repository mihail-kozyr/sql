SELECT 'drop table '||r.owner||'.'  || r.table_name || ';'
FROM dba_tables r
  JOIN dba_tables s on (r.table_name = 'E$_'||s.table_name)
WHERE r.owner = 'DFS_RAW'
  AND r.table_name like 'E$%'
  AND s.owner = 'SPB';