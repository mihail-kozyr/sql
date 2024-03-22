DECLARE
  CURSOR c_deferr IS
    SELECT deferred_tran_id
          ,destination
      FROM deferror;
BEGIN
  FOR J IN c_deferr LOOP
    dbms_defer_sys.delete_error(j.deferred_tran_id, j.destination);
  END LOOP;
  COMMIT WORK;
END;
/
