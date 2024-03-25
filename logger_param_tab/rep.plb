create or replace PACKAGE BODY rep_imp 
IS
    /**
    * Процедура получения сообщений из именованного канала
    *
    * @param in_pipe         - имя трубы
    */ 
    PROCEDURE receive_output(
        in_pipe IN VARCHAR2)
    IS
        v_result INTEGER;
        v_msg    VARCHAR2(4000);
        v_error_msg    VARCHAR2(32767);
        v_pct    NUMBER;



    BEGIN
        -- ждём сообщение 2 секунды
        v_result := dbms_pipe.receive_message(
                       pipename => in_pipe,
                       timeout  => 2);

        IF v_result = 0 THEN
            dbms_pipe.unpack_message(v_msg);
            dbms_pipe.unpack_message(v_pct);
            dbms_pipe.unpack_message(v_error_msg);

            IF v_msg IS NOT NULL THEN
                dbms_output.put_line(v_msg);
            END IF;
            IF v_pct IS NOT NULL THEN
                dbms_output.put_line('*** Job percent done = '||v_pct);
            END IF;
            IF v_error_msg IS NOT NULL THEN
                dbms_output.put_line('Error occured'||v_error_msg);
            END IF;            
        ELSE
            IF v_result = 1 Then
                dbms_output.put_line('Timeout limit exceeded!');
            ELSE
                raise_application_error(-20002, 'error receiving message pipe: '||v_result);
            END IF;
        END IF;

    END receive_output;

   /**
    * Процедура удаления именованного канала DBMS_PIPE
    * @param pipename  - имя канала
    */
    PROCEDURE remove_pipe(pipename IN VARCHAR2)
    IS
        r NUMBER;
    BEGIN
        r := DBMS_PIPE.REMOVE_PIPE(pipename);
    END remove_pipe;

    /**
    * Процедура для отправки сообщений о работе задания Data Pump
    * в именованный канал DBMS_PIPE. Каналс двумя полями
    *  - сообщение Data Pump
    *  - процент завершения заданьица
    *
    * @param in_pipe         - имя трубы
    * @param in_msg          - текст сообщения об экспорте
    * @param in_pct_complete - процент завершения задания
    * @param in_error_msg    - сообщение об ошибке
    */ 
    PROCEDURE send_output(
        in_pipe         IN VARCHAR2, 
        in_msg          IN VARCHAR2 DEFAULT NULL, 
        in_pct_complete IN NUMBER DEFAULT NULL,
        in_error_msg    IN VARCHAR2 DEFAULT NULL) 
    IS
        v_status NUMBER;
    BEGIN
        IF in_pipe IS NULL THEN
            RETURN;
        END IF;
        dbms_pipe.pack_message(in_msg);
        dbms_pipe.pack_message(in_pct_complete);
        dbms_pipe.pack_message(in_error_msg);

        v_status := dbms_pipe.send_message(in_pipe);
        IF v_status != 0 then
            raise_application_error(-20001, '!! message pipe error !!');
        END IF;
    END send_output;


   /** 
    * Основная процедура для импорта данных - точка входа. 
    *
    * @param in_pipe имя канала DBMS_PIPE для обмена сообщениями    
    */

    PROCEDURE main(in_pipe IN VARCHAR2 DEFAULT NULL)
    IS
        ind             NUMBER;            -- переменная цикла
        handle          NUMBER;            -- ручка от помпы Oracle Data Pump
        percent_done    NUMBER := 0;       -- процент завершения
        job_state       VARCHAR2(30);      -- монторинг состояния задания
        le              ku$_LogEntry;      -- журналы и сообщения об ошибке
        js              ku$_JobStatus;     -- статус задания для get_status
        jd              ku$_JobDesc;       -- описание задания из get_status
        sts             ku$_Status;        -- статус задания, возвращаемый get_status

    
        -- логгер с task_code=<пакет>.<рутина>
        log logger := NEW logger(
                        utl_call_stack.subprogram(1)(1)||'.'||
                        utl_call_stack.subprogram(1)(2));

        -- каталог экспортного файла
        dir VARCHAR2(128);
        -- имя задания экспорта
        exp_job_name CONSTANT VARCHAR2(30) := 'REPEXP';        
        -- имя экспортного файла 
        fname VARCHAR2(256) := 'vsms_trans_'||TO_CHAR(SYSDATE, 'yyyymmddhh24mi');
                result NUMBER;
    BEGIN
        log.info('Start');

        -- получаем handler для задания экспорта таблиц DataPump 
        handle := dbms_datapump.open('EXPORT', 'TABLE', NULL, exp_job_name, 'LATEST');
        log.debug('Handler has initiated');

        SELECT val
          INTO dir
          FROM params
         WHERE param = 'EXPORT_DIRECTORY';

        log.debug('DataPump Export Dir='||dir);  
        -- создаём pipe для интерактивного обмена сообщениями вывода при экспорте DataPump
        IF in_pipe IS NOT NULL THEN
            result := dbms_pipe.create_pipe(pipename => in_pipe, maxpipesize => 65536, private => true);
            IF result != 0 THEN
                raise_application_error(-20010, 'Ошибка создания канала DBMS_PIPE с кодом:'||result);
            END IF;
        END IF;

        -- задаём имя экспортного dmp-файла. Если файл существует, перезаписываем
        dbms_datapump.add_file(
            handle, 
            fname, 
            dir, 
            reusefile => 1);

        -- задаём  журнал экспорта
        dbms_datapump.add_file(
            handle, 
            fname, 
            dir, 
            filetype=>dbms_datapump.ku$_file_type_log_file);

        -- задаём схему для экспорта как схему собственника этого пакета
        dbms_datapump.metadata_filter(handle, 'SCHEMA_EXPR', q'[IN ('USVISTA')]');

        -- CONTENT = DATA_ONLY, т.е. экспортируем только данные, без метаданных
        dbms_datapump.set_parameter(handle => handle, name => 'INCLUDE_METADATA', value => 0);

        -- экспортируем только таблицу VSMS_TRANS
        dbms_datapump.metadata_filter(handle, 'NAME_EXPR', q'[IN('VSMS_TRANS')]');

        -- запускаем задание
        dbms_datapump.start_job(handle);
        log.debug('DataPump Jub has been run.');
        -- Задание в данный момент выполняется. Следующий цикл следит за заданием
        -- пока оно не завершится. Попутно выполняется отображение информации о 
        -- прогрессе выполнения.
        job_state := 'UNDEFINED';
        WHILE (job_state != 'COMPLETED') AND (job_state != 'STOPPED') 
        LOOP
            dbms_datapump.get_status(handle,
               dbms_datapump.ku$_status_job_error +
               dbms_datapump.ku$_status_job_status +
               dbms_datapump.ku$_status_wip,-1,job_state,sts);
            js := sts.job_status;

            -- Если процент выполнения изменился, отображаем новое значение
            IF js.percent_done > percent_done THEN
                percent_done := js.percent_done;
                -- отправляем новый процент выполнения в трубу
                IF in_pipe IS NOT NULL THEN
                    send_output(in_pipe, in_pct_complete=>percent_done);
                END IF;
            END IF;

            -- Если получено к.л. сообщение work-in-progress (WIP) или сообщение об ошибке по заданию,
            -- отображаем его.
            IF (bitand(sts.mask,dbms_datapump.ku$_status_wip) != 0) THEN
                le := sts.wip;
            ELSE
                IF (bitand(sts.mask,dbms_datapump.ku$_status_job_error) != 0) THEN
                    le := sts.error;
                ELSE
                    le := NULL;
                END IF;
            END IF;

            IF le IS NOT NULL THEN
                ind := le.FIRST;
                WHILE ind IS NOT NULL 
                LOOP
                    log.info(le(ind).LogText);
                    IF in_pipe IS NOT NULL THEN
                        -- изображаем прогресс
                        IF percent_done < 15 THEN
                            percent_done := 15;
                        ELSIF percent_done < 70 THEN
                            percent_done := percent_done + 5;
                        ELSIF percent_done < 98 THEN
                            percent_done := percent_done + 1;
                        END IF;
                        send_output(in_pipe, in_msg=>le(ind).LogText,in_pct_complete=>percent_done);
                    END IF;
                    ind := le.NEXT(ind);
                END LOOP;
            END IF;
        END LOOP;

        -- Сообщаем, что задания отработало и отсоединяемся от него.

        dbms_output.put_line('Job has completed');
        dbms_output.put_line('Final job state = ' || job_state);
        dbms_datapump.detach(handle);

        -- удаляем дамп и журнал из каталога через час, чтобы не засорял диск
       DBMS_SCHEDULER.CREATE_JOB( 
        job_name   => 'rep_exp_cleaner_'||rep.NEXTVAL,
        job_type   => 'PLSQL_BLOCK',
        job_action => 'utl_file.fremove('''||DIR||''','''||fname||'.dmp'');
                       utl_file.fremove('''||DIR||''','''||fname||'.log'');',
       start_date => SYSTIMESTAMP + INTERVAL '1' HOUR,
       auto_drop => TRUE, -- для отладки отключить автоудаление
       enabled   => TRUE
       );
        -- очищаем таблицу со списком идентификаторов для экспорта
        --DELETE FROM ffa_exp_imp_ids WHERE export_id = l_export_id;
        COMMIT;
        
        log.info('End');
    END main;

END rep_exp;