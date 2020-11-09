/************************************************
 *												*
 *	Zadanie: 2 (Biuro)							*
 *	Termin:  27.10.2020							*
 *												*
 *	Autor:   Patryk  Amsolik (224246)			*
 *	Autor:   Jakub   Pietras (224404)			*
 *												*
 ************************************************/
 

--1	Wyœwietl zawartoœæ ka¿dej z tabeli schematu

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



--2	SprawdŸ, ile razy by³a wynajmowana i ogl¹dana ka¿da nieruchomoœæ

	SELECT nieruchomoscNr,
	(SELECT COUNT(*) FROM wizyty w1 WHERE w1.nieruchomoscnr = w.nieruchomoscNr) AS ile_wizyt,
	(SELECT COUNT(*) FROM wynajecia w2 WHERE w2.nieruchomoscNr = w.nieruchomoscNr) AS ile_wynajmow 
	FROM wynajecia w
	GROUP BY nieruchomoscNr



--3	SprawdŸ, o ile procent wzrós³ czynsz od pierwszego wynajmu do chwili obecnej 
--	(wartoœæ aktualnego czynszu znajduje siê w tabeli nieruchomoœci, poprzednie 
--	wartoœci w wynajêcia). Wyniki podaj w postaci ...%

	--PRAWID£OWO

	SELECT N1.nieruchomoscNr, str((N1.Czynsz*100 / W1.Czynsz) -100) + '%' AS Podwyzka
	FROM nieruchomosci N1, wynajecia W1
	WHERE N1.nieruchomoscnr = w1.nieruchomoscNr 
	AND w1.od_kiedy = (
		SELECT min(W2.Od_kiedy) 
		FROM wynajecia W2 
		WHERE W2.nieruchomoscNr = N1.nieruchomoscnr
	)
	ORDER BY 1




--4	Podaj, ile ³¹cznie zap³acono czynszu za ka¿de wynajmowane mieszkanie 
--	(wysokoœæ czynszu w tabeli podawana jest na miesi¹c)

	SELECT nieruchomoscNr, SUM(czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1))
	FROM wynajecia
	GROUP BY nieruchomoscNr



--5	Zak³adaj¹c, ¿e 30% czynszu z wynajmu pobiera biuro, podaj, ile zarobi³o ka¿de biuro

	SELECT n.biuroNr, SUM(w.czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1)) * 0.3
	FROM wynajecia w
	INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
	GROUP BY n.biuroNr



--6	Podaj nazwê miasta, w którym:

--		a) biura wynajê³y najwiêcej mieszkañ (liczy siê iloœæ)

		SELECT miasto, COUNT(*) AS ile
		FROM wynajecia w
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
		GROUP BY miasto
		ORDER BY ile DESC

--		b) przychód z wynajmu by³ najwy¿szy (liczy siê czas)

		SELECT miasto, SUM(w.czynsz * (DATEDIFF(MONTH, od_kiedy, do_kiedy) + 1)) AS ile
		FROM wynajecia w
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
		WHERE w.nieruchomoscNr = n.nieruchomoscnr
		GROUP BY miasto
		ORDER BY ile DESC



--7	SprawdŸ, czy klienci, którzy ogl¹dali nieruchomoœci (wizyty), pó¿niej j¹ wynajêli
--	(podaj numery tych klientów i nieruchomoœci)

	SELECT DISTINCT i.klientnr, i.nieruchomoscnr
	FROM wizyty i, wynajecia y
	WHERE i.klientnr = y.klientnr AND i.nieruchomoscnr = y.nieruchomoscNr



--8	Ile nieruchomoœci ogl¹da³ ka¿dy klient przed wynajêciem jednej z nich?

	SELECT w.klientnr, COUNT(DISTINCT w.nieruchomoscnr) 
	FROM wizyty w, wynajecia y
	WHERE w.klientnr = y.klientnr AND w.nieruchomoscnr <> y.nieruchomoscNr
	GROUP BY w.klientnr



--9	Podaj, którzy klienci wynajêli mieszkanie p³ac¹c za czynsz wiêcej ni¿ deklarowali maksymalnie

	SELECT DISTINCT k.klientnr
	FROM klienci k
	INNER JOIN wynajecia w ON k.klientnr = w.klientnr
	WHERE w.czynsz > k.max_czynsz



--10 Podaj numery biur, które nie oferuj¹ ¿adnej nieruchomoœci

	SELECT biuroNr
	FROM biura
	WHERE biuroNr NOT IN 
	(
		SELECT n.biuroNr 
		FROM wynajecia w 
		INNER JOIN nieruchomosci n ON w.nieruchomoscNr = n.nieruchomoscnr
	)



--11 Ile kobiet i mê¿czyzn

--		a) zatrudnia ca³a sieæ biur

		SELECT	SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel

--		b) zatrudniaj¹ poszczególne biura

		SELECT	b.biuroNr,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		INNER JOIN biura b ON b.biuroNr = personel.biuroNr
		GROUP BY b.biuroNr

--		c) zatrudniaj¹ poszczególne miasta

		SELECT	b.miasto,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		INNER JOIN biura b ON b.biuroNr = personel.biuroNr
		GROUP BY b.miasto

--		d) jest zatrudnionych na poszczególnych stanowiskach

		SELECT	stanowisko,
				SUM(IIF(plec = 'K', 1, 0)) AS kobiety, 
				SUM(IIF(plec <> 'K',1, 0)) AS mezczyzni
		FROM personel
		GROUP BY stanowisko