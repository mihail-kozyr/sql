-- Собранная статистика
SET linesize 100
col object_type FOR a6
SELECT *
FROM (
  SELECT  owner, 
          'table' object_type,
          COUNT(last_analyzed) analyzed,
          COUNT(CASE WHEN last_analyzed IS NOT NULL THEN NULL END) not_analyzed,
          MAX(last_analyzed) freshest_stat,
          MIN(last_analyzed) oldest_stat
      FROM dba_tables
    GROUP BY owner 
  UNION ALL
  SELECT  owner, 
         'index' object_type, 
          COUNT(last_analyzed) analyzed,
          COUNT(CASE WHEN last_analyzed IS NOT NULL THEN NULL END) not_analyzed,
          MAX(last_analyzed) freshest_stat,
          MIN(last_analyzed) oldest_stat
      FROM dba_indexes
    GROUP BY owner)
ORDER BY owner
/