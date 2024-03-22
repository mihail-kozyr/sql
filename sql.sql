SELECT sql_text
    FROM v$sqltext_with_newlines
  WHERE hash_value = &1
ORDER BY piece
/
