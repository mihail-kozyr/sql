SELECT hp.*, sq.sql_id, sq.*, sq.sql_text, sess.* 
  FROM v$SESSION sess
    JOIN v$SQL sq ON (sq.sql_id = sess.sql_id)
    JOIN dba_hist_sql_plan hp ON (sq.plan_hash_value =hp.plan_hash_value AND sess.sql_id = hp.sql_id)
WHERE username = 'OWB_DEV'
 AND status = 'ACTIVE';
 