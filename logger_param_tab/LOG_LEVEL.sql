--------------------------------------------------------
--  DDL for Table LOG_LEVEL
--------------------------------------------------------

  CREATE TABLE "LOG_LEVEL" 
   (	"LOG_LEVEL" VARCHAR2(20), 
	"LOG_LEVEL_NO" VARCHAR2(20 CHAR), 
	"CREATED_BY" VARCHAR2(512 CHAR) DEFAULT COALESCE(sys_context('APEX$SESSION', 'APP_USER'), SYS_CONTEXT('CLIENTCONTEXT', 'apex_user_name'), USER), 
	"CREATED_ON" DATE DEFAULT SYSDATE, 
	"MODIFIED_BY" VARCHAR2(512 CHAR), 
	"MODIFIED_ON" DATE, 
	"LOV_LEVEL_NAME" VARCHAR2(50)
   ) ;

   COMMENT ON COLUMN "LOG_LEVEL"."LOG_LEVEL" IS 'Уровень логирования';
   COMMENT ON COLUMN "LOG_LEVEL"."LOG_LEVEL_NO" IS 'Числовое значение уровня логирования';
   COMMENT ON COLUMN "LOG_LEVEL"."CREATED_BY" IS 'Автор создания записи';
   COMMENT ON COLUMN "LOG_LEVEL"."CREATED_ON" IS 'Дата создания записи';
   COMMENT ON COLUMN "LOG_LEVEL"."MODIFIED_BY" IS 'Автор изменения записи';
   COMMENT ON COLUMN "LOG_LEVEL"."MODIFIED_ON" IS 'Дата изменения записи';
   COMMENT ON COLUMN "LOG_LEVEL"."LOV_LEVEL_NAME" IS 'Название уровня логирования на русском';
   COMMENT ON TABLE "LOG_LEVEL"  IS 'Уровни логирования для записи в журнал событий (LOG). Используется для регулирования количества записей, записываемых в журнал';
