CREATE OR REPLACE FUNCTION FNC_SFCQI8012_PID (PARTCD IN VARCHAR2, LOTNO IN VARCHAR2, PRODDATE IN VARCHAR2)
		RETURN NVARCHAR2
	AS
		/*========================================================================
Program name  : FNC_SFCQI8012
Description   :	RETURN PID
Spec          :
Programmer    : T.Wuttipong
Version	      : 09/02/2017
========================================================================*/
		CURSOR cursor_ IS
				SELECT
					DISTINCT QST60_PID
				FROM QSTMATSN
				WHERE QST60_PARTCD = PARTCD
						AND QST60_LOTNO = LOTNO
						AND QST60_PRODDATE = PRODDATE;

		QST60_PID VARCHAR2(1000) := '';
		type C_PID is varray (1000) of QSTMATSN.QST60_PID%type;
		PID_LIST C_PID := C_PID();
		couter integer := 0;
--		TYPE mytable_tt IS TABLE OF cursor_ %ROWTYPE INDEX BY PLS_INTEGER;
--		l_my_table_recs mytable_tt;
	BEGIN
		FOR MAT IN cursor_ LOOP
			couter := couter + 1;
			PID_LIST.extend;
			PID_LIST(couter) := MAT.QST60_PID;
		END LOOP;

		FOR indx IN 1 .. PID_LIST.COUNT
	    LOOP
	         --process each record.. via l_my_table_recs (indx)

			IF(indx <> PID_LIST.COUNT) THEN
				QST60_PID := CONCAT(QST60_PID , '''' || PID_LIST(indx) || ''',');
			ELSE
				QST60_PID := CONCAT(QST60_PID , '''' || PID_LIST(indx) || '''');
			END IF;

	    END LOOP;

--		OPEN cursor_;
--		LOOP
--			FETCH cursor_
--			BULK COLLECT INTO l_my_table_recs LIMIT 100;
--
--			DBMS_OUTPUT.PUT_LINE(QST60_PID);
--			FOR indx IN 1 .. l_my_table_recs.COUNT
--		    LOOP
--		         --process each record.. via l_my_table_recs (indx)
--
--				IF(indx <> l_my_table_recs.COUNT) THEN
--					QST60_PID := CONCAT(QST60_PID , '''' || PID_LIST(indx) || ''',');
--				ELSE
--					QST60_PID := CONCAT(QST60_PID , '''' || PID_LIST(indx) || '''');
--				END IF;
--
--		    END LOOP;
--
--			EXIT WHEN cursor_%NOTFOUND;
--		END LOOP;
--		CLOSE cursor_;
		RETURN QST60_PID;
--		DBMS_OUTPUT.PUT_LINE(QST60_PID);
	END;
