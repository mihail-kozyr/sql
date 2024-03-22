COL name FORMAT a20

SELECT name, value/1024/1024 Mb
  FROM v$parameter
 WHERE name IN ('shared_pool_size',
                'java_pool_size',
                'db_cache_size',
                'log_buffer',
                'large_pool_size',
                'pga_aggregate_target')
/
