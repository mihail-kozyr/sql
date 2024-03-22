COL destination FORMAT a20
COL deferred_tran_id FORMAT A14
COL origin_tran_id FORMAT A14
COL origin_tran_db FOR A18
COL error_msg for A30
SET LINESIZE 200

SELECT   e.destination, /*e.deferred_tran_id,*/ e.origin_tran_db, 
         /*e.origin_tran_id,*/ e.start_time, e.error_msg, COUNT (e.callno) cnt
    FROM SYS.deferror e, SYS.defcall c
   WHERE e.deferred_tran_id = c.deferred_tran_id
GROUP BY e.destination,
         e.deferred_tran_id,
         e.origin_tran_db,
         e.origin_tran_id,
         e.start_time,
         e.error_msg
ORDER BY 1;

COL destination CLEAR
COL origin_tran_db CLEAR
COL error_msg CLEAR
