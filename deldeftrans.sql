DECLARE
  counter NUMBER DEFAULT 0;
BEGIN
  FOR j IN (SELECT *
                FROM deftrandest
              WHERE dblink = UPPER('&1') )
  LOOP
    DBMS_DEFER_SYS.delete_tran(j.deferred_tran_id, j.dblink);
    counter := counter + 1;
  END LOOP;
  COMMIT WORK;
  DBMS_OUTPUT.PUT_LINE(counter || ' def. trans was dropped.');
END;
/

