COL today NEW_VALUE today
COL logfile NEW_VALUE logfile
WHENEVER SQLERROR EXIT FAILURE 
SET SQLBLANKLINES ON

SET TERMOUT OFF
SELECT TO_CHAR(SYSDATE,'dd.mm.yyyy hh24:mi:ss') AS today,
       'install_logger_'|| TO_CHAR(SYSDATE,'yyyymmddhh24miss')||'.log' AS logfile
 FROM dual;
SET TERMOUT ON
SET ECHO ON


SPOOL '&logfile'

PROMPT *************************************************************************

PROMPT  *  Logger Installation (&today)

PROMPT *************************************************************************
rem @@SEQ.sql
rem@@LOG_NOIDENTITY.sql
@@LOG.sql
@@LOG_CONSTRAINT.sql
@@LOG_DATE_IDX.sql
@@LOG_LEVEL.sql
@@LOG_LEVEL_CONSTRAINT.sql
@@LOG_LEVEL_DATA_TABLE.sql
@@PARAMS.sql
@@PARAMS_CONSTRAINT.sql
@@PARAMS_DATA_TABLE.sql
@@logger.pls
@@logger.plb


SPOOL OFF