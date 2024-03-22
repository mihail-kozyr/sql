DECLARE
  v date := sysdate;
BEGIN
  while (v + 10/24/60 > sysdate)
  loop
    null;
  end loop;
END;
/
