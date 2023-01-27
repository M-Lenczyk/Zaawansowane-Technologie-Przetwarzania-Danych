--LABORATORIUM 6 - Oracle Spatial: SQL/MM

--zad1A
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
 and prior t.owner = t.owner;
 
--zad1B
select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

--zad1C
CREATE TABLE MYST_MAJOR_CITIES(
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

--zad1D
INSERT INTO MYST_MAJOR_CITIES
SELECT C.FIPS_CNTRY, C.CITY_NAME, 
    TREAT(ST_POINT.FROM_SDO_GEOM(C.GEOM) AS ST_POINT) STGEOM
FROM MAJOR_CITIES C;


--zad2A
INSERT INTO MYST_MAJOR_CITIES VALUES(
    'PL', 'Szczyrk', ST_POINT(SDO_GEOMETRY('POINT(19.036107 49.718655)', 8307))
);

--zad2B
SELECT R.NAME, R.GEOM.GET_WKT()
FROM RIVERS R;

--zad2C
SELECT SDO_UTIL.TO_GMLGEOMETRY(ST_POINT.GET_SDO_GEOM(STGEOM)) GML
FROM MYST_MAJOR_CITIES
WHERE CITY_NAME='Szczyrk';


--zad3A
CREATE TABLE MYST_COUNTRY_BOUNDARIES(
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

--zad3B
INSERT INTO MYST_COUNTRY_BOUNDARIES
SELECT B.FIPS_CNTRY, B.CNTRY_NAME, ST_MULTIPOLYGON(B.GEOM)
FROM COUNTRY_BOUNDARIES B;

--zad3C
SELECT B.STGEOM.ST_GEOMETRYTYPE() TYP_OBIEKTU, COUNT(*) ILE
FROM MYST_COUNTRY_BOUNDARIES B
GROUP BY B.STGEOM.ST_GEOMETRYTYPE();

--zad3D
SELECT B.STGEOM.ST_ISSIMPLE()
FROM MYST_COUNTRY_BOUNDARIES B;


--zad4A
SELECT B.CNTRY_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B,
 MYST_MAJOR_CITIES C
WHERE B.STGEOM.ST_CONTAINS(C.STGEOM) = 1
GROUP BY B.CNTRY_NAME;

--zad4B
SELECT A.CNTRY_NAME A_NAME, B.CNTRY_NAME B_NAME
FROM MYST_COUNTRY_BOUNDARIES A,
 MYST_COUNTRY_BOUNDARIES B
WHERE A.STGEOM.ST_TOUCHES(B.STGEOM) = 1
AND B.CNTRY_NAME = 'Czech Republic'; 

--zad4C
SELECT DISTINCT B.CNTRY_NAME, R.NAME
FROM MYST_COUNTRY_BOUNDARIES B, RIVERS R
WHERE B.CNTRY_NAME = 'Czech Republic'
AND ST_LINESTRING(R.GEOM).ST_INTERSECTS(B.STGEOM) = 1

--zad4D
SELECT TREAT(A.STGEOM.ST_UNION(B.STGEOM) as ST_POLYGON).ST_AREA() POWIERZCHNIA
FROM MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
WHERE A.CNTRY_NAME = 'Czech Republic'
AND B.CNTRY_NAME = 'Slovakia';

--zad4E
SELECT B.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)).ST_GEOMETRYTYPE() as WEGRY_BEZ
FROM MYST_COUNTRY_BOUNDARIES B, WATER_BODIES W
WHERE B.CNTRY_NAME = 'Hungary'
AND W.NAME = 'Balaton';


--zad5A
SELECT B.CNTRY_NAME A_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
WHERE SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM,
 'distance=100 unit=km') = 'TRUE'
AND B.CNTRY_NAME = 'Poland'
GROUP BY B.CNTRY_NAME;

--zad5B
INSERT INTO USER_SDO_GEOM_METADATA
SELECT 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
FROM ALL_SDO_GEOM_METADATA T
WHERE T.TABLE_NAME = 'MAJOR_CITIES';

--zad5C
CREATE INDEX MYST_MAJOR_CITIES_IDX ON MYST_MAJOR_CITIES(STGEOM) INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

--zad5D
EXPLAIN PLAN FOR
SELECT B.CNTRY_NAME A_NAME, COUNT(*)
FROM MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
WHERE SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM,
 'distance=100 unit=km') = 'TRUE'
AND B.CNTRY_NAME = 'Poland'
GROUP BY B.CNTRY_NAME;

select * from table(dbms_xplan.display)
