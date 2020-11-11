/************************************************
 *												*
 *	Zadanie: 4 									*
 *	Termin:  24.11.2020							*
 *												*
 *	Autor:   Patryk  Amsolik (224246)			*
 *	Autor:   Jakub   Pietras (224404)			*
 *												*
 ************************************************/


-- Zadanie 1


	print('Czesc, to ja')


-- Zadanie 2


	DECLARE	@num int = 4
	PRINT 'ZMIENNA = ' + CAST(@num AS VARCHAR)


-- Zadanie 3


	DECLARE	@val int = 5

	IF @val % 2 = 0 
		SET @val /= 2
	ELSE
		SET @val += 1

	PRINT @val


-- Zadanie 4


	DECLARE @i int = 1

	WHILE @i < 5
		BEGIN
			PRINT 'zmienna ma wartosc ' + CAST(@i AS VARCHAR)
			SET @i += 1
		END


-- Zadanie 5


	DECLARE @j INT = 3

	WHILE @j < 8
		BEGIN
			PRINT @j
			IF @j = 3
				PRINT 'poczatek'
			ELSE IF @j = 5
				PRINT 'srodek'
			ELSE IF @j = 7
				PRINT 'koniec'
			SET @j += 1
		END

-- Zadanie 6


	USE master
	IF EXISTS(SELECT 1
          FROM master.dbo.sysdatabases
          WHERE name = 'TEST_DB')
    DROP DATABASE TEST_DB
	GO

	CREATE DATABASE TEST_DB
	GO
	USE TEST_DB
	CREATE TABLE ODDZIALY (
		NR_ODD INT,
		NAZWA_ODD VARCHAR(30)
	)


-- Zadanie 7


	INSERT INTO ODDZIALY VALUES (1, 'Sales')
	INSERT INTO ODDZIALY VALUES (2, 'Management')
	INSERT INTO ODDZIALY VALUES (3, 'Finance')
	INSERT INTO ODDZIALY VALUES (4, 'Recruitment')

	DECLARE 
		@k INT = 1,
		@name VARCHAR(20)

	SELECT @name = NAZWA_ODD
	FROM ODDZIALY
	WHERE NR_ODD = @k

	PRINT @name


-- Zadanie 8


	DECLARE @i VARCHAR(40), @j VARCHAR(40)
	DECLARE cur CURSOR FOR 
	SELECT 'NUMER ODDZIALU TO: ' + CAST(NR_ODD AS VARCHAR(10)), 'NAZWA ODDZIALU TO: ' + NAZWA_ODD
	FROM ODDZIALY;

	OPEN cur
	FETCH NEXT FROM cur INTO @i, @j

	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @i + ', ' + @j
			FETCH NEXT FROM cur INTO @i, @j
		END
	CLOSE cur
	DEALLOCATE cur


-- Zadanie 9


	DECLARE @l int, @cnt int = 0
	DECLARE ptr CURSOR FOR
	SELECT NR_ODD
	FROM ODDZIALY
	WHERE NR_ODD > 2

	OPEN ptr
	FETCH NEXT FROM ptr INTO @l 


	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE FROM ODDZIALY
		WHERE NR_ODD = @l
		SET @cnt += 1
		FETCH NEXT FROM ptr INTO @l
	END
	PRINT 'Liczba usuniêtych rekordów to: ' + CAST(@cnt AS VARCHAR(40))
	CLOSE ptr
	DEALLOCATE ptr


-- Zadanie 10


	SELECT * FROM ODDZIALY

	DECLARE @val INT
	DECLARE cur2 CURSOR FOR
	SELECT NR_ODD FROM ODDZIALY WHERE NR_ODD = 3
	OPEN cur2

	FETCH NEXT FROM cur2 INTO @val

	IF @@FETCH_STATUS <> 0
		INSERT INTO ODDZIALY VALUES (3, 'Finance')
	ELSE
		UPDATE ODDZIALY SET NAZWA_ODD = 'IT' WHERE NR_ODD = @val
	CLOSE cur2
	DEALLOCATE cur2

	SELECT * FROM ODDZIALY
	
	