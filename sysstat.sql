SET SERVEROUTPUT ON
DECLARE
  STATUS VARCHAR2(20);
  DSTART DATE;
  DSTOP DATE;
  PVALUE NUMBER;
  PNAME VARCHAR2(30);
BEGIN
  PNAME := 'cpuspeed';
  DBMS_STATS.GET_SYSTEM_STATS(status, dstart, dstop, pname, pvalue, stattab => 
  'mystats', statid => 'TEST', statown => 'SYSTEM');
  DBMS_OUTPUT.PUT_LINE('status                      : '||status);
  DBMS_OUTPUT.PUT_LINE('cpu in mhz                  : '||pvalue);
  PNAME := 'sreadtim';
  DBMS_STATS.GET_SYSTEM_STATS(status, dstart, dstop, pname, pvalue, stattab => 
  'mystats', statid => 'TEST', statown => 'SYSTEM');
  DBMS_OUTPUT.PUT_LINE('single block readtime in ms : '||pvalue);
  PNAME := 'mreadtim';
  DBMS_STATS.GET_SYSTEM_STATS(status, dstart, dstop, pname, pvalue, stattab => 
  'mystats', statid => 'TEST', statown => 'SYSTEM');
  DBMS_OUTPUT.PUT_LINE('multiblock readtime in ms   : '||pvalue);
  PNAME := 'mbrc';
  DBMS_STATS.GET_SYSTEM_STATS(status, dstart, dstop, pname, pvalue, stattab => 
  'mystats', statid => 'TEST', statown => 'SYSTEM');
  DBMS_OUTPUT.PUT_LINE('average multiblock readcount: '||pvalue);
END;
/   
