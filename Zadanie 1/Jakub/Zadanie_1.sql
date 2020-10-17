--1. Wyœwietl zawartoœæ ka¿dej z tabel schematu.
SELECT * FROM kraje
SELECT * FROM skocznie
SELECT * FROM trenerzy
SELECT * FROM uczestnictwa_w_zawodach
SELECT * FROM zawodnicy
SELECT * FROM zawody


--2. SprawdŸ, czy dla ka¿dego wpisanego kraju istnieje przynajmniej jeden zawodnik.
SELECT kraj
FROM kraje
WHERE id_kraju NOT IN (SELECT id_kraju FROM zawodnicy)


--3. Podaj liczbê zawodników z ka¿dego kraju wraz z jego nazw¹.
SELECT kraj, COUNT(kraj)
FROM kraje k, zawodnicy z
WHERE k.id_kraju = z.id_kraju
GROUP BY kraj


--4. SprawdŸ, czy istniej¹ zawodnicy, którzy nie brali udzia³u w ¿adnych zawodach.
SELECT nazwisko
FROM zawodnicy
WHERE id_skoczka NOT IN (SELECT id_skoczka FROM zawody)


--5. Dla ka¿dego zawodnika podaj jego nazwisko oraz liczbê zawodów, w których bra³ udzia³
SELECT (SELECT nazwisko FROM zawodnicy z WHERE z.id_skoczka = u.id_skoczka) as nazwisko, COUNT(id_skoczka) as ile
FROM uczestnictwa_w_zawodach u
GROUP BY id_skoczka
ORDER BY nazwisko


--6. Dla ka¿dego zawodnika podaj nazwê skoczni, na której skaka³.
SELECT DISTINCT nazwisko, s.nazwa
FROM zawodnicy z
INNER JOIN uczestnictwa_w_zawodach u ON z.id_skoczka = u.id_skoczka
INNER JOIN zawody a ON u.id_zawodow = a.id_zawodow
INNER JOIN skocznie s ON a.id_skoczni = s.id_skoczni
ORDER BY nazwisko, s.nazwa


--7. Ile lat ma ka¿dy z zawodników? Wynik uporz¹dkuj malej¹co wzglêdem wieku.
SELECT nazwisko, YEAR(GETDATE()) - YEAR(data_ur)
FROM zawodnicy
ORDER BY data_ur


--8. Ile lat mia³ ka¿dy z zawodników, gdy uczestniczy³ w swoich pierwszych zawodach?
SELECT nazwisko, MIN(YEAR(a.DATA) - YEAR(z.data_ur))
FROM zawodnicy z
LEFT JOIN uczestnictwa_w_zawodach u ON z.id_skoczka = u.id_skoczka
LEFT JOIN zawody a ON u.id_zawodow = a.id_zawodow
GROUP BY nazwisko


--9. Dla ka¿dej skoczni podaj odleg³oœæ miêdzy punktem bezpieczeñstwa (sedz) a punktem konstrukcyjnym (k)
SELECT nazwa, sedz - k AS odl
FROM skocznie
ORDER BY odl DESC


--10. Podaj nazwê skoczni, na której odbywa³y siê zawody, która ma najd³u¿szy punkt konstrukcyjny.
SELECT TOP 1 nazwa, sedz - k as odl
FROM skocznie
WHERE id_skoczni IN (SELECT id_skoczni FROM zawody)
ORDER BY odl DESC


--11. Podaj, w jakich krajach odbywa³y siê zawody.
SELECT DISTINCT kraj
FROM kraje k
INNER JOIN skocznie s ON s.id_kraju = k.id_kraju
INNER JOIN zawody z ON s.id_skoczni = z.id_skoczni


--12. Podaj, ile razy ka¿dy z zawodników skaka³ na skoczni we w³asnym kraju.
SELECT nazwisko, k.kraj, COUNT(nazwisko) AS ile
FROM zawodnicy z
INNER JOIN uczestnictwa_w_zawodach u ON z.id_skoczka = u.id_skoczka
INNER JOIN zawody a ON u.id_zawodow = a.id_zawodow
INNER JOIN skocznie s ON a.id_skoczni = s.id_skoczni
INNER JOIN kraje k ON s.id_kraju = k.id_kraju
WHERE z.id_kraju = k.id_kraju
GROUP BY nazwisko, kraj
ORDER BY nazwisko


--13. WprowadŸ nowego trenera z USA (imiê: Corby nazwisko: Fisher ur.: 20.07.1975).
INSERT INTO trenerzy VALUES(7, 'Corby', 'Fisher', '1975-07-20')


--14. Dodaj kolumnê trener do tabeli zawodnicy
GO
ALTER TABLE zawodnicy ADD trener INT
GO

--15. Do kolumny trener w tabeli zawodnicy wprowadŸ numery trenerów, uwzglêdniaj¹c w ka¿dym przypadku kraj.
UPDATE zawodnicy SET trener = t.id_trenera
FROM zawodnicy z
INNER JOIN trenerzy t ON z.id_kraju = t.id_kraju


--16. Utwórz powi¹zanie miêdzy trenerami a zawodnikami.
ALTER TABLE zawodnicy
ADD CONSTRAINT FKZawodnicyTrenerzy FOREIGN KEY (trener) REFERENCES Trenerzy(id_trenera)


--17. Dla tych trenerów, którzy nie maj¹ wprowadzonej daty urodzenia, wprowadŸ datê 
--    o 5 starsz¹, ni¿ data urodzenia jego najstarszego zawodnika.
UPDATE t
SET data_ur_t = (

	SELECT TOP 1 DATEADD(YEAR, -5, data_ur) 
	FROM zawodnicy 
	WHERE zawodnicy.trener = t.id_trenera
	ORDER BY data_ur DESC)

FROM trenerzy t
WHERE data_ur_t IS NULL


SELECT *
FROM trenerzy