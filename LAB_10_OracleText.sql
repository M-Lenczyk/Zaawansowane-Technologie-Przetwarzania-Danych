--LABORATORIUM 10 - OracleText

--Operator CONTAINS - Podstawy
--zad1
select * from  ZSBD_TOOLS.cytaty

create table CYTATY
as select * from ZSBD_TOOLS.CYTATY;

--zad2
select AUTOR, TEKST 
from CYTATY
where LOWER(TEKST) LIKE '%pesymista%'
and LOWER(TEKST) LIKE '%optymista%';

--zad3
create index CYTATY_TEKST_IDX on CYTATY(TEKST)
indextype is CTXSYS.CONTEXT;

--zad4
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'PESYMISTA AND OPTYMISTA', 1) > 0;

--zad5
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'PESYMISTA - OPTYMISTA', 1) > 0;

--zad6
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST,'near((pesymista, optymista),3)') > 0;

--zad7
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST,'near((pesymista, optymista),10)') > 0;

--zad8
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST,'życi%',1) > 0;

--zad9
select AUTOR, TEKST, SCORE(1) as DOPASOWANIE
from CYTATY
where CONTAINS(TEKST,'życi%',1) > 0;

--zad10
select AUTOR, TEKST, SCORE(1) as DOPASOWANIE
from CYTATY
where CONTAINS(TEKST,'życi%',1) > 0
and ROWNUM <=1
order by DOPASOWANIE desc;

--zad11
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST,'FUZZY(PROBELM,,,N)', 1) > 0;

--zad12
insert into CYTATY
values(39,'Bertrand Russel', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
commit;

delete from CYTATY
where ID = 39;

select * from CYTATY;

--zad13
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'głupcy', 1) > 0;

--zad14
select TOKEN_TEXT
from DR$CYTATY_TEKST_IDX$I;

select TOKEN_TEXT
from DR$CYTATY_TEKST_IDX$I
where TOKEN_TEXT = 'głupcy';

--zad15
drop index CYTATY_TEKST_IDX;

create index CYTATY_TEKST_IDX on CYTATY(TEKST)
indextype is CTXSYS.CONTEXT;

--zad16
select AUTOR, TEKST
from CYTATY
where CONTAINS(TEKST, 'głupcy', 1) > 0;

--zad17
drop index CYTATY_TEKST_IDX;

drop table CYTATY;

--Zaawansowane indeksowanie i wyszukiwanie

--zad1
create table QUOTES
as select * from ZSBD_TOOLS.QUOTES;

--zad2
create index QUOTES_TEXT_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT;

--zad3
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'work', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '$work', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'working', 1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, '$working', 1) > 0;

--zad4
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'it', 1) > 0;

--zad5
select *
from CTX_STOPLISTS;

--zad6
select *
from CTX_STOPWORDS;

--zad7
drop index QUOTES_TEXT_IDX;

create index QUOTES_TEXT_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ('stoplist CTXSYS.EMPTY_STOPLIST');

--zad8
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'it', 1) > 0;

--zad9
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'fool AND humans', 1) > 0;

--zad10
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'fool AND humans', 1) > 0;

--zad11
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT,'(fool AND humans) within SENTENCE',1) > 0;

--zad12
drop index QUOTES_TEXT_IDX;

--zad13
begin
    ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
    ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

--zad14
create index QUOTES_TEXT_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ('stoplist CTXSYS.EMPTY_STOPLIST
            section group nullgroup');

--zad15
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT,'(fool AND humans) within SENTENCE',1) > 0;

select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT,'(fool AND computers) within SENTENCE',1) > 0;

--zad16
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'humans', 1) > 0;

--zad17
drop index QUOTES_TEXT_IDX;

begin
    ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m', 'printjoins', '_-');
    ctx_ddl.set_attribute ('lex_z_m', 'index_text', 'YES');
end;

create index QUOTES_TEXT_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ('stoplist CTXSYS.EMPTY_STOPLIST
            section group nullgroup
            LEXER lex_z_m');

--zad18
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'humans', 1) > 0;

--zad19
select AUTHOR, TEXT
from QUOTES
where CONTAINS(TEXT, 'non\-humans', 1) > 0;

--zad20
drop table QUOTES;

begin
    ctx_ddl.drop_preference('lex_z_m');
end;