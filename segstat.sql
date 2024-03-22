select
    object_name "Object Name"
  , tablespace_name "Tablespace Name"
  , object_type "Object Type"
  , logical_reads_total "Logical Reads"
  , ratio "%Total"
from(
select n.owner||'.'||n.object_name||decode(n.subobject_name,null,null,'.'||n.subobject_name) object_name
     , n.tablespace_name
     , case when length(n.subobject_name) < 11 then
              n.subobject_name
            else
              substr(n.subobject_name,length(n.subobject_name)-9)
       end subobject_name
     , n.object_type
     , r.logical_reads_total
     , round(r.ratio * 100, 2) ratio
  from dba_hist_seg_stat_obj  n
     , (select *
          from (select e.dataobj#
                     , e.obj#
                     , e.dbid
                     , e.logical_reads_total - nvl(b.logical_reads_total, 0) logical_reads_total
                     , ratio_to_report(e.logical_reads_total - nvl(b.logical_reads_total, 0)) over () ratio
                  from dba_hist_seg_stat  e
                     , dba_hist_seg_stat  b
                 where b.snap_id  = 394
                   and e.snap_id  = 396
                   and b.dbid     = 1190928213   
                   and e.dbid     = 1190928213
                   and b.instance_number  = 1
                   and e.instance_number  = 1
                   and e.obj#             = b.obj#
                   and e.dataobj#         = b.dataobj#
               and e.logical_reads_total - nvl(b.logical_reads_total, 0)  > 0
                 order by logical_reads_total desc) d
          where rownum <= 100) r
 where n.dataobj# = r.dataobj#
)
order by logical_reads_total desc;