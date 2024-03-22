COL username for a15
COL program for a20
COL osuser for a20
SELECT p.spid, 
NVL(b.name, 'N/A') process, 
NVL(s.username, 'N/A') username, 
NVL(s.osuser, 'N/A') osuser, 
s.status status, 
s.sid sid, 
NVL(s.program, 'N/A') program, 
t.value value 
FROM v$process p, v$bgprocess b, v$session s, v$sesstat t, v$statname n 
WHERE s.paddr=p.addr AND b.paddr(+)=p.addr AND t.sid=s.sid AND n.name='session pga memory max' 
AND t.statistic#=n.statistic# 
Order by t.value desc
/
