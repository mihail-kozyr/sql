create or replace package rep as 

  /**
   * Пакет для репликации данных. Выполняет экспорт таблиц через DataPump
   *
   *
   * @author Mihail Kozyr
   * @version 1 (2022.01.13)
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
    * Основная процедура репликации - точка входа. 
    *
    * @param in_pipe имя канала DBMS_PIPE для обмена сообщениями
    */   
   PROCEDURE main(in_pipe IN VARCHAR2 DEFAULT NULL);

end rep;