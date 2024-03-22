set ver off

create user &1
identified by &1
default tablespace users
temporary tablespace temp
/

grant connect, resource, ckr_des6i to &1
/

grant execute on dbms_pipe to &1;

grant execute on dbms_lock to &1;

grant select on v_$parameter to &1;

grant select on v_$session to &1;


