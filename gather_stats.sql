DECLARE
   CURSOR tabs
   IS
      SELECT owner, table_name
        FROM dba_tables
       WHERE owner NOT IN
                ('SYS', 
                 'SYSTEM',
                 'OUTLN',
                 'OLAPSYS',
                 'WMSYS',
                 'SCOTT',
                 'PERFSTAT',
                 'QS_OS',
                 'QS_CS',
                 'QS_CBADM',
                 'QE',
                 'QS',
                 'QS_ES',
                 'QS_WS',
                 'OE',
                 'ORDSYS',
                 'MDSYS',
                 'CTXSYS',
                 'XDB',
                 'WKSYS',
                 'ODM',
                 'ODM_MTR',
                 'HR',
                 'PM',
                 'SH',
                 'RMAN'
                )
         AND (last_analyzed < SYSDATE - 10 OR last_analyzed IS NULL);
BEGIN
   FOR x IN tabs
   LOOP
      BEGIN
         DBMS_STATS.gather_table_stats
                            (ownname               => x.owner,
                             tabname               => x.table_name,
                             estimate_percent      => DBMS_STATS.auto_sample_size,
                             method_opt            => 'FOR ALL COLUMNS SIZE AUTO',
                             DEGREE                => 2,
                             granularity           => 'ALL',
                             CASCADE               => TRUE
                            );
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END LOOP;
END;
/
