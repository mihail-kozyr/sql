col name for a50

select d.file# f#, d.name, d.status, h.status
from v$datafile d
   join v$datafile_header h on (d.file#=h.file#)
/
