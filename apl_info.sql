begin
  dbms_output.put_line(sys_context('userenv', 'client_info') );
end;
/

begin
   dbms_application_info.set_module(module_name => 'SCOTINA', 
                                    action_name => 'TEST');
end;
/

begin
  dbms_application_info.set_client_info('BI');
end;
/
