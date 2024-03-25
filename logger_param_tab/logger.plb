create or replace TYPE BODY LOGGER AS
/**
 * ������ ��� �������������� �������� � �������
 * ��� �������������� ������� � ���������� ������������ ������� �������� 
 * LOG. � ������ ������� ������������� �������� ��� ������� 
 * �������, ������ ������� ����������� � ���� ������, PL/SQL, Java
 *
 * @headcom
 * 
 */


   /** ����������� ��� ������������� �������
    *
    * @param p_task_code -  ��� ������
    * @param p_table_name -  ��� �������
    */

    CONSTRUCTOR FUNCTION LOGGER(
      SELF IN OUT NOCOPY LOGGER,
      p_task_code IN VARCHAR2 DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT 
    IS
    BEGIN
        --self.id := log_seq.nextval;
        self.task_code := p_task_code;
        self.table_name := p_table_name;
        SELECT NVL(MAX(UPPER(val)), 'DEBUG') INTO self.log_level FROM params WHERE param = 'LOG_LEVEL';
        SELECT log_level_no INTO self.level_no FROM log_level WHERE log_level = self.log_level;
        RETURN;
    END LOGGER;


   /* ����� ������� ������������ ��������� 
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����  
    */
    MEMBER PROCEDURE critical(
      p_message VARCHAR2 DEFAULT NULL,
      p_code VARCHAR2 DEFAULT NULL,
      p_procedure_name  VARCHAR2 DEFAULT NULL,
      p_error_line VARCHAR2 DEFAULT NULL,
      p_note VARCHAR2 DEFAULT NULL,
      p_error_backtrace VARCHAR2 DEFAULT NULL,
      p_long_message IN CLOB DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL
     )
    IS
        -- �������� ��������� �� ������ 4� ����
        msg VARCHAR2(4000) := SUBSTRB(p_message, 1, 4000); 
        large_msg CLOB;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        IF self.level_no <= 50 THEN
            DBMS_OUTPUT.PUT_LINE(p_message);

            IF LENGTHB(p_message) > 4000 THEN
                large_msg := p_message;
            END IF;

            INSERT INTO log(
                task_code, 
                log_level, 
                message, 
                error_code, 
                procedure_name, 
                error_line, 
                note, 
                error_backtrace, 
                long_message,
                table_name) 
              VALUES(
                  self.task_code, 
                  'CRITICAL', 
                  msg, 
                  p_code, 
                  p_procedure_name,
                  p_error_line, 
                  p_note, 
                  p_error_backtrace, 
                  NVL(p_long_message, large_msg),
                  NVL(p_table_name, self.table_name)
                     );
            COMMIT WORK;             
        END IF;
    END critical;



  /** ����� ������� ��������� �� ������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    */
    MEMBER PROCEDURE error(
      p_message VARCHAR2 DEFAULT NULL,
      p_code VARCHAR2 DEFAULT NULL,
      p_procedure_name  VARCHAR2 DEFAULT NULL,
      p_error_line VARCHAR2 DEFAULT NULL,
      p_note VARCHAR2 DEFAULT NULL,
      p_error_backtrace VARCHAR2 DEFAULT NULL,
      p_long_message IN CLOB DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL
      )
    IS
        l_event_type VARCHAR2(255);
        l_table_name VARCHAR2(255);
        log_template VARCHAR2(4000);        
        -- �������� ��������� �� ������ 4� ����
        msg VARCHAR2(4000) := SUBSTRB(p_message, 1, 4000);
        l_machine varchar2(4000);
        l_event_code varchar2(4000);
        l_arm varchar2(4000);
        large_msg CLOB;

        l_sec_level varchar2(200);
        l_sec_username VARCHAR2(256);

        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF self.level_no <= 40 THEN
            DBMS_OUTPUT.PUT_LINE(p_message);

            IF LENGTHB(p_message) > 4000 THEN
                large_msg := p_message;
            END IF;

            INSERT INTO log(
                task_code, 
                log_level, 
                message, 
                error_code, 
                procedure_name, 
                error_line, 
                note, 
                error_backtrace, 
                long_message,
                table_name) 
              VALUES(
                  self.task_code, 
                  'ERROR', 
                  msg, 
                  p_code, 
                  p_procedure_name,
                  p_error_line, 
                  p_note, 
                  p_error_backtrace, 
                  NVL(p_long_message, large_msg),
                  NVL(p_table_name, self.table_name)                  
                     );
            COMMIT WORK;
        END IF;
    END error;


   /* ����� ������� ��������������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����        
    */ 
    MEMBER PROCEDURE warning(
      p_message VARCHAR2 DEFAULT NULL,
      p_code VARCHAR2 DEFAULT NULL,
      p_procedure_name  VARCHAR2 DEFAULT NULL,
      p_error_line VARCHAR2 DEFAULT NULL,
      p_note VARCHAR2 DEFAULT NULL,
      p_error_backtrace VARCHAR2 DEFAULT NULL,
      p_long_message IN CLOB DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL      
     )
    IS
        -- �������� ��������� �� ������ 4� ����
        msg VARCHAR2(4000) := SUBSTRB(p_message, 1, 4000);
        large_msg CLOB;
        PRAGMA AUTONOMOUS_TRANSACTION;
     BEGIN
         IF self.level_no <= 30 THEN
             DBMS_OUTPUT.PUT_LINE(p_message);

             IF LENGTHB(p_message) > 4000 THEN
                 large_msg := p_message;
             END IF;

            INSERT INTO log(
                task_code, 
                log_level, 
                message, 
                error_code, 
                procedure_name, 
                error_line, 
                note, 
                error_backtrace, 
                long_message,
                table_name) 
              VALUES(
                  self.task_code, 
                  'WARNING', 
                  msg, 
                  p_code, 
                  p_procedure_name,
                  p_error_line, 
                  p_note, 
                  p_error_backtrace, 
                  NVL(p_long_message, large_msg),
                  NVL(p_table_name, self.table_name)                  
                     );
            COMMIT WORK;
         END IF;
    END warning;

  /** ����� ������� ��������������� ���������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    */  
    MEMBER PROCEDURE info(
      p_message VARCHAR2 DEFAULT NULL,
      p_code VARCHAR2 DEFAULT NULL,
      p_procedure_name  VARCHAR2 DEFAULT NULL,
      p_error_line VARCHAR2 DEFAULT NULL,
      p_note VARCHAR2 DEFAULT NULL,
      p_error_backtrace VARCHAR2 DEFAULT NULL,
      p_long_message IN CLOB DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL      
     )      
    IS
        l_table_name VARCHAR2(255);
        -- �������� ��������� �� ������ 4� ����
        msg VARCHAR2(4000) := SUBSTRB(p_message, 1, 4000);
        l_machine varchar2(4000);
        large_msg CLOB;


        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF self.level_no <= 20 THEN
            DBMS_OUTPUT.PUT_LINE(p_message);


            IF LENGTHB(p_message) > 4000 THEN
                 large_msg := p_message;
            END IF;

            INSERT INTO log(
                task_code, 
                log_level, 
                message, 
                error_code, 
                procedure_name, 
                error_line, 
                note, 
                error_backtrace, 
                long_message,
                table_name) 
              VALUES(
                  self.task_code, 
                  'INFO', 
                  msg, 
                  p_code, 
                  p_procedure_name,
                  p_error_line, 
                  p_note, 
                  p_error_backtrace, 
                  NVL(p_long_message, large_msg),
                  NVL(p_table_name, self.table_name)                  
                     )
                RETURNING ID into self.id;
            COMMIT WORK;
        END IF;
    END info;


   /* ����� ������� ��������� ��� �������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    */   
    MEMBER PROCEDURE debug(
      p_message VARCHAR2 DEFAULT NULL,
      p_code VARCHAR2 DEFAULT NULL,
      p_procedure_name  VARCHAR2 DEFAULT NULL,
      p_error_line VARCHAR2 DEFAULT NULL,
      p_note VARCHAR2 DEFAULT NULL,
      p_error_backtrace VARCHAR2 DEFAULT NULL,
      p_long_message IN CLOB DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL      
     )
    IS
        -- ���������, ���������� �� 4�
        msg VARCHAR2(4000) := SUBSTRB(p_message, 1, 4000);
        large_msg CLOB;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF self.level_no <= 10 THEN
            DBMS_OUTPUT.PUT_LINE(msg);

            IF LENGTHB(p_message) > 4000 THEN
                large_msg := p_message;
            END IF;

            INSERT INTO log(
                task_code, 
                log_level, 
                message, 
                error_code, 
                procedure_name, 
                error_line, 
                note, 
                error_backtrace, 
                long_message,
                table_name) 
              VALUES(
                  self.task_code, 
                  'DEBUG', 
                  msg, 
                  p_code, 
                  p_procedure_name,
                  p_error_line, 
                  p_note, 
                  p_error_backtrace, 
                  NVL(p_long_message, large_msg),
                  NVL(p_table_name, self.table_name)
                     );
            COMMIT WORK;
        END IF;
    END debug;

END ;