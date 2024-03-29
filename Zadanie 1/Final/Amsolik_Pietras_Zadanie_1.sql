/************************************************
 *												*
 *	Zadanie: 1 (Narciarze)						*
 *	Termin:  20.10.2020							*
 *												*
 *	Autor:   Patryk  Amsolik (224246)			*
 *	Autor:   Jakub   Pietras (224404)			*
 *												*
 *	Wkład:   | Amsolik > 50% | Pietras > 50% |  *
 *												*
 *	Każdy członek grupy wykonał zadanie			*
 *  samodzielnie. Niekiedy wybierano najlepsze	*
 *  (według naszej oceny) spośród dwóch			*
 *	(różnych) rozwiązań.						*
 *												*
 ************************************************/


 --1. Wyświetl zawartość każdej z tabel schematu.


	SELECT * FROM kraje
	SELECT * FROM skocznie
	SELECT * FROM trenerzy
	SELECT * FROM uczestnictwa_w_zawodach
	SELECT * FROM zawodnicy
	SELECT * FROM zawody



--2. Sprawdź, czy dla każdego wpisanego kraju istnieje przynajmniej jeden zawodnik.

--	Pietras
	SELECT kraj
	FROM kraje
	WHERE id_kraju NOT IN (SELECT id_kraju FROM zawodnicy)

--	Amsolik
	SELECT kraje.id_kraju, kraje.kraj, COUNT(zawodnicy.id_kraju) liczba
	FROM kraje
	LEFT JOIN zawodnicy ON zawodnicy.id_kraju=kraje.id_kraju
	GROUP by kraje.id_kraju, kraje.kraj
	HAVING COUNT(zawodnicy.id_kraju)=0



--3. Podaj liczbę zawodników z każdego kraju wraz z jego nazwą.

--	Pietras (Wynik jak w treści zadania)
	SELECT kraj, COUNT(kraj) AS liczba
	FROM kraje k, zawodnicy z
	WHERE k.id_kraju = z.id_kraju
	GROUP BY kraj

--	Amsolik (Wynik z Japonią = 0)
	SELECT kraje.id_kraju, kraje.kraj, COUNT(zawodnicy.id_kraju) liczba
	FROM kraje
	LEFT JOIN zawodnicy ON zawodnicy.id_kraju=kraje.id_kraju
	GROUP by kraje.id_kraju, kraje.kraj
	


--4. Sprawdź, czy istnieją zawodnicy, którzy nie brali udziału w żadnych zawodach.

--	Pietras
	SELECT nazwisko
	FROM zawodnicy
	WHERE id_skoczka NOT IN (SELECT id_skoczka FROM zawody)

--	Amsolik
	SELECT zawodnicy.nazwisko FROM zawodnicy 
	LEFT JOIN uczestnictwa_w_zawodach ON zawodnicy.id_skoczka=uczestnictwa_w_zawodach.id_skoczka
	GROUP BY zawodnicy.nazwisko
	HAVING COUNT(uczestnictwa_w_zawodach.id_skoczka)=0



--5. Dla każdego zawodnika podaj jego nazwisko oraz liczbę zawodów, w których brał udział
	
	--	Pietras
	SELECT (SELECT nazwisko FROM zawodnicy z WHERE z.id_skoczka = u.id_skoczka) AS nazwisko, COUNT(id_skoczka) AS ile
	FROM uczestnictwa_w_zawodach u
	GROUP BY id_skoczka
	ORDER BY nazwisko

	--	Amsolik
	SELECT zawodnicy.nazwisko, COUNT(uczestnictwa_w_zawodach.id_skoczka) ile FROM zawodnicy 
	LEFT JOIN uczestnictwa_w_zawodach ON zawodnicy.id_skoczka=uczestnictwa_w_zawodach.id_skoczka
	GROUP BY zawodnicy.nazwisko



--6. Dla każdego zawodnika podaj nazwę skoczni, na której skakał.


	SELECT DISTINCT nazwisko, s.nazwa
	FROM zawodnicy z
	LEFT JOIN uczestnictwa_w_zawodach u ON z.id_skoczka = u.id_skoczka
	LEFT JOIN zawody a ON u.id_zawodow = a.id_zawodow
	LEFT JOIN skocznie s ON a.id_skoczni = s.id_skoczni



--7. Ile lat ma każdy z zawodników? Wynik uporządkuj malejąco względem wieku.

	--	Pietras	
	SELECT nazwisko, YEAR(GETDATE()) - YEAR(data_ur) AS wiek
	FROM zawodnicy
	ORDER BY data_ur

	--	Amsolik
	--	DATEDIFF(YEAR, data_ur, GETDATE())



