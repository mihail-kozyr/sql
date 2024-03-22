SET SERVEROUTPUT ON
DECLARE
  l_redo_before PLS_INTEGER;
  l_redo_after  PLS_INTEGER;
BEGIN
  FOR J IN (SELECT * FROM user_mviews)
  LOOP
    SELECT value
      INTO l_redo_before
      FROM v$mystat JOIN v$statname USING (statistic#)
    WHERE NAME = 'redo size';
    DBMS_MVIEW.REFRESH(j.mview_name);
    COMMIT WORK;
    SELECT value
      INTO l_redo_after
      FROM v$mystat JOIN v$statname USING (statistic#)
    WHERE NAME = 'redo size';
    DBMS_OUTPUT.PUT_LINE(l_redo_after-l_redo_before
          || ' was used for refreshing '||j.mview_name);
  END LOOP;
  COMMIT;
END;
/
