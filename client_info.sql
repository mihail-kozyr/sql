set linesize 200
column username format a20 word_wrapped
column module format a30 word_wrapped
column action format a30 word_wrapped
column client_info format a10 word_wrapped

select username||'('||sid||','||serial#||')' username,
	   module, 
	   action, 
	   client_info
from v$session
where module||action||client_info is not null;
