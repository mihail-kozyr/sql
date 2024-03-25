create or replace package rep_imp as 

  /**
   * Пакет для репликации данных. Выполняет импорт таблиц через DataPump
   *
   *
   * @author Mihail Kozyr
   * @version 1 (2022.01.18)
   * @headcom
   */ 
   
   /**
    * Процедура получения сообщений из именованного канала
    *
    * @param in_pipe         - имя трубы
    */ 
    PROCEDURE receive_output(in_pipe IN VARCHAR2);   

   /**
    * Процедура удаления именованного канала DBMS_PIPE
    * @param pipename  - имя канала
    */
    PROCEDURE remove_pipe(pipename IN VARCHAR2);
    
   /** 
    * Процедура импорта данных через утилиту Oracle Data Pump
    *
    * @param in_file_name имя файла импорта DataPump
    * @param in_pipe имя канала DBMS_PIPE для обмена сообщениями
    */   
   PROCEDURE imp(
      in_file_name IN VARCHAR2,
      in_pipe IN VARCHAR2 DEFAULT NULL);
      
   /** 
    * Процедура инкрементального обновления таблицы VSMS_TRANS
    *
    * @param in_strategy - стратегия обновления: NOT_EXISTS, MINUS
    * @in_mode - режим работы процедуры
    *     RUN - рабочий режим, запускающий команды на исполнение 
    *     SIM - режим симулации, выводящий только тексты команд на экран   
    
    */   
   PROCEDURE vsms_trans_iu(
      in_file_name IN VARCHAR2,
      in_pipe IN VARCHAR2 DEFAULT NULL);      

end rep_imp;