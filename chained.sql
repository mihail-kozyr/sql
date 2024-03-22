SELECT owner, COUNT(*)
  FROM dba_tables
 WHERE chain_cnt > 0
GROUP BY owner 
/
