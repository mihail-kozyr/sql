CREATE OR REPLACE PROCEDURE show_call (t IN VARCHAR2, c IN NUMBER) IS
--
-- Version: 5/11/99_V8 Erhan Odok (eodok.us)
--
-- Print the argument type and values of a deferred call.
-- Modified for Oracle8 and supports all replicated datatypes including
-- NCHAR, NVARCHAR and all LOBs. (BFILES are not replicated [yet])
--
-- NOTE: set serveroutput on before calling this procedure
--
-- Input parameters
--   t: deferred transaction id
--   c: call identifier from the defCall view
-- Sample output
--   Call Number: 0
--   Call to P98016.SALGRADE$RP.REP_UPDATE
--   # of arguments: 9
--   ARG                    Data Type       Value
--   ---------------------- --------------- ----------------------
--   01 COLUMN_CHANGED$     RAW             060607
--   02*GRADE1_o            NUMBER          9
--   03*GRADE1_n            NUMBER          (NULL)
--   04 HISAL2_o            NUMBER          9999
--   05 HISAL2_n            NUMBER          (NULL)
--   06 LOSAL3_o            NUMBER          999
--   07 LOSAL3_n            NUMBER          (NULL)
--   08 SITE_NAME           VARCHAR2        REP2.WORLD
--   09 PROPAGATION_FLAG    VARCHAR2        N
--
--  Note: Columns marked with a '*' are part of primary key
--
  argno   	number;
  argtyp  	number;
  argform 	number;
  callno  	number;
  tranid  	VARCHAR2(30);
  typdsc 	char(15);
  rowid_val     rowid;
  char_val      varchar2(255);
  nchar_val     nvarchar2(255);
  date_val      date;
  number_val    number;
  varchar2_val  varchar2(2000);
  nvarchar2_val nvarchar2(2000);
  raw_val       raw(255);
  arg_name      varchar2(128);
  arg_name_c	char(128);
  table_name	varchar2(100);
  col_name	varchar2(100);
  pk_char       char(1);

  cursor c_defcall (c NUMBER, t VARCHAR2) is
     select callno, deferred_tran_id, schemaname, packagename, procname, 
argcount
       from defcall
      where callno = c and deferred_tran_id = t;

  cursor c_arg_name (p_schema VARCHAR2, p_procname VARCHAR2, 
                     p_pkgname VARCHAR2, p_call_count VARCHAR2)  is
     select argument_name
       from all_arguments
      where owner = p_schema
        and package_name = p_pkgname
        and object_name = p_procname
        and (overload = (select ovrld.overload from 
                          (select overload, object_name, package_name, 
max(position) pos
                             from all_arguments
                            where object_name = p_procname
                              and package_name = p_pkgname
                            group by overload, object_name, package_name
                          ) ovrld
                          where p_call_count = ovrld.pos
                            and object_name = p_procname
                            and package_name = p_pkgname
                        )
             or overload is null
            )
      order by position;

  cursor pk_cursor (schema VARCHAR2, t_name VARCHAR2, col_name VARCHAR2) is
     select decode (count(*),1,'*',' ')
       from dba_constraints  t1, dba_cons_columns t2
      where t1.constraint_name = t2.constraint_name
        and t1.owner           = t2.owner
        and t1.owner           = schema
        and t1.constraint_type = 'P'
        and t1.table_name      = t_name
        and t2.column_name     like col_name;

BEGIN
  
  FOR c1rec in c_defcall (c, t) LOOP
    dbms_output.put_line('  ');
    dbms_output.put_line('Call Number: ' ||c1rec.callno);
    dbms_output.put_line('Call to ' ||c1rec.schemaname||'.'||c1rec.packagename||
'.'||c1rec.procname);
    dbms_output.put_line('# of arguments: '||c1rec.argcount);
    dbms_output.put_line(' ARG                    ' || 'Data Type       ' || 
'Value');
    dbms_output.put_line(' ---------------------- ' || '--------------- ' || '--
--------------------');

    argno := 1; 
    callno := c1rec.callno; tranid := c1rec.deferred_tran_id;
    open c_arg_name (c1rec.schemaname, c1rec.procname, c1rec.packagename, c1rec.
argcount);

    WHILE argno <= c1rec.argcount LOOP

      fetch c_arg_name into arg_name;
      arg_name_c := arg_name;

      table_name := substr(c1rec.packagename, 1, instr(c1rec.packagename, '$') -
 1);
      col_name := substr(arg_name, 1, length(arg_name) - 5) || '%';
      open pk_cursor (c1rec.schemaname, table_name, col_name);
      fetch pk_cursor into pk_char;
--      dbms_output.put_line (table_name||'.'||col_name||'['||pk_char||']');
      close pk_cursor;

      argtyp := dbms_defer_query.get_arg_type(callno, argno, tranid);
      argform := dbms_defer_query.get_arg_form(callno, argno, tranid);

      if argtyp = 1 and argform = 1 then
        typdsc := 'VARCHAR2';
        varchar2_val := dbms_defer_query.get_varchar2_arg(callno, argno, tranid)
;
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(varchar2_val,'(NULL)'));
      elsif argtyp = 1 and argform = 2 then
        typdsc := 'NVARCHAR2';
        nvarchar2_val := dbms_defer_query.get_nvarchar2_arg(callno, argno, 
tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(translate(nvarchar2_val using char_cs),'(NULL)'));
      elsif argtyp = 2 then
        typdsc := 'NUMBER';
        number_val := dbms_defer_query.get_number_arg(callno, argno, tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(to_char(number_val),'(NULL)'));
      elsif argtyp = 11 then
        typdsc := 'ROWID';
        rowid_val := dbms_defer_query.get_rowid_arg(callno, argno, tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(rowid_val,'(NULL)'));
      elsif argtyp = 12 then
        typdsc := 'DATE';
        date_val := dbms_defer_query.get_date_arg(callno, argno, tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(to_char(date_val,'YYYY-MM-DD HH24:MI:SS'),'(NULL)'));
      elsif argtyp = 23 then
        typdsc := 'RAW';
        raw_val := dbms_defer_query.get_raw_arg(callno, argno, tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(raw_val,'(NULL)'));
      elsif argtyp = 96 and argform = 1 then
        typdsc := 'CHAR';
        char_val := dbms_defer_query.get_char_arg(callno, argno, tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(char_val,'(NULL)')||'|');
      elsif argtyp = 96 and argform = 2 then
        typdsc := 'NCHAR';
        nchar_val := dbms_defer_query.get_nchar_arg(callno, argno, tranid);
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(translate(nchar_val using char_cs),'(NULL)')||'|');
      elsif argtyp = 113 then
        typdsc := 'BLOB';
        varchar2_val := dbms_lob.substr(dbms_defer_query.get_blob_arg(callno, 
argno, tranid));
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(varchar2_val,'(NULL)'));
      elsif argtyp = 112 and argform = 1 then
        typdsc := 'CLOB';
        varchar2_val := dbms_lob.substr(dbms_defer_query.get_clob_arg(callno, 
argno, tranid));
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(varchar2_val,'(NULL)'));
      elsif argtyp = 112 and argform = 2 then
        typdsc := 'NCLOB';
        nvarchar2_val := dbms_lob.substr(dbms_defer_query.get_nclob_arg(callno, 
argno, tranid));
        dbms_output.put_line(to_char(argno,'09')||pk_char||arg_name_c||typdsc||
' '||nvl(translate(nvarchar2_val using char_cs),'(NULL)'));
      end if;

      argno := argno + 1;
    end loop;
  end loop;
end;
/
