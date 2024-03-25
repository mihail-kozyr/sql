WHENEVER SQLERROR EXIT FAILURE;
--------------------------------------------------------
--  DDL for Table LOG
--------------------------------------------------------

  CREATE TABLE "LOG" 
   (	"ID" NUMBER GENERATED ALWAYS AS IDENTITY, 
	"LOG_DATE" DATE DEFAULT SYSDATE, 
	"TASK_CODE" VARCHAR2(128 CHAR), 
	"LOG_LEVEL" VARCHAR2(30 CHAR), 
	"MESSAGE" VARCHAR2(4000 CHAR), 
	"ERROR_CODE" VARCHAR2(256 CHAR), 
	"PROCEDURE_NAME" VARCHAR2(240 CHAR), 
	"ERROR_LINE" NUMBER, 
	"NOTE" VARCHAR2(4000 CHAR), 
	"MODIFIED_ON" DATE DEFAULT SYSDATE, 
	"MODIFIED_BY" VARCHAR2(30 CHAR) DEFAULT USER, 
	"OSUSER" VARCHAR2(30 CHAR) DEFAULT sys_context('USERENV','OS_USER'), 
	"HOST" VARCHAR2(54 CHAR) DEFAULT sys_context('USERENV','HOST'), 
	"IP" VARCHAR2(30 CHAR) DEFAULT sys_context('USERENV','IP_ADDRESS'), 
	"CLIENT_IDENTIFIER" VARCHAR2(64 CHAR) DEFAULT sys_context('USERENV','CLIENT_IDENTIFIER'), 
	"CALL_STACK" VARCHAR2(4000 CHAR), 
	"SESSIONID" VARCHAR2(200 CHAR) DEFAULT sys_context('USERENV','SESSIONID'), 
	"SID" NUMBER DEFAULT to_number(sys_context('USERENV','SID') ), 
	"ACTION" VARCHAR2(32 CHAR) DEFAULT sys_context('USERENV','ACTION'), 
	"BG_JOB_ID" VARCHAR2(64 CHAR) DEFAULT sys_context('USERENV','BG_JOB_ID'), 
	"MODULE" VARCHAR2(48 CHAR) DEFAULT sys_context('USERENV','MODULE'), 
	"STATEMENTID" NUMBER DEFAULT to_number(sys_context('USERENV','STATEMENTID') ), 
	"ERROR_BACKTRACE" VARCHAR2(4000 CHAR), 
	"LONG_MESSAGE" CLOB,
    "TABLE_NAME" VARCHAR2(128 BYTE)	
   ) ;


   COMMENT ON COLUMN "LOG"."ID" IS '����������� ����';
   COMMENT ON COLUMN "LOG"."LOG_DATE" IS '���� �������';
   COMMENT ON COLUMN "LOG"."TASK_CODE" IS '��� ������';
   COMMENT ON COLUMN "LOG"."LOG_LEVEL" IS '������� �����������: CRITICAL, ERROR, WARNING, INFO, DEBUG';
   COMMENT ON COLUMN "LOG"."MESSAGE" IS '����� ���������';
   COMMENT ON COLUMN "LOG"."ERROR_CODE" IS '��� ������ ��� ��������������';
   COMMENT ON COLUMN "LOG"."PROCEDURE_NAME" IS '�������� ������������ ������';
   COMMENT ON COLUMN "LOG"."ERROR_LINE" IS '������ ������ � ����������� ������';
   COMMENT ON COLUMN "LOG"."NOTE" IS '�����������';
   COMMENT ON COLUMN "LOG"."MODIFIED_ON" IS '���� �������/��������� ������';
   COMMENT ON COLUMN "LOG"."MODIFIED_BY" IS '����� �������/���������';
   COMMENT ON COLUMN "LOG"."OSUSER" IS '������������ ��';
   COMMENT ON COLUMN "LOG"."HOST" IS '��� �����';
   COMMENT ON COLUMN "LOG"."IP" IS 'IP �����';
   COMMENT ON COLUMN "LOG"."CLIENT_IDENTIFIER" IS '���������� ������������� ����������, ������������� ����� DBMS_SESSION.SET_IDENTIFIER, ����� ������ OCI OCI_ATTR_CLIENT_IDENTIFIER ��� Java ����� Oracle.jdbc.OracleConnection.setClientIdentifier';
   COMMENT ON COLUMN "LOG"."CALL_STACK" IS '������ ���� �������';
   COMMENT ON COLUMN "LOG"."SESSIONID" IS '������������� ������';
   COMMENT ON COLUMN "LOG"."SID" IS 'SID ������';
   COMMENT ON COLUMN "LOG"."ACTION" IS '��� ����������, ������������� ����� ����� DBMS_APPLICATION_INFO ��� OCI';
   COMMENT ON COLUMN "LOG"."BG_JOB_ID" IS '������������� �������� �������� oracle';
   COMMENT ON COLUMN "LOG"."MODULE" IS '������, ������������� ����� ����� DBMS_APPLICATION_INFO ��� OCI';
   COMMENT ON COLUMN "LOG"."STATEMENTID" IS '������������� ����������� ����� ����������� ��� fine-grained ����� ��������� - STATEMENTID';
   COMMENT ON COLUMN "LOG"."ERROR_BACKTRACE" IS '���� ������ � ��������� ������ ������, � ������� ��������� ����������';
   COMMENT ON COLUMN "LOG"."LONG_MESSAGE" IS '���� ��� ���������, ����������� 4000 ����';
   COMMENT ON TABLE "LOG"  IS '������� ��������������';
