SELECT owner, to_char(last_analyzed, 'mm.yyyy') last_analyzed, COUNT(*) cnt
  FROM dba_tables
 GROUP BY owner, to_char(last_analyzed, 'mm.yyyy')
/
