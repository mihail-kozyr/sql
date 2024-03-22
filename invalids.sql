SELECT owner, object_type, COUNT(*) invalids_cnt
    FROM dba_objects
  WHERE status = 'INVALID'
GROUP BY owner, object_type
HAVING COUNT(*) >= 1;

SELECT owner, object_type, object_name
    FROM dba_objects
  WHERE STATUS = 'INVALID'
ORDER BY 1, 2, 3;
