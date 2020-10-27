/************************************************
 *												*
 *	Zadanie: 2 (Biuro)							*
 *	Termin:  27.10.2020							*
 *												*
 *	Autor:   Patryk  Amsolik (224246)			*
 *	Autor:   Jakub   Pietras (224404)			*
 *												*
 ************************************************/
 

--1	Wyúwietl zawartoúÊ kaødej z tabeli schematu

	SELECT * FROM biura
	SELECT * FROM biura2
	SELECT * FROM klienci
	SELECT * FROM nieruchomosci
	SELECT * FROM nieruchomosci2
	SELECT * FROM personel
	SELECT * FROM rejestracje
	SELECT * FROM wizyty
	SELECT * FROM wlasciciele
	SELECT * FROM wynajecia



--2	Sprawdü, ile razy by≥a wynajmowana i oglπdana kaøda nieruchomoúÊ

	SELECT nieruchomoscNr,
	(SELECT COUNT(*) FROM wizyty w1 WHERE w1.nieruchomoscnr = w.nieruchomoscNr) AS ile_wizyt,
	(SELECT COUNT(*) FROM wynajecia w2 WHERE w2.nieruchomoscNr = w.nieruchomoscNr) AS ile_wynajmow 
	FROM wynajecia w
	GROUP BY nieruchomoscNr



--3	Sprawdü, o ile procent wzrÛs≥ czynsz od pierwszego wynajmu do chwili obecnej 
--	(wartoúÊ aktualnego czynszu znajduje siÍ w tabeli nieruchomoúci, poprzednie 
--	wartoúci w wynajÍcia). Wyniki podaj w postaci ...%

	-- èLE WYST•PI• POWT”RZENIA

	SELECT n.nieruchomoscnr, Str(n.czynsz * 100 / w.czynsz - 100) + '%'
	FROM nieruchomosci n
	INNER JOIN wynajecia w ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE w.nieruchomoscNr = n.nieruchomoscnr
	ORDER BY n.nieruchomoscnr

	--PRAWID£OWO

	SELECT N1.nieruchomoscNr, str((N1.Czynsz*100 / W1.Czynsz) -100) + '%' AS Podwyzka
	FROM nieruchomosci N1, wynajecia W1
	WHERE N1.nieruchomoscnr = w1.nieruchomoscNr AND w1.od_kiedy = (
	SELECT min(W2.Od_kiedy) FROM wynajecia W2 WHERE W2.nieruchomoscNr = N1.nieruchomoscnr)




--4	Podaj, ile ≥πcznie zap≥acono czynszu za kaøde wynajmowane mieszkanie 
--	(wysokoúÊ czynszu w tabeli podawana jest na miesiπc)

	SELECT nieruchomoscNr, SUM(czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1))
	FROM wynajecia
	GROUP BY nieruchomoscNr



--5	Zak≥adajπc, øe 30% czynszu z wynajmu pobiera biuro, podaj, ile zarobi≥o kaøde biuro

	SELECT n.biuroNr, SUM(w.czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1)) * 0.3
	FROM wynajecia w
	INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
	GROUP BY n.biuroNr



--6	Podaj nazwÍ miasta, w ktÛrym:

--		a) biura wynajÍ≥y najwiÍcej mieszkaÒ (liczy siÍ iloúÊ)

		SELECT miasto, COUNT(*) AS ile
		FROM wynajecia w
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
		GROUP BY miasto
		ORDER BY ile DESC

--		b) przychÛd z wynajmu by≥ najwyøszy (liczy siÍ czas)

		SELECT miasto, SUM(w.czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1)) AS ile
		FROM wynajecia w
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
		WHERE w.nieruchomoscNr = n.nieruchomoscnr
		GROUP BY miasto
		ORDER BY ile DESC



--7	Sprawdü, czy klienci, ktÛrzy oglπdali nieruchomoúci (wizyty), pÛøniej jπ wynajÍli
--	(podaj numery tych klientÛw i nieruchomoúci)

	SELECT DISTINCT i.klientnr, i.nieruchomoscnr
	FROM wizyty i, wynajecia y
	WHERE i.klientnr = y.klientnr AND i.nieruchomoscnr = y.nieruchomoscNr



--8	Ile nieruchomoúci oglπda≥ kaødy klient przed wynajÍciem jednej z nich?

	SELECT w.klientnr, COUNT(DISTINCT w.nieruchomoscnr) 
	FROM wizyty w, wynajecia y
	WHERE w.klientnr = y.klientnr AND w.nieruchomoscnr <> y.nieruchomoscNr
	GROUP BY w.klientnr



--9	Podaj, ktÛrzy klienci wynajÍli mieszkanie p≥acπc za czynsz wiÍcej niø deklarowali maksymalnie

	SELECT DISTINCT k.klientnr
	FROM klienci k
	INNER JOIN wynajecia w ON k.klientnr = w.klientnr
	WHERE w.czynsz > k.max_czynsz



--10 Podaj numery biur, ktÛre nie oferujπ øadnej nieruchomoúci

	SELECT biuroNr
	FROM biura
	WHERE biuroNr NOT IN 
	(
		SELECT n.biuroNr 
		FROM wynajecia w 
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
	)



--11 Ile kobiet i mÍøczyzn

--		a) zatrudnia ca≥a sieÊ biur

		SELECT	SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel

--		b) zatrudniajπ poszczegÛlne biura

		SELECT	b.biuroNr,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		INNER JOIN biura b ON b.biuroNr = personel.biuroNr
		GROUP BY b.biuroNr

--		c) zatrudniajπ poszczegÛlne miasta

		SELECT	b.miasto,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		INNER JOIN biura b ON b.biuroNr = personel.biuroNr
		GROUP BY b.miasto

--		d) jest zatrudnionych na poszczegÛlnych stanowiskach

		SELECT	stanowisko,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		GROUP BY stanowisko