--------------------------------------------------------
--  Constraints for Table LOG_LEVEL
--------------------------------------------------------

  ALTER TABLE "LOG_LEVEL" MODIFY ("LOG_LEVEL" NOT NULL ENABLE);
  ALTER TABLE "LOG_LEVEL" ADD CONSTRAINT "LOG_LEVEL_PK" PRIMARY KEY ("LOG_LEVEL")
  USING INDEX  ENABLE;
