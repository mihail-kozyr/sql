WITH fwait AS 
(SELECT event, ROUND(AVG(time_waited_micro/total_waits)) avg_tim
     FROM v$session_event
   WHERE event LIKE ('db file s% read')
  GROUP BY event)
SELECT f1.*,
       ROUND((SELECT avg_tim  
                  FROM fwait 
                WHERE event = 'db file sequential read')/
             (SELECT avg_tim 
                  FROM fwait 
                WHERE event = 'db file scattered read')*100) opmimizer_index_cost_adj
  FROM fwait f1
ORDER BY event DESC 
