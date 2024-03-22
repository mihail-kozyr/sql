set serveroutput on 
call dbms_java.set_output(2000); 

exec executecmd('&1 &2 &3 &4 &5 &6 &7 &8 &9 &10')   
