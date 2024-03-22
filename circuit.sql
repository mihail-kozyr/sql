select d.name, c.circuit, c.server, c.status
from v$circuit c
  join v$dispatcher d on (c.dispatcher=d.paddr)
/
