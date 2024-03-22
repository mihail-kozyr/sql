set linesize 200 pagesize 64
col username for a20
col osuser for a20
col seq for 999,990
col event for a28

SELECT sess.username, sess.osuser,
       sw.seq#, sw.event, sw.state, sw.seconds_in_wait secs, sw.wait_time
    FROM v$session_wait sw
      JOIN v$session sess USING (sid)
/
