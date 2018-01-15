DECLARE
TYPE t_ref_cursor IS REF CURSOR RETURN VIEW_SFCCWWN%ROWTYPE;
c_cursor t_ref_cursor;
rec c_cursor%ROWTYPE;
cwwn_table SFCCWWN_TABLE_T := SFCCWWN_TABLE_T();
indx INTEGER := 0;
v_length INTEGER := 0;
v_min SFCCWWN.SFCA_WWN%TYPE;
v_max SFCCWWN.SFCA_WWN%TYPE;
wwn SFCCWWN.SFCA_WWN%TYPE;
v_File_Handle UTL_FILE.FILE_TYPE;
--r -- read text, w -- write text, a -- append text, rb -- read byte mode, wb -- write byte mode, ab -- append byte mode
BEGIN
	v_File_Handle := UTL_FILE.FOPEN('SFC', 'GW33_W_' || to_char(sysdate, 'yyyymmddHH24MISS') || '.LOG', 'a');
	OPEN c_cursor FOR
		SELECT * FROM VIEW_SFCCWWN;
	LOOP
		FETCH c_cursor INTO rec;
		EXIT WHEN c_cursor%NOTFOUND;
		
		IF(rec.SFCA_REF1 IS NULL) THEN
			indx := indx + 1;
			cwwn_table.extend;
			cwwn_table(indx) := new CWWN_T(
			 	rec.SFCA_WWN,
			 	rec.SFCA_REF1,
			 	rec.SFCA_REF2,
			 	rec.SFCA_ASSODATE
			 );
			
		ELSE
		
			SELECT COUNT(*) INTO v_length FROM TABLE(cwwn_table);
			IF(v_length > 0) THEN
				SELECT MIN(SFCA_WWN), MAX(SFCA_WWN) INTO v_min, v_max FROM TABLE(cwwn_table);
--				SELECT TO_NUMBER(MIN(SFCA_WWN),'XXXXXXXXXXXXXXXX')-5764975786582867967, TO_NUMBER(MAX(SFCA_WWN),'XXXXXXXXXXXXXXXX')-5764975786582867967 INTO v_min, v_max FROM TABLE(cwwn_table);
				--Instead, insert into a table or write to a log file
--				DBMS_OUTPUT.PUT_LINE(v_min || ' ' || v_max);
				UTL_FILE.PUT_LINE(v_File_Handle, v_min || ' ' || v_max);
			END IF;

			cwwn_table := SFCCWWN_TABLE_T();
			indx := 0;

		END IF;

	END LOOP;
	CLOSE c_cursor;

	SELECT COUNT(*) INTO v_length FROM TABLE(cwwn_table);
	IF(v_length > 0) THEN
		SELECT MIN(SFCA_WWN), MAX(SFCA_WWN) INTO v_min, v_max FROM TABLE(cwwn_table);
--		SELECT TO_NUMBER(MIN(SFCA_WWN),'XXXXXXXXXXXXXXXX')-5764975786582867967, TO_NUMBER(MAX(SFCA_WWN),'XXXXXXXXXXXXXXXX')-5764975786582867967 INTO v_min, v_max FROM TABLE(cwwn_table);
		UTL_FILE.PUT_LINE(v_File_Handle, v_min || ' ' || v_max);
	END IF;
	
   --Flush and close the file
    UTL_FILE.FFLUSH(v_File_Handle);
    UTL_FILE.FCLOSE(v_File_Handle);

END;