--8. Ile lat miał każdy z zawodników, gdy uczestniczył w swoich pierwszych zawodach?

	--	Pietras
	SELECT nazwisko, MIN(YEAR(a.DATA) - YEAR(z.data_ur))
	FROM zawodnicy z
	LEFT JOIN uczestnictwa_w_zawodach u ON z.id_skoczka = u.id_skoczka
	LEFT JOIN zawody a ON u.id_zawodow = a.id_zawodow
	GROUP BY nazwisko

	--	Amsolik
	--	MIN(DATEDIFF(YEAR, zawodnicy.data_ur, zawody.[DATA]))



--9. Dla każdej skoczni podaj odległość między punktem bezpieczeństwa (sedz) a punktem konstrukcyjnym (k)


	SELECT nazwa, sedz - k AS odl
	FROM skocznie
	ORDER BY odl DESC



--10. Podaj nazwę skoczni, na której odbywały się zawody, która ma najdłuższy punkt konstrukcyjny.

	--	Pietras
	SELECT TOP 1 nazwa, sedz - k AS odl
	FROM skocznie
	WHERE id_skoczni IN (SELECT id_skoczni FROM zawody)
	ORDER BY odl DESC

	--	Amsolik
	SELECT TOP(1) nazwa, (sedz-k) odl FROM skocznie
	INNER JOIN zawody ON zawody.id_skoczni=skocznie.id_skoczni
	ORDER BY odl DESC



--11. Podaj, w jakich krajach odbywały się zawody.

	-- Pietras
	SELECT DISTINCT kraj
	FROM kraje k
	INNER JOIN skocznie s ON s.id_kraju = k.id_kraju
	INNER JOIN zawody z ON s.id_skoczni = z.id_skoczni

	--	Amsolik
	SELECT DISTINCT kraj 
	FROM skocznie s, zawody z, kraje k
	WHERE z.id_skoczni=s.id_skoczni AND k.id_kraju=s.id_kraju



--12. Podaj, ile razy każdy z zawodników skakał na skoczni we własnym kraju.

	--	Pietras
	SELECT nazwisko, k.kraj, COUNT(nazwisko) AS ile
	FROM zawodnicy z
	INNER JOIN uczestnictwa_w_zawodach u ON z.id_skoczka = u.id_skoczka
	INNER JOIN zawody a ON u.id_zawodow = a.id_zawodow
	INNER JOIN skocznie s ON a.id_skoczni = s.id_skoczni
	INNER JOIN kraje k ON s.id_kraju = k.id_kraju
	WHERE z.id_kraju = k.id_kraju
	GROUP BY nazwisko, kraj
	ORDER BY nazwisko

	--	Amsolik
	SELECT DISTINCT zaw.nazwisko, k.kraj, COUNT(zaw.id_skoczka) AS ile 
	FROM skocznie s, zawody z, uczestnictwa_w_zawodach u, zawodnicy zaw, kraje k
	WHERE s.id_skoczni=z.id_skoczni AND zaw.id_skoczka=u.id_skoczka AND u.id_zawodow=z.id_zawodow AND k.id_kraju=zaw.id_kraju AND s.id_kraju=zaw.id_kraju
	GROUP BY zaw.nazwisko, k.kraj
	ORDER BY nazwisko



--13. Wprowadź nowego trenera z USA (imię: Corby nazwisko: Fisher ur.: 20.07.1975).


	INSERT INTO trenerzy VALUES(7, 'Corby', 'Fisher', '1975-07-20')



--14. Dodaj kolumnę trener do tabeli zawodnicy


	GO
	ALTER TABLE zawodnicy ADD trener INT
	GO



--15. Do kolumny trener w tabeli zawodnicy wprowadź numery trenerów, uwzględniając w każdym przypadku kraj.


	UPDATE zawodnicy SET trener = t.id_trenera
	FROM zawodnicy z
	INNER JOIN trenerzy t ON z.id_kraju = t.id_kraju



--16. Utwórz powiązanie między trenerami a zawodnikami.


	ALTER TABLE zawodnicy
	ADD CONSTRAINT FKZawodnicyTrenerzy FOREIGN KEY (trener) REFERENCES Trenerzy(id_trenera)



--17. Dla tych trenerów, którzy nie mają wprowadzonej daty urodzenia, wprowadź datę 
--    o 5 starszą, niż data urodzenia jego najstarszego zawodnika.


	UPDATE t
	SET data_ur_t = (

		SELECT TOP 1 DATEADD(YEAR, -5, data_ur) 
		FROM zawodnicy 
		WHERE zawodnicy.trener = t.id_trenera
		ORDER BY data_ur DESC)

	FROM trenerzy t
	WHERE data_ur_t IS NULL