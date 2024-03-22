SELECT gname, status 
  FROM dba_repgroup;

SELECT oname, status, generation_status
   FROM  dba_repobject  
  WHERE status <> 'VALID';
  
SELECT oname, status, generation_status,
       replication_trigger_exists, internal_package_exists
   FROM  dba_repobject
  WHERE status != 'VALID'
     OR replication_trigger_exists != 'Y'
     OR internal_package_exists != 'Y'; 
     
column owner format a25
column object_name format a30
column object_type format a15

SELECT owner, object_name, object_type
   FROM  dba_objects
  WHERE status != 'VALID'
    AND   owner IN ('SYS', 'SYSTEM');      
    
column gname format a18

SELECT gname, request, status, errnum
  FROM   dba_repcatlog
ORDER BY id, gname;    
