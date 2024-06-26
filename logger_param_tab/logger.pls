create or replace TYPE LOGGER force AS OBJECT(

/**
 * ������ ��� �������������� �������� � �������
 * ��� �������������� ������� � ���������� ������������ ������� �������� 
 * LOG. � ������ ������� ������������� �������� ��� ������� 
 * �������, ������ ������� ����������� � ���� ������, PL/SQL, Java
 *
 * @headcom
 */


    -- �������� ������
    id NUMBER, -- ������������� ������ �������
    task_code VARCHAR2(128 CHAR), -- ��� ������
    log_level VARCHAR2(8), -- CRITICAL, ERROR, WARNING, INFO, DEBUG
    level_no NUMBER, -- ������� �������������� � �������� �������������
    table_name VARCHAR2(128), -- ��� �������


   /** ����������� ��� ������������� �������
    *
    * @param p_task_code -  ��� ������
    * @param p_table_name -  ��� �������    
    */
    CONSTRUCTOR FUNCTION LOGGER(
      SELF IN OUT NOCOPY LOGGER,
      p_task_code IN VARCHAR2 DEFAULT NULL,
      p_table_name IN VARCHAR2 DEFAULT NULL
    ) RETURN SELF AS RESULT,    

  /** ����� ������� ������������ ��������� 
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    * @param p_table_name -  ��� �������     
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
     ),


  /** ����� ������� ��������� �� ������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    * @param p_table_name -  ��� �������     
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
      ),



  /** ����� ������� ��������������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    * @param p_table_name -  ��� �������     
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
     ),



  /** ����� ������� ���������������� ���������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    * @param p_table_name -  ��� �������     
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
     ),


   /* ����� ������� ��������� ��� �������
    * @param p_message - ����� ���������
    * @param p_code - ��� ����������� ������
    * @param p_procedure_name - �������� ������, ���������� ������
    * @param p_error_line - ����� ������ � �������
    * @param p_note - ����������
    * @param p_error_backtrace - ���� ��������� �� ������
    * @param p_long_message - ��������� �������� �������, ����������� 32K ����
    * @param p_table_name -  ��� �������     
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


) NOT FINAL;
/