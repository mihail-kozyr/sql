TRUNCATE TABLE mv_capabilities_table;

BEGIN
  FOR J IN (SELECT * FROM user_mviews)
  LOOP
    DBMS_MVIEW.EXPLAIN_MVIEW(j.mview_name);
    COMMIT WORK;
  END LOOP;
END;
/

SELECT mvname, capability_name, possible
  FROM mv_capabilities_table
ORDER BY mvname
/
