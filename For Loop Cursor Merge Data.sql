/*
Ex.
*/
CREATE OR REPLACE PROCEDURE sp_SPECIALCLOSE(PACKAGEID_NEW IN VARCHAR2, PACKAGEID_BEBORE IN VARCHAR2, HDID_NEW IN VARCHAR2, HDID_BEBORE IN VARCHAR2)
/*========================================================================
Program name  : SPECIALCLOSE
Description   :	CALCULATE PALET AND CARTON FOR HDD TO FACTORY
Spec          :
Programmer    : T.Wuttipong
Version	      : 02/02/2017
========================================================================*/
AS
  edasn SFCMCUPC.SFC80_EDASN%type;
  type c_edasn is varray (4)  of SFCMCUPC.SFC80_EDASN%type;
  sn_list c_edasn := c_edasn();
  couter integer := 0;
  qty integer := 0;
  CURSOR cursor_ is
    SELECT SFC80_EDASN FROM SFCMCUPC WHERE SFC80_PACKAGEID = PACKAGEID_NEW; ---'FANQB0703S'
  CURSOR cursor_2 is
    SELECT SFCPS_DATA, SFCPS_VALUE FROM SFC_PRINTSV_DT WHERE SFCPS_HDID = HDID_BEBORE; --'201701090718340076A';
BEGIN
--  OPEN cursor_;
--  LOOP
--    FETCH cursor_ INTO edasn;
--    EXIT WHEN cursor_%notfound;
--    dbms_output.put_line(edasn);
--  END LOOP;
--  CLOSE cursor_;

FOR sn IN cursor_ LOOP
  couter := couter + 1;
  sn_list.extend;
  sn_list(couter) := sn.SFC80_EDASN;
END LOOP;

SAVEPOINT start_tran;
MERGE INTO SFC_PRINTSV_HD hd 
  USING(
      SELECT
        HDID_NEW AS SFCPS_DOCID, --'2017010907183400bed'
        SFCPS_SERVERID,
        SFCPS_DOCNAME,
        SFCPS_SENDER,
        'N' AS SFCPS_FLAGPRINT,
        SFCPS_REQUSER,
        SFCPS_DOCTYPE,
        PACKAGEID_NEW AS SFCPS_DOCDATA --'FANQB0703S'
      FROM SFC_PRINTSV_HD
      WHERE SFCPS_DOCDATA = PACKAGEID_BEBORE --'FANQB0703G'
    ) tmp
    ON (
      hd.SFCPS_DOCDATA = tmp.SFCPS_DOCDATA
      )
    WHEN NOT MATCHED THEN
    INSERT (
					hd.SFCPS_DOCID,
					hd.SFCPS_SERVERID,
					hd.SFCPS_DOCNAME,
					hd.SFCPS_SENDER,
					hd.SFCPS_FLAGPRINT,
					hd.SFCPS_RECDATE,
					hd.SFCPS_REQUSER,
					hd.SFCPS_DOCTYPE,
					hd.SFCPS_DOCDATA
				) VALUES (
					tmp.SFCPS_DOCID,
					tmp.SFCPS_SERVERID,
					tmp.SFCPS_DOCNAME,
					tmp.SFCPS_SENDER,
					tmp.SFCPS_FLAGPRINT,
					sysdate,
					tmp.SFCPS_REQUSER,
					tmp.SFCPS_DOCTYPE,
					tmp.SFCPS_DOCDATA);

FOR cur IN cursor_2 LOOP
--  DBMS_OUTPUT.PUT_LINE(cur.SFCPS_DATA);
  INSERT INTO SFCORCL.SFC_PRINTSV_DT (SFCPS_HDID, SFCPS_DATA, SFCPS_VALUE) SELECT HDID_NEW /*'2017010907183400bed'*/, cur.SFCPS_DATA, cur.SFCPS_VALUE FROM DUAL;
END LOOP;

FOR i IN 1..4 LOOP
--DBMS_OUTPUT.PUT_LINE(sn_list.COUNT);
IF (i <= sn_list.COUNT) THEN
 MERGE INTO SFCORCL.SFC_PRINTSV_DT dt using(
  SELECT sn_list(i) AS SFCPS_VALUE,
         CONCAT( 'T', i ) AS SFCPS_DATA
  FROM DUAL
 ) tmp
 ON (
  dt.SFCPS_HDID = HDID_NEW AND dt.SFCPS_DATA = tmp.SFCPS_DATA
 )
 WHEN MATCHED THEN
 UPDATE SET dt.SFCPS_VALUE = tmp.SFCPS_VALUE;
ELSE
  MERGE INTO SFCORCL.SFC_PRINTSV_DT dt using(
  SELECT
         CONCAT( 'T', i ) AS SFCPS_DATA
  FROM DUAL
 ) tmp
 ON (
  dt.SFCPS_HDID = HDID_NEW AND dt.SFCPS_DATA = tmp.SFCPS_DATA
 )
 WHEN MATCHED THEN
 UPDATE SET dt.SFCPS_VALUE = NULL;
END IF;
END LOOP;

qty := sn_list.COUNT;
UPDATE SFCORCL.SFC_PRINTSV_DT SET SFCPS_VALUE = qty WHERE SFCPS_HDID = HDID_NEW AND SFCPS_DATA = 'H';

COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_tran;
    RAISE;
--DBMS_OUTPUT.put_line(sn_list(2));
END;
