/************************************************
 *												*
 *	Zadanie: 5 									*
 *	Termin:  24.11.2020							*
 *												*
 *	Autor:   Patryk  Amsolik (224246)			*
 *	Autor:   Jakub   Pietras (224404)			*
 *												*
 ************************************************/


    USE test_pracownicy
    GO


-- 1.   Utwórz tabelę dziennik składającą się z pól: tabela (do piętnastu znaków),
--      data, l_wierszy (liczba całkowita), komunikat (do trzystu znaków)



    CREATE TABLE dziennik
    (
        tabela    NVARCHAR(15),
        data      DATETIME,
        l_wierszy INT,
        komunikat NVARCHAR(300)
    )



-- 2.   Zadeklaruj blok anonimowy aktualizujący tabelę pracownicy poprzez dodanie
--      premii tym pracownikom, którzy są kierownikami. Wartosć premii jest ustawiana
--      przez zmienną zadeklarowaną w bloku. Następnie policz ile zmieniono wierszy
--      i wstaw liczbę zmian oraz odpowiedni komentarz do tabeli dziennik
--      (Wprowadzono dodatek funkcyjny w wysokości ...).



    DECLARE @nr_akt INT, @ilosc_zmian INT = 0, @kwota INT = 500
    DECLARE @komunikat VARCHAR(300) = N'Wprowadzono dodatek funkcyjny w wysokości '
    SET @komunikat += CAST(@kwota AS VARCHAR(6))

    DECLARE crs CURSOR FOR
        SELECT nr_akt
        FROM pracownicy
        WHERE nr_akt IN (SELECT kierownik FROM pracownicy)

    OPEN crs
    FETCH NEXT FROM crs INTO @nr_akt

    WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE pracownicy
            SET placa += @kwota
            WHERE nr_akt = @nr_akt

            SET @ilosc_zmian += 1
            FETCH NEXT FROM crs INTO @nr_akt
        END

    CLOSE crs
    DEALLOCATE crs

    INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @ilosc_zmian, @komunikat)



-- 3.   Zadeklaruj blok wstawiający do dziennika komentarz o ilości zatrudnionych
--      pracowników w wybranym roku
--      (np. 1989) (Zatrudniono ... pracowników. / Nikogo nie zatrudniono.)



    DECLARE @rok INT = 1988, @ile_zatrudnionych INT
    DECLARE @komunikat_z NVARCHAR(300) = 'W ' + CAST(@rok AS CHAR(4))

    SELECT @ile_zatrudnionych = COUNT(*)
    FROM pracownicy
    WHERE DATEPART(YEAR, data_zatr) = @rok

    IF @ile_zatrudnionych > 0
        SET @komunikat_z += ' zatrudniono ' + CAST(@ile_zatrudnionych AS VARCHAR(3)) + N' pracowników.'
    ELSE
        SET @komunikat_z += ' nikogo nie zatrudniono.'

    INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @ile_zatrudnionych, @komunikat_z)



-- 4.   Zadeklaruj blok anonimowy wstawiający do dziennika komentarz o długości zatrudnienia
--      pracownika z numerem 8902 (dłużej, czy krócej niż 15 lat):
--      Pracownik ... jest zatrudniony [dłużej niż / krócej niż] 15 lat.



	
	DECLARE @pracownik INT = 8902, @staz INT
	DECLARE @komentarz NVARCHAR(300) = 'Pracownik '
	SET @komentarz += CAST(@pracownik AS CHAR(4)) + ' jest zatrudniony'

	SELECT @staz = DATEDIFF(YEAR, data_zatr, GETDATE())
	FROM pracownicy
	WHERE nr_akt = @pracownik

	IF @staz > 15
		SET @komentarz += N' dłużej niż '
	ELSE
		SET @komentarz += N' krócej niż '
	SET @komentarz += '15 lat.'

	INSERT dziennik VALUES ('pracownicy', GETDATE(), 1, @komentarz)
	SELECT * FROM dziennik
	GO


-- 5.   Utwórz procedurę składowaną PIERWSZA, ktora wyświetli wartość pobranego argumentu
--      w postaci: Wartość parametru wynosiła: ...... Wywołaj procedurę z bloku.



    CREATE PROCEDURE PIERWSZA(@val INT) AS
        PRINT (N'Wartość parametru wynosiła: ' + CAST(@val AS VARCHAR(40)))
    GO

    EXEC PIERWSZA 3000
	GO


