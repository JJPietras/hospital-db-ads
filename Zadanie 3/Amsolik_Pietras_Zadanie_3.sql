DECLARE 
@x int, 
@s varchar(10)

SET @x=10
SET @s='napis'

PRINT @x+2
PRINT @s



DECLARE 
@imieP varchar(20), 
@nazwiskoP varchar(20)

SELECT @imieP=imie, @nazwiskoP=nazwisko 
FROM biblioteka..pracownicy 
WHERE id=7

PRINT @imieP+' '+@nazwiskoP



DECLARE 
@imie2P varchar(20),
@nazwisko2P varchar(20)

SELECT @imie2P=imie, @nazwisko2P=nazwisko
FROM biblioteka..pracownicy
PRINT @imie2P+' '+@nazwisko2P


---- 1.
DECLARE
@imie3P varchar(20),
@nazwisko3P varchar(20)

SET @imie3P='Teofil'
SET @nazwisko3P='Szczerbaty'

SELECT @imie3P=imie, @nazwisko3P=nazwisko
FROM biblioteka..pracownicy
WHERE id=1

PRINT @imie3P+' '+@nazwisko3P

---- 2.
DECLARE
@imie4P varchar(20),
@nazwisko4P varchar(20)

SET @imie4P='Teofil'
SET @nazwisko4P='Szczerbaty'

SELECT @imie4P=imie, @nazwisko4P=nazwisko
FROM biblioteka..pracownicy
WHERE id=20

PRINT @imie4P+' '+@nazwisko4P


-- WAITFOR
create table biblioteka..liczby (licz1 int, czas datetime default getdate());
go
declare @x int
set @x=2
insert into biblioteka..liczby(licz1) values(@x);
waitfor delay '00:00:10'
insert into biblioteka..liczby(licz1) values (@x+2);
select * from biblioteka..liczby;


-- IF..ELSE
if exists (select * from biblioteka..wypozyczenia) print('By³y wypo¿yczenia')
else print('Nie by³o ¿adnych wypo¿yczeñ')

-- WHILE
declare @y int
set @y=0
while (@y<10)
begin
	print @y
	if (@y=5) break
	set @y=@y+1
end


-- CASE
select tytul as tytulK, cena as cenaK, [cena jest]=CASE
		when cena<20.00 then 'Niska'
		when cena between 20.00 and 40.00 then 'Przystêpna'
		when cena>40 then 'Wysoka'
		else 'Nieznana'
		end
from biblioteka..ksiazki


-- NULLIF
-- przydatne. kiedy trzeba pomin¹æ jak¹œ wartoœæ w funkcjach agreguj¹cych
-- proszê stworzyæ w³asny przyk³ad
/*select count(*) as 'Liczba pracowników',
	avg(nullif(data_z,0)) as 'Œrednia p³aca',
	min(nullif(data_z,0)) as 'P³aca minimalna'
from narciarze..trenerzy*/

-- ISNULL
-- pozwala na nadawanie wartoœci domyœlnych tam, gdzie jest NULL
-- proszê stworzyæ w³asny przyk³ad
--	 select title, pub_id, isnull(price,(selectmin(price) from pubs..titles)) from pubs..tites



-- Komunikaty o b³êdzie
raiserror(21000,10,1)
print @@error
raiserror(21000,10,1) with seterror
print @@error
raiserror(21000,11,1)
print @@error
raiserror('Ala ma kota',11,1)
print @@error


declare
@d1 datetime,
@d2 datetime

set @d1='20091020'
set @d2='20091025'

select dateadd(hour, 112, @d1)
select dateadd(day, 112, @d1)

select datediff(minute, @d1, @d2)
select datediff(day, @d1, @d2)

select datename(month, @d1)
select datepart(month, @d1)

select cast(day(@d1) as varchar)
+'-'+cast(month(@d1) as varchar)+'-'+cast(year(@d1) as varchar)




select COL_LENGTH('biblioteka..pracownicy', 'imie')
select datalength(2+3.4)
select db_id('master')
select db_name(1)
select user_id()
select user_name()
select host_id()
select host_name()
use biblioteka;
select object_id('Pracownicy')
select object_name(object_id('Pracownicy'))


-- 1. --
if exists(select 1 from master.dbo.sysdatabases where name = 'test_cwiczenia')
drop database test_cwiczenia
go
create database test_cwiczenia
go
use test_cwiczenia
go
create table test_cwiczenia..liczby (liczba int )
go
declare @i int
set @i=1
while @i<100
begin
	insert test_cwiczenia..liczby values (@i)
	set @i=@i+1
end
go
select * from test_cwiczenia..liczby



-- 2. --
use test_cwiczenia
go
if exists(select 1 from sys.objects where TYPE ='P' and name = 'proc_liczby')
drop procedure proc_liczby
go
create procedure proc_liczby @max int = 10
as
begin
	select liczba from test_cwiczenia..liczby
	where liczba<=@max
end
go
exec test_cwiczenia..proc_liczby 3
exec test_cwiczenia..proc_liczby
go


-- 3 --
use test_cwiczenia
go
if exists(select 1 from sys.objects where TYPE ='P' and name = 'proc_statystyka')
drop procedure proc_liczby
go
create procedure proc_statystyka @max int output, @min int output, @aux int output
as
begin
	set @max=(select max(liczba) from test_cwiczenia..liczby)
	set @min=(select min(liczba) from test_cwiczenia..liczby)
	set @aux=10
end
go
declare @max int, @min int, @aux2 int
exec test_cwiczenia..proc_statystyka @max output, @min output, @aux=@aux2 output
select @max 'Max', @min 'Min', @aux2


--- Proszê zmodyfikowaæ przyk³ady - dostosowaæ do w³asnych baz!!! -----
use test_cwiczenia

-- 1 --
-- drop function fn_srednia
/* create function fn_srednia(@rodzaj varchar(12)) returns int
begin
	return (select avg(price) from pubs..titles where type=@rodzaj)
end

select dbo.fn_srednia('business')

-- 2 --

-- drop function funkcja

create function funkcja(@max int) returns table
return (select * from liczby where liczba <=@max)

select * from funkcja(3) */