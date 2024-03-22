select tablespace_name, sum(bytes)/1024/1024 "Mb Free"
from dba_free_space
group by tablespace_name
/
