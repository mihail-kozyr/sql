REM Session I/O By User

set linesize 200
col osuser for a20
col username for a20

SELECT NVL(sess.username, 'Oracle Process') AS username,
       sess.osuser,
--       sess.process pid,
       sid,
--       sess.serial#,
       io.physical_reads,
       io.block_gets,
       io.consistent_gets,
       io.block_changes,
       io.consistent_changes
  FROM v$sess_io io JOIN v$session sess USING (sid)
ORDER BY io.block_gets+io.consistent_gets DESC
/