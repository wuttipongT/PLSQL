/*
Oracle / PLSQL: Functions
A function is same as a procedure except that it returns a value. Therefore, 
all the discussions of the previous chapter are true for functions too.
*/

/* Example */
CREATE OR REPLACE FUNCTION SFCORCL.FNC_SFCQI8012_INVNO (PARTCD IN VARCHAR2, LOTNO IN VARCHAR2, PRODDATE IN VARCHAR2)
		RETURN NVARCHAR2
	AS
	/*========================================================================
	Program name  : FNC_SFCQI8012
	Description   :	RETURN INVNO
	Spec          :
	Programmer    : T.Wuttipong
	Version	      : 09/02/2017
	========================================================================*/
		CURSOR cursor_ IS
				SELECT
					DISTINCT QST60_INVNO
				FROM QSTMATSN
				WHERE QST60_PARTCD = PARTCD
						AND QST60_LOTNO = LOTNO
						AND QST60_PRODDATE = PRODDATE;

		QST60_INVNO VARCHAR2(1000) := '';
		type C_INVNO is varray (1000) of QSTMATSN.QST60_INVNO%type;
		INVNO_LIST C_INVNO := C_INVNO();
		couter integer := 0;
		TYPE mytable_tt IS TABLE OF cursor_ %ROWTYPE INDEX BY PLS_INTEGER;
		l_my_table_recs mytable_tt;
	BEGIN
		FOR MAT IN cursor_ LOOP
			couter := couter + 1;
			INVNO_LIST.extend;
			INVNO_LIST(couter) := MAT.QST60_INVNO;
		END LOOP;

		FOR indx IN 1 .. INVNO_LIST.COUNT
	    LOOP
	         --process each record.. via l_my_table_recs (indx)

			IF(indx <> INVNO_LIST.COUNT) THEN
				QST60_INVNO := CONCAT(QST60_INVNO , '''' || INVNO_LIST(indx) || ''',');
			ELSE
				QST60_INVNO := CONCAT(QST60_INVNO , '''' || INVNO_LIST(indx) || '''');
			END IF;

	    END LOOP;
--		OPEN cursor_;
--		LOOP
--			FETCH cursor_
--			BULK COLLECT INTO l_my_table_recs LIMIT 100;
--
--			FOR indx IN 1 .. l_my_table_recs.COUNT
--		    LOOP
--		         --process each record.. via l_my_table_recs (indx)
--
--				IF(indx <> l_my_table_recs.COUNT) THEN
--					QST60_INVNO := CONCAT(QST60_INVNO , '''' || INVNO_LIST(indx) || ''',');
--				ELSE
--					QST60_INVNO := CONCAT(QST60_INVNO , '''' || INVNO_LIST(indx) || '''');
--				END IF;
--
--		    END LOOP;
--
--			EXIT WHEN cursor_%NOTFOUND;
--		END LOOP;
--		CLOSE cursor_;
		RETURN QST60_INVNO;
--		DBMS_OUTPUT.PUT_LINE(QST60_PID);
	END;
