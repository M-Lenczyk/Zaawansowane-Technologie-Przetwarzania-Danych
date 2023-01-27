--LABORATORIUM 3 - CLOB

--zad1
CREATE TABLE DOKUMENTY(
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

select * FROM DOKUMENTY

--zad2
DECLARE
    tekst CLOB :='';
BEGIN
    FOR counter IN 1..10000 LOOP
        tekst := tekst || 'Oto tekst.';
    END LOOP;
    
    INSERT INTO DOKUMENTY(ID, DOKUMENT) VALUES(1, TO_CLOB(tekst));
    
END;

--zad3
SELECT * FROM DOKUMENTY;

SELECT UPPER(DOKUMENT) FROM DOKUMENTY;
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;
SELECT SUBSTR(DOKUMENT, 5,1000) FROM DOKUMENTY;
SELECT DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) FROM DOKUMENTY;

--zad4
INSERT INTO DOKUMENTY(ID, DOKUMENT) VALUES(2, EMPTY_CLOB());

--zad5
INSERT INTO DOKUMENTY(ID, DOKUMENT) VALUES(3, NULL);

--zad6 Polecenia z zad. 3.

--zad7
SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES;

--zad8
DECLARE
    lobd clob;
    fils BFILE := BFILENAME('ZSBD_DIR', 'dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT DOKUMENT INTO lobd FROM DOKUMENTY
    WHERE ID = 2 FOR UPDATE;
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset,
        873, langctx, warn);
    DBMS_LOB.FILECLOSE(fils);
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;

--zad9
UPDATE DOKUMENTY 
SET DOKUMENT = TO_CLOB(BFILENAME('ZSBD_DIR', 'dokument.txt'))
WHERE ID = 3;

--zad10
SELECT * FROM DOKUMENTY;

--zad11
SELECT LENGTH(DOKUMENT) FROM DOKUMENTY;

--zad12
DROP TABLE DOKUMENTY;

--zad13
CREATE OR REPLACE PROCEDURE CLOB_CENSOR(lobd in out clob, text_to_replace in VARCHAR2)
IS
    censored VARCHAR2(250);
    pos INTEGER;
BEGIN
    censored := '';
    FOR counter IN 1..LENGTH(text_to_replace) LOOP
        censored := censored || '.';
    END LOOP;
    
    pos := DBMS_LOB.INSTR(lobd, text_to_replace);
    WHILE pos <> 0
        LOOP
            DBMS_LOB.WRITE(lobd, LENGTH(text_to_replace), pos, censored);
            pos := DBMS_LOB.INSTR(lobd, text_to_replace);
        END LOOP;
END CLOB_CENSOR;

--zad14
CREATE TABLE BIOGRAPHIES_COPY AS SELECT * FROM ZSBD_TOOLS.BIOGRAPHIES;

SELECT * FROM BIOGRAPHIES_COPY;

DECLARE
    lobd CLOB;
BEGIN
    SELECT BIO INTO lobd
    FROM BIOGRAPHIES_COPY
    FOR UPDATE;
    
    CLOB_CENSOR(lobd, 'Cimrman');
    COMMIT;
END;

SELECT * FROM BIOGRAPHIES_COPY;

--zad15
DROP TABLE BIOGRAPHIES_COPY;
