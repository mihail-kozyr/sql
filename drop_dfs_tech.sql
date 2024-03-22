

select 'drop '||object_type||' dfs_tech.' || object_name || ';'
-- object_type, object_name
from dba_objects
where owner = 'DFS_TECH'
and object_name like '%SPB%';
