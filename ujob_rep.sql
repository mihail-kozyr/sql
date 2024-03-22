set linesize 200
col what for a60
col log_user for a10

select job, what, broken, failures, (next_date-sysdate)*24*60*60 sec
from user_jobs
/
