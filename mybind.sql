SELECT u.username, s.*
  FROM v$sql s JOIN dba_users u ON (u.user_id = s.parsing_user_id)
 WHERE SUBSTR(sql_text, 1, 20) IN 
   (SELECT SUBSTR(sql_text, 1, 20)
     FROM v$sql
    GROUP BY SUBSTR(sql_text, 1, 20)
    HAVING COUNT(*) > 5)
/
