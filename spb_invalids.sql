col object_name for a30
set linesize 200
set pagesize 100


SELECT owner, object_type, object_name, status
   FROM dba_objects
 WHERE status != 'VALID'
    AND (owner = 'SPB' 
         OR (owner = 'DFS_TECH' AND object_name LIKE '%SPB%')
        )
    
ORDER BY 1, 2, 3;