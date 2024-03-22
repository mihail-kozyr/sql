SELECT sql_text, module, elapsed_time, executions, disk_reads, buffer_gets, rows_processed,
       ROUND(elapsed_time/executions/1000000, 4), hash_value
FROM v$sqlarea
WHERE NVL(executions,0) > 0
AND elapsed_time/executions/1000000 > 1
ORDER BY elapsed_time/executions DESC
