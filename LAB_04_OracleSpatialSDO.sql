--LABORATORIUM 4 - OracleSpatial: Typ SDO_GEOMETRY

--zad1A
CREATE TABLE FIGURY(
    ID number(1) PRIMARY KEY,
    KSZTALT MDSYS.SDO_GEOMETRY
);

--zad1B
--KOLO
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    1,
    SDO_GEOMETRY(2003, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,4),
    SDO_ORDINATE_ARRAY(3,5, 5,3, 7,5))
    );
	
--KWADRAT    
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    2,
    SDO_GEOMETRY(2003, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,1003,3),
    SDO_ORDINATE_ARRAY(1,1, 5,5))
    );
	
--HAK    
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    3,
    SDO_GEOMETRY(2002, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
    SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1))
    );

--zad1C
INSERT INTO FIGURY(ID, KSZTALT)
VALUES(
    4,
    SDO_GEOMETRY(2003, NULL, NULL,
    SDO_ELEM_INFO_ARRAY(1, 1003, 3),
    SDO_ORDINATE_ARRAY(1,1))
    );

--zad1D
SELECT ID, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT,0.01) VALID 
FROM FIGURY;

--zad1E
DELETE FROM FIGURY
WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(KSZTALT,0.01) <> 'TRUE';

--zad1F
COMMIT;
