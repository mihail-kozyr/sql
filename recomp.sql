SELECT 'ALTER ' || decode(object_type, 'PACKAGE BODY', 'PACKAGE', object_type) || ' '
       || owner || '.' || object_name || ' compile;' recomp
    FROM dba_objects
  WHERE STATUS = 'INVALID'
/
