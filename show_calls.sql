spool trans.log 
set serveroutput on size 1000000 
DECLARE  
  argno          NUMBER;
  argtyp         NUMBER;
  typdsc         CHAR(15);
  rowid_val      ROWID;  
  char_val       VARCHAR2(255);
  date_val       DATE;
  number_val     NUMBER;
  varchar2_val   VARCHAR2(2000);
  raw_val        RAW(255);
  callno         NUMBER;  
  start_time     VARCHAR2(255); 
  destination    VARCHAR2(255); 
  v_tranid       deftran.deferred_tran_id%TYPE; 
  origdb         VARCHAR2(200);  
  origuser       VARCHAR2(200); 
  local_node     VARCHAR2(300); 
  tranid         VARCHAR2(70);  
  schnam         VARCHAR2(35);  
  pkgnam         VARCHAR2(35);  
  prcnam         VARCHAR2(35); 
  operation      VARCHAR2(35);  
  argcnt         NUMBER;  
--------------------------------------------------------------------------------
CURSOR c_deftran is 
       SELECT deferred_tran_id--!!, origin_user  
       FROM deftran; 
       
CURSOR c_defcall IS 
       SELECT callno,   
             --! deferred_tran_db,   
              deferred_tran_id,  
              schemaname,  
              packagename,  
              procname,  
              argcount  
          FROM defcall  
         WHERE deferred_tran_id = v_tranid;  
--------------------------------------------------------------------------------         
CURSOR c_operation IS 
 SELECT SUBSTR(procname,5,12)  
       FROM defcall 
         WHERE deferred_tran_id = v_tranid; 
--------------------------------------------------------------------------------         
CURSOR c_started IS 
       SELECT to_char(start_time,'MON-DD-YYYY:HH24:MI:SS') 
          FROM deftran 
         WHERE deferred_tran_id = v_tranid; 
--------------------------------------------------------------------------------       
CURSOR c_destination IS  
       SELECT dblink 
          FROM deftrandest 
         WHERE deferred_tran_id = v_tranid; 
--------------------------------------------------------------------------------
BEGIN  
  SELECT GLOBAL_NAME 
     INTO local_node 
    FROM GLOBAL_NAME; 
  
  DBMS_OUTPUT.put_line(CHR(10)||'PRINTING ALL CALLS FOR SITE: '
                            ||local_node||CHR(10)); 
  FOR c_deftran_rec in c_deftran LOOP 
    v_tranid := c_deftran_rec.deferred_tran_id; /* Assign bind variable */ 
--!!    origuser := c_deftran_rec.origin_user; 
    argno := 1;  
    
    OPEN c_defcall;  
    OPEN c_operation; 
    OPEN c_started; 
    OPEN c_destination; 
  
    WHILE TRUE LOOP  
     FETCH c_defcall into callno,/*origdb,*/tranid,schnam,pkgnam,prcnam,argcnt;  
     FETCH c_operation into operation; 
     FETCH c_started into start_time; 
     FETCH c_destination into destination; 
     EXIT WHEN c_defcall%NOTFOUND;  
     DBMS_OUTPUT.put_line('*******************************************'); 
     DBMS_OUTPUT.put_line('Transaction id: '||tranid); 
     DBMS_OUTPUT.put_line('Transaction logged by: '||origuser); 
     DBMS_OUTPUT.put_line('Transaction logged on: '||start_time); 
     DBMS_OUTPUT.put_line('DML operation is a ' || operation||'.'); 
     DBMS_OUTPUT.put_line('Originating from ' || origdb); 
     DBMS_OUTPUT.put_line('Destination to: ' || destination); 
     DBMS_OUTPUT.put_line('Call to ' || schnam||'.'||pkgnam||'.'||prcnam);  
     DBMS_OUTPUT.put_line('ARG ' || 'Data Type       ' || 'Value');  
     DBMS_OUTPUT.put_line('--- ' || '--------------- '   
                          || '-----------------------');  
     argno := 1;  
     WHILE TRUE LOOP  
        IF argno > argcnt THEN 
          EXIT;  
        END IF;  
  
        argtyp := dbms_defer_query.get_arg_type(callno,  
                                                origdb,  
                                                argno,  
                                                tranid);  
        IF argtyp = 1 THEN  
           typdsc := 'VARCHAR2';  
           varchar2_val := dbms_defer_query.get_varchar2_arg(callno,  
              origdb,argno,tranid);  
            dbms_output.put_line(to_char(argno,'09')|| ') ' 
                || typdsc||' '|| varchar2_val);  
        END IF;  
        IF argtyp = 2 THEN  
           typdsc := 'NUMBER';  
           number_val := dbms_defer_query.get_number_arg(callno,  
     origdb,argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| number_val);  
 end if;  
        if argtyp = 11 then  
           typdsc := 'ROWID';  
 rowid_val := dbms_defer_query.get_rowid_arg(callno,  
                        origdb,argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| rowid_val);  
        end if;  
        if argtyp = 12 then  
           typdsc := 'DATE';  
           date_val := dbms_defer_query.get_date_arg(callno,  
                                       origdb,argno,tranid);  
    dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '  
                                || to_char(date_val,'YYYY-MM-DD HH24:MI:SS'));  
        end if;  
        if argtyp = 23 then  
typdsc := 'RAW';  
raw_val := dbms_defer_query.get_raw_arg(callno,  
                   origdb,argno,tranid);  
    dbms_output.put_line(to_char(argno,'09')   
                                || ') ' || typdsc||' '|| raw_val);  
     end if;  
        if argtyp = 96 then  
           typdsc := 'CHAR';  
    char_val := dbms_defer_query.get_char_arg(callno,  
                            origdb,argno,tranid);  
           dbms_output.put_line(to_char(argno,'09')   
               || ') ' || typdsc||' '|| char_val);  
     end if;  
  
 
        argno := argno + 1;  
     end loop;  
 end loop;  
 close c_defcall;  
 close c_operation; 
 close c_started; 
 close c_destination; 
 END LOOP; 
end; 
/ 
spool off 
 
