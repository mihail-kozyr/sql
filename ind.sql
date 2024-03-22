REM ------------------------------------------------------------------------ 
REM REQUIREMENTS: 
REM   RESOURCE role
REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTEX
REM    (c)2004 RDTEX
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Provide index information 
REM ------------------------------------------------------------------------ 

undefine table
col partition_name FOR a10
SET linesize 200
SELECT user_indexes.table_name,
       user_indexes.index_name, 
       user_indexes.uniqueness,
       user_indexes.partitioned,
	   NULL status,
	   NULL partition_name,
	   NULL locality,
	   NULL alignment
FROM user_indexes
WHERE table_name LIKE UPPER('&&table')
AND partitioned <> 'YES'
UNION ALL 
SELECT user_indexes.table_name,
       user_indexes.index_name, 
       user_indexes.uniqueness,
       user_indexes.partitioned,
	   user_ind_partitions.status,
	   user_ind_partitions.partition_name,
	   user_part_indexes.locality,
	   user_part_indexes.alignment
FROM user_indexes
  JOIN user_ind_partitions ON (user_ind_partitions.index_name = user_indexes.index_name)
  JOIN user_part_indexes ON (user_part_indexes.index_name = user_ind_partitions.index_name) 
WHERE table_name LIKE UPPER('&&table')
AND partitioned = 'YES'
ORDER BY table_name, index_name, partition_name
/
  
