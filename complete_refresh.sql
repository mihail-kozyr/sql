REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTEX
REM    22/06/2005 
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Disable FK constraints reference to specified table. Useful for
REM    TRUNCATE operation. Then constraints will be enable back.
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM   SQL> set serveroutput on
REM   SQL> @disable_fk gxp_business_units
REM   
REM   Table created.
REM   
REM   Constraint TRT_BUN_FK was disabled in table DSS_TRAN_TARIFS
REM   Constraint GAR_BUN_FK was disabled in table GXP_ADMIN_USERS
REM   Constraint GAN_BUN_FK was disabled in table GXP_ADMIN_USER_BUN
REM   
REM   PL/SQL procedure successfully completed.
REM   
REM   
REM   Keys was disabled. Press <ENTER> to enable it
REM   
REM   ...
REM ------------------------------------------------------------------------ 