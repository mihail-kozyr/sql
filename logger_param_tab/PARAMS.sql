--------------------------------------------------------
--  DDL for Table PARAMS
--------------------------------------------------------

  CREATE TABLE "PARAMS" 
   (	"PARAM" VARCHAR2(512 CHAR), 
	"VAL" VARCHAR2(4000 CHAR), 
	"DESCRIPTION" VARCHAR2(4000 CHAR), 
	"CREATED_ON" DATE DEFAULT SYSDATE, 
	"CREATED_BY" VARCHAR2(512 CHAR) DEFAULT sys_context('USERENV','OS_USER'), 
	"MODIFIED_ON" DATE DEFAULT sysdate, 
	"MODIFIED_BY" VARCHAR2(512 CHAR)
   ) ;
