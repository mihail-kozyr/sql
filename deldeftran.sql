BEGIN
  FOR j IN (SELECT *
                FROM deftrandest
              WHERE dblink = UPPER(&dblink) )
  LOOP
    DBMS_DEFER_SYS.delete_tran(j.deferred_tran_id, j.dblink);
  END LOOP;
  COMMIT WORK;
END;
/

