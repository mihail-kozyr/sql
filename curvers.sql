REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM    The script must be run as SYS.
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    The script generates a summary report of the v$sql_shared_cursor 
REM    view. Counts all the children that have Y in any of the columns and 
REM    if any have all N too. The script uses modified procedure from 
REM    Note 438755.1
REM ------------------------------------------------------------------------ 
REM PARAMETERS:
REM     1 - minimum number of child cursors threshold 
REM ------------------------------------------------------------------------ 
 


SET SERVEROUTPUT ON 
DECLARE
  -- vars
  v_query       VARCHAR2(32767);
  v_coladdr     VARCHAR2(4000);
  v_use_sql_id  BOOLEAN;
  theCursor     NUMBER;
  columnValue   VARCHAR2(32000);
  status        NUMBER;
  -- 
  -- Print full version of the cursor 
  PROCEDURE print_sql(p_address VARCHAR2, p_use_sql_id BOOLEAN)
  IS
    v_stmt      VARCHAR2(32000);
    v_sql_text  v$sqltext_with_newlines.sql_text%type;
    theCursor   NUMBER;
    v_query     VARCHAR2(200);
  BEGIN
    IF p_use_sql_id THEN
      dbms_output.put_line(p_address);
      v_query:= 'SELECT sql_text FROM v$sqltext_with_newlines WHERE sql_id = :a ORDER BY piece';    
    ELSE
      v_query:= 'SELECT sql_text FROM v$sqltext_with_newlines WHERE address = HEXTORAW(:a) ORDER BY piece';
    END IF;
    theCursor := dbms_sql.open_cursor;  
    sys.dbms_sys_sql.parse_as_user(theCursor, v_query, dbms_sql.native);
    dbms_sql.bind_variable(theCursor, ':a', p_address);
    dbms_sql.define_column(theCursor, 1, v_stmt, 8000);
    status := dbms_sql.execute(theCursor);
    WHILE (dbms_sql.fetch_rows(theCursor) >0) 
    LOOP
     dbms_sql.column_value(theCursor, 1, v_stmt); 
     dbms_output.put_line(v_stmt); 
    END LOOP;
  END print_sql;
  -- Since 10g sql_id colum is used for unique cursor 
  -- identification. p_sql_id will be true if sql_id
  -- exists in V$SQL_SHARED_CURSOR
  --
  -- p_coladdr is a column name which we're going to use to 
  -- identify the parent cursor. 
  -- V$SQL_SHARED_CURSOR
  --    9i KGLHDPAR      - address of the parent cursor
  --       ADDRESS       - address of the child cursor
  --
  --   10g ADDRESS       - address of the parent cursor
  --       CHILD_ADDRESS - address of the child cursor
  --       
  PROCEDURE coladdr_sqlid
  (p_coladdr OUT VARCHAR2,
   p_use_sql_id  OUT BOOLEAN)
  IS
    v_coladdr VARCHAR(4000);
    v_sql_id  VARCHAR(100);
  BEGIN
    SELECT MAX(column_name),MAX(DECODE(column_name,'SQL_ID','SQL_ID',NULL)) 
      INTO p_coladdr,v_sql_id
     FROM cols 
    WHERE table_name='V_$SQL_SHARED_CURSOR'
     AND column_name IN ('KGLHDPAR','ADDRESS','SQL_ID'); 
     p_use_sql_id := v_sql_id IS NOT NULL;
  END coladdr_sqlid;
  -- The procedure from Note 438755.1 with few modifications
  PROCEDURE version_rpt
   (p_sql_id     VARCHAR2  DEFAULT NULL,
    p_address    VARCHAR2    DEFAULT NULL,
    p_coladdr    VARCHAR2  DEFAULT 'KGLHDPAR',
    p_use_sql_id BOOLEAN   DEFAULT FALSE) 
  IS
    TYPE vc_arr  IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
    TYPE num_arr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    v_colname   vc_arr;
    v_Ycnt      num_arr;
    v_count     NUMBER:=-1;
    v_no        NUMBER;
    v_all_no    NUMBER:=-1;
    v_query     VARCHAR2(4000);
    v_sql_id    VARCHAR2(15):=p_sql_id;
    v_coladdr   VARCHAR2(4000) := p_coladdr;
    v_hash      NUMBER;
    v_address   VARCHAR2(200);
    theCursor   NUMBER;
    columnValue CHAR(1);
    status      NUMBER;
  BEGIN
    IF p_use_sql_id THEN
      EXECUTE IMMEDIATE 'SELECT MAX(hash_value) FROM v$sql WHERE sql_id = :p_sql_id'
        INTO v_hash USING p_sql_id;
      EXECUTE IMMEDIATE 'SELECT MAX(address) FROM v$sql_shared_cursor WHERE sql_id = :p_sql_id'
        INTO v_address USING p_sql_id;        
    ELSE
      EXECUTE IMMEDIATE 'SELECT MAX(hash_value) FROM v$sql WHERE address = :p_address'
        INTO v_hash USING p_address;    
    END IF;
    dbms_output.enable(1000000);
    dbms_output.put_line('Addr: '||v_address||'  Hash_Value: '||v_hash||'  SQL_ID '||v_sql_id);
    dbms_output.put_line('Stmt: '); 
    IF p_use_sql_id THEN
      print_sql(v_sql_id, p_use_sql_id);    
    ELSE 
      print_sql(p_address, p_use_sql_id);    
    END IF;
    v_query:='';
    SELECT column_name, 0 
       BULK COLLECT INTO v_colname,v_Ycnt
      FROM cols 
    WHERE table_name='V_$SQL_SHARED_CURSOR'
     AND data_length=1
    ORDER BY column_id;
      
    FOR i IN 1 .. v_colname.count LOOP
      v_query:= v_query ||','|| v_colname(i);
    END LOOP;
    v_query:= 'SELECT '||substr(v_query,2) || ' FROM V$SQL_SHARED_CURSOR ';
    
    IF v_sql_id IS NOT NULL THEN
      v_query:=v_query ||' WHERE sql_id = '''||v_sql_id||'''';
    ELSE
      v_query:=v_query ||' WHERE '||p_coladdr||' = HEXTORAW('''||p_address||''')';
    END IF;
    theCursor := dbms_sql.open_cursor;
    sys.dbms_sys_sql.parse_as_user(theCursor, v_Query, dbms_sql.native);

    FOR i IN 1 .. v_colname.count 
    LOOP
      dbms_sql.define_column( theCursor, i, columnValue, 8000 );
    END LOOP;
 
    status := dbms_sql.execute(theCursor);
   
    WHILE (dbms_sql.fetch_rows(theCursor) >0) 
    LOOP
      v_no := 0;
      v_count:=v_count+1;
      FOR i IN 1..v_colname.count 
      LOOP
        dbms_sql.column_value(theCursor, i, columnValue);
        IF columnValue='Y' THEN
           v_Ycnt(i):=v_Ycnt(i)+1;
        ELSE
          v_no:=v_no+1;
        END IF;
      END LOOP;
      IF v_no=v_colname.count THEN
        v_all_no:=v_all_no+1;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(theCursor);
    dbms_output.new_line;
    dbms_output.put_line('Children Summary');
    dbms_output.put_line('================');
    FOR i IN 1 .. v_colname.count 
    LOOP
      IF v_Ycnt(i)>0 THEN
        dbms_output.put_line(v_colname(i)||' :'||v_Ycnt(i));
      END IF;
    END LOOP;
    IF v_all_no > 1 THEN 
      dbms_output.put_line('Children with ALL Columns as "N" :'||v_all_no);
    END IF;
    dbms_output.put_line('Children Total :'||v_count);
  END version_rpt;      
BEGIN
  dbms_output.put_line('Version Count Report v1.1rd threshold: &1 '||to_char(sysdate,'dd.mm.yy hh24:mi') );
  dbms_output.put_line('================================================================');
    
  coladdr_sqlid(v_coladdr, v_use_sql_id);
  IF v_use_sql_id THEN
    v_query:= 'sql_id';  
  ELSE
    v_query:= v_coladdr;
  END IF;
  v_query:= 'SELECT '||v_query||' FROM v$sql_shared_cursor GROUP BY '||v_query||' HAVING COUNT(*) > &1';
  theCursor := dbms_sql.open_cursor;  
  sys.dbms_sys_sql.parse_as_user(theCursor, v_query, dbms_sql.native);
  dbms_sql.define_column(theCursor, 1, columnValue, 8000);
  status := dbms_sql.execute(theCursor);
  WHILE (dbms_sql.fetch_rows(theCursor) >0) 
  LOOP
   dbms_sql.column_value(theCursor, 1, columnValue);
    IF v_use_sql_id THEN
       version_rpt(p_sql_id=>columnValue, p_use_sql_id=>v_use_sql_id);
    ELSE
       version_rpt(p_address=>columnValue, p_coladdr=>v_coladdr, p_use_sql_id=>v_use_sql_id);    
    END IF;   
    dbms_output.put_line('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  END LOOP;
END;
/
