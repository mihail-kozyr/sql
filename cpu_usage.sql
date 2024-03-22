REM CPU centiseconds used by this session (divide by 100 to get real CPU seconds)

SELECT NVL(sess.username, 'Oracle Process') username,
       sid, 
       nam.NAME, 
       stat.value
    FROM v$sesstat stat
      JOIN v$statname nam USING (statistic#)
      JOIN v$session sess USING (sid)
  WHERE nam.NAME = 'CPU used by this session'
ORDER BY VALUE desc
/
