column object_name format a30
column number_of_blocks format 999,999,999,999

SELECT o.object_name, count(1) number_of_blocks
   FROM dba_objects o, v$bh bh
  WHERE o.object_id = bh.objd
   AND o.owner <> 'SYS'
  GROUP BY o.object_name 
  ORDER BY count(1) DESC
/
