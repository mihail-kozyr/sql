CREATE OR REPLACE PROCEDURE
          send_mail (p_sender    IN VARCHAR2,
                     p_recipient IN VARCHAR2,
                     p_subject   IN VARCHAR2,
                     p_message   IN VARCHAR2,
                     p_smtp_svr  IN VARCHAR2 DEFAULT 'smtp-proxy.int.rdtex.ru')
as
   l_mail_conn utl_smtp.connection;
BEGIN
   l_mail_conn := utl_smtp.open_connection(p_smtp_svr,25);
   utl_smtp.helo(l_mail_conn, p_smtp_svr);
   utl_smtp.mail(l_mail_conn, p_sender);
   utl_smtp.rcpt(l_mail_conn, p_recipient);
   utl_smtp.open_data(l_mail_conn );
   
   /*Служебная инфа для автоперекодировщика*/
   utl_smtp.write_data(l_mail_conn, 'Content-Type: text/plain; charset=KOI8-R');   
   utl_smtp.write_data(l_mail_conn, utl_tcp.CRLF || 'Content-Transfer-Encoding: 8bit'); 
   
   /*Тема*/
   utl_smtp.write_raw_data(l_mail_conn, utl_raw.cast_to_raw(utl_tcp.CRLF || 'Subject : ' || CONVERT(p_subject,'CL8KOI8R')));
   
   	/*Само сообщение*/
   utl_smtp.write_raw_data(l_mail_conn, utl_raw.cast_to_raw(utl_tcp.CRLF || CONVERT(p_message,'CL8KOI8R')));
   utl_smtp.close_data(l_mail_conn );
   utl_smtp.quit(l_mail_conn);
END;
/

-- exec send_mail('q@q.ru', 'kozyr@rdtex.ru', 'This is a subject', 'Hello, Mike!')	
-- exec send_mail('q@q.ru', 'kozyr@rdtex.ru', 'Это, типа, тема', 'Превед, медвед!')	