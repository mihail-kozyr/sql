REM ------------------------------------------------------------------------ 
REM AUTHOR:  
REM    Michael Kozyr, RDTeX
REM    (c)2005 by RDTeX
REM ------------------------------------------------------------------------ 
REM PURPOSE: 
REM    Find diferences between work, archive, temp, and transit 
REM    GXP_SCADA_MESASURES 
REM ------------------------------------------------------------------------ 
REM EXAMPLE: 
REM                         Redo Log Summary 
REM 
REM    Size  
REM    Group                    Member            Archived  Status  (MB) 
REM    ----- ------------------------------------ -------- -------- ---- 
REM        1 /u02/oracle/V7.1.6/dbs/log1V716.dbf      NO   INACTIVE  10 
REM        2 /u02/oracle/V7.1.6/dbs/log2V716.dbf      NO   INACTIVE  10 
REM        3 /u02/oracle/V7.1.6/dbs/log3V716.dbf      NO   CURRENT   10 
REM  
REM ------------------------------------------------------------------------ 

CREATE GLOBAL TEMPORARY TABLE scm_deferences
( attr VARCHAR2(100)
 ,WORK VARCHAR2(1)
 ,arch VARCHAR2(1)
 ,temp VARCHAR2(1)
)
ON COMMIT DELETE ROWS;

SET serveroutput ON  

DECLARE
  TYPE DiffCur IS REF CURSOR RETURN scm_deferences%ROWTYPE;
  
  							  
  l_dif_record scm_deferences%ROWTYPE;
  l_diff_cv DiffCur; 

   
  PROCEDURE Deferences(p_cv IN OUT DiffCur, p_choice IN NUMBER)
  IS
  BEGIN
    -- Columns which exists in work table and don't exist in archive table
    IF p_choice = 1 THEN
      OPEN p_cv FOR 
        SELECT 'Column ' || column_name, 'Y' WORK, 'N' arch, NULL temp
        FROM (
	        SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES'
            AND owner = 'IUS'
            MINUS
            SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES'
            AND owner = 'SCADA_ARCH');
  -- Columns which exists in archive table and don't exist in work table          
    ELSIF p_choice = 2 THEN
      OPEN p_cv FOR 
        SELECT 'Column ' || column_name, 'N' WORK, 'Y' arch, NULL temp
        FROM (
	        SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES'
            AND owner = 'SCADA_ARCH'
            MINUS
            SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES'
            AND owner = 'IUS');
    -- Columns which exists in work table and don't exist in temporary table            
    ELSIF p_choice = 3 THEN
      OPEN p_cv FOR 
      SELECT 'Column ' || column_name, 'Y' WORK, NULL arch, 'N' temp
        FROM (
	        SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES'
            AND owner = 'IUS'
            MINUS
            SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES_TEMP'
            AND owner = 'SCADA_ARCH');    
    -- Columns which exists in temporary table and don't exist in work table
    ELSIF p_choice = 4 THEN
      OPEN p_cv FOR 
      SELECT 'Column ' || column_name, 'N' WORK, NULL arch, 'Y' temp
        FROM (
	        SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES_TEMP'
            AND owner = 'SCADA_ARCH'
            MINUS
            SELECT column_name
            FROM all_tab_columns
            WHERE table_name = 'GXP_SCADA_MEASURES'
            AND owner = 'IUS');                
    END IF;
  END Deferences;
  
BEGIN
  -- Loop by 
  FOR j IN 1.. 4 LOOP 
     -- Open a cursor variable
    Deferences(l_diff_cv, j);
    -- Loop by cursor variablable's values
    LOOP 
      FETCH l_diff_cv INTO l_dif_record;
      EXIT WHEN l_diff_cv%NOTFOUND;      
      -- Populate temporary table
      DBMS_OUTPUT.put_line(l_dif_record.attr);
      MERGE INTO scm_deferences s
      USING (SELECT l_dif_record.attr attr FROM dual) s2
      ON (s.attr = s2.attr)
      WHEN MATCHED THEN
        UPDATE SET WORK = NVL(l_dif_record.work, s.work),
		s.arch = NVL(l_dif_record.arch, s.arch),
		s.temp = NVL(l_dif_record.temp, s.temp)
       WHEN NOT MATCHED THEN
        INSERT(attr, work, arch, temp) 
		VALUES (s2.attr, l_dif_record.work, l_dif_record.arch, l_dif_record.temp);

    END LOOP; -- cursor variable
  END LOOP; -- verificators
  
END;
/

-- Print the result of comparison
SELECT * FROM  scm_deferences;

-- Clear temporary table
COMMIT;

-- Drop temporary table
DROP TABLE scm_deferences;