-- 6.   Utwórz procedurę DRUGA o następujących własnościach:
--
--          *   trzy argumenty: wejściowy ciąg znaków domyślnie NULL,
--              wyjściowy ciąg znaków oraz wejściowy numer
--              z przypisaną wartością początkową 1,
--
--          *   zadeklarowana zmienna lokalna znakowa niezerowa
--              z przypisaną wartością 'DRUGA',
--
--          *   ciąg zwacany to łańcuch składający się z: wartości
--              zmiennej lokalnej, ciągu wejściowego oraz numeru
--              wejściowego.



    CREATE PROCEDURE DRUGA(@in VARCHAR(40) = NULL, @out VARCHAR(70) OUTPUT, @number INT = 1) AS
	BEGIN
    DECLARE @local VARCHAR(20) = 'DRUGA'
        SET @out = @local + @in + CAST(@number AS VARCHAR(20))
	END
    GO

    /*DECLARE @val VARCHAR(70)
    EXEC DRUGA @in = 'Wejscie', @out = @val OUTPUT
    PRINT @val*/



-- 7.   Utwórz procedurę, podwyższającą płacę dla danego argumentem działu o określony
--      drugim argumentem procent. Wprowadź domyślne wartości dla argumentów, a także
--      odpowiedni komentarz do dziennika. Policz zmodyfikowane rekordy.
--      (zaktualizuj atrybut placa, wstaw komunikat do dziennika w postaci:
--      Wprowadzono podwyżke o ... procent). Jeśli numer działu to zero, podnieś
--      płacę wszystkim pracownikom.


    /*DROP PROCEDURE PREMIA*/
    CREATE PROCEDURE PREMIA(@dzial INT = 10, @procent INT = 5) AS
    DECLARE @pracownik MONEY, @count INT = 0
    DECLARE @komunikat NVARCHAR(300) = N'Wprowadzono podwyżkę o '
        SET @komunikat += CAST(@procent AS VARCHAR(4)) + '%'

    DECLARE
        cur CURSOR FOR
            SELECT nr_akt
            FROM pracownicy
            WHERE id_dzialu = @dzial
               OR @dzial = 0

        OPEN cur
        FETCH NEXT FROM cur INTO @pracownik
        WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE pracownicy
                SET placa *= (1.0 + (@procent / 100.0))
                WHERE nr_akt = @pracownik

                SET @count += 1
                FETCH NEXT FROM cur INTO @pracownik
            END

        CLOSE cur
        DEALLOCATE cur
    INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @count, @komunikat)
    GO


    /*SELECT * FROM pracownicy ORDER BY id_dzialu
    EXEC PREMIA 10
    SELECT * FROM pracownicy ORDER BY id_dzialu*/


-- 8.   Napisz funkcję zwracającą udział procentowy działu w budżecie firmy.
--      Wywołaj ją wewnątrz zapytania dającego wynik w postaci dwóch kolumn:
--      id_dzialu, udzial_w_budzecie.


    /*DROP FUNCTION PERCENTOR
    GO*/
	
    CREATE FUNCTION PERCENTOR(@dzial INT) RETURNS FLOAT AS
    BEGIN
        DECLARE @sum_dzial FLOAT, @sum_wszys FLOAT
        SELECT @sum_dzial = SUM(placa)
        FROM pracownicy
        WHERE id_dzialu = @dzial
           OR (id_dzialu IS NULL AND @dzial IS NULL)

        SELECT @sum_wszys = SUM(placa) FROM pracownicy
        RETURN (@sum_dzial * 100) / @sum_wszys
    END
	GO

    SELECT DISTINCT id_dzialu, CAST(dbo.PERCENTOR(id_dzialu) AS VARCHAR(16)) + '%' AS udzial_w_budzecie
    FROM pracownicy
	GO

-- 9.   Utwórz wyzwalacz do_archiwum, który przenosi dane pracownika do tabeli
--      prac_archiw w przypadku jego zwolnienia (usunięcia z tabeli pracownicy).
--      Dodaj komentarz do tablicy dziennik: Zwolniono pracownika numer: ....



    CREATE TRIGGER do_archiwum ON pracownicy FOR DELETE AS
    BEGIN
        INSERT INTO prac_archiw
        SELECT deleted.nr_akt,
               deleted.nazwisko,
               deleted.stanowisko,
               deleted.kierownik,
               deleted.data_zatr,
               GETDATE(),
               deleted.placa,
               deleted.dod_funkcyjny,
               deleted.prowizja,
               deleted.id_dzialu
        FROM deleted

        DECLARE @komunikat NVARCHAR(300) = 'Zwolniono pracownika numer '
        SET @komunikat += CAST((SELECT deleted.nr_akt FROM deleted) AS VARCHAR(4))
        INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), 1, @komunikat)
    END
	GO
    /*DELETE FROM pracownicy WHERE nr_akt = 9411*/