--1
SELECT * FROM kraje
SELECT * FROM skocznie
SELECT * FROM trenerzy
SELECT * FROM uczestnictwa_w_zawodach
SELECT * FROM zawodnicy
SELECT * FROM zawody

--2
SELECT kraje.id_kraju, kraje.kraj, COUNT(zawodnicy.id_kraju) liczba
FROM kraje
LEFT JOIN zawodnicy ON zawodnicy.id_kraju=kraje.id_kraju
GROUP by kraje.id_kraju, kraje.kraj
HAVING COUNT(zawodnicy.id_kraju)=0

--3
SELECT kraje.id_kraju, kraje.kraj, COUNT(zawodnicy.id_kraju) liczba
FROM kraje
LEFT JOIN zawodnicy ON zawodnicy.id_kraju=kraje.id_kraju
GROUP by kraje.id_kraju, kraje.kraj

--4
SELECT zawodnicy.nazwisko FROM zawodnicy 
LEFT JOIN uczestnictwa_w_zawodach ON zawodnicy.id_skoczka=uczestnictwa_w_zawodach.id_skoczka
GROUP BY zawodnicy.nazwisko
HAVING COUNT(uczestnictwa_w_zawodach.id_skoczka)=0

--5
SELECT zawodnicy.nazwisko, COUNT(uczestnictwa_w_zawodach.id_skoczka) ile FROM zawodnicy 
LEFT JOIN uczestnictwa_w_zawodach ON zawodnicy.id_skoczka=uczestnictwa_w_zawodach.id_skoczka
GROUP BY zawodnicy.nazwisko

--6
SELECT DISTINCT nazwisko, skocznie.nazwa FROM zawodnicy 
LEFT JOIN uczestnictwa_w_zawodach ON zawodnicy.id_skoczka=uczestnictwa_w_zawodach.id_skoczka
LEFT JOIN zawody ON zawody.id_zawodow=uczestnictwa_w_zawodach.id_zawodow
LEFT JOIN skocznie ON skocznie.id_skoczni=zawody.id_skoczni

--7
SELECT nazwisko, DATEDIFF(YEAR, data_ur, GETDATE()) wiek FROM zawodnicy 
ORDER BY WIEK DESC

--8
SELECT nazwisko, MIN(DATEDIFF(YEAR, zawodnicy.data_ur, zawody.[DATA])) FROM zawodnicy
LEFT JOIN uczestnictwa_w_zawodach ON zawodnicy.id_skoczka=uczestnictwa_w_zawodach.id_skoczka
LEFT JOIN zawody ON zawody.id_zawodow=uczestnictwa_w_zawodach.id_zawodow
GROUP BY nazwisko

--9
SELECT nazwa, (sedz-k) old FROM skocznie

--10
SELECT TOP(1) nazwa, (sedz-k) old FROM skocznie
INNER JOIN zawody ON zawody.id_skoczni=skocznie.id_skoczni
ORDER BY old DESC


--11
select distinct kraj from skocznie s, zawody z, kraje k
where z.id_skoczni=s.id_skoczni and k.id_kraju=s.id_kraju

--12
select distinct zaw.nazwisko, k.kraj, COUNT(zaw.id_skoczka) as ile from skocznie s, zawody z, uczestnictwa_w_zawodach u, zawodnicy zaw, kraje k
where s.id_skoczni=z.id_skoczni and zaw.id_skoczka=u.id_skoczka and u.id_zawodow=z.id_zawodow and k.id_kraju=zaw.id_kraju and s.id_kraju=zaw.id_kraju
group by zaw.nazwisko, k.kraj
order by nazwisko

--13
--SELECT * FROM trenerzy INSERT INTO trenerzy VALUES(7, 'Corby', 'Fisher', '1975-07-20');

--14
--ALTER TABLE zawodnicy ADD trener INT

--15
/*
UPDATE zawodnicy SET trener = t.id_trenera
FROM zawodnicy z
INNER JOIN trenerzy t ON z.id_kraju = t.id_kraju
*/

--16
/*
ALTER TABLE zawodnicy    
ADD CONSTRAINT FKZawodnicyTrenerzy FOREIGN KEY (trener) REFERENCES Trenerzy(id_trenera)
*/
--17
/*
UPDATE trenerzy
SET data_ur_t = (SELECT TOP 1 DATEADD(YEAR, -5, data_ur) FROM zawodnicy INNER JOIN trenerzy ON zawodnicy.id_kraju = trenerzy.id_kraju ORDER BY data_ur DESC)
WHERE data_ur_t is null
*/
