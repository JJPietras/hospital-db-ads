-- //===============================================//
--
--              PROJEKT SZPITAL
--
--  Autor:      Jakub Pietras       (224404)
--  Autor:      Patryk Amsolik      (224246)
--  Zajęcia:    Wtorek 14:00-15:30
--  Termin:     16.06.2020
--
--	IDE:        MS SQL Server Management Studio 18
--	IDE:        JetBrains DataGrip 2020.1
--
--	Tabele:     10
--  Kwerendy:   15
--
-- //===============================================//


--#################################################################################################################--
--#																												  #--
--#													DEFINICJA													  #--
--#																												  #--
--#################################################################################################################--

USE master
IF DB_ID('szpital') IS NOT NULL
    DROP DATABASE szpital
GO

CREATE DATABASE szpital
GO

USE szpital
GO


CREATE TABLE miasta
(
    kod_pocztowy VARCHAR(6)   NOT NULL,
    nazwa        NVARCHAR(20) NOT NULL,
    wojewodztwo  NVARCHAR(20) NOT NULL,

    CONSTRAINT miasta_primary
        PRIMARY KEY (kod_pocztowy),

    CONSTRAINT miasta_kod_pocztowy_format
        CHECK (kod_pocztowy LIKE '[0-9][0-9]-[0-9][0-9][0-9]'),

    CONSTRAINT miasta_nazwa_format
        CHECK (nazwa LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT miasta_wojewodztwo_format
        CHECK (wojewodztwo LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),
)
GO

CREATE TABLE adresy
(
    id_adresu INT IDENTITY,
    miasto    VARCHAR(6)   NOT NULL,
    ulica     NVARCHAR(40) NOT NULL,
    nr_domu   VARCHAR(5)   NOT NULL,
    nr_lokalu VARCHAR(5),

    CONSTRAINT adresy_primary
        PRIMARY KEY (id_adresu),

    CONSTRAINT adresy_miasto_foreign
        FOREIGN KEY (miasto) REFERENCES miasta (kod_pocztowy),

    CONSTRAINT adresy_ulica_format
        CHECK (ulica LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT adresy_nr_domu_format
        CHECK (nr_domu LIKE '[1-9]%'),

    CONSTRAINT adresy_nr_lokalu_format
        CHECK (nr_lokalu LIKE '[1-9]%')
)
GO

CREATE TABLE specjalizacje
(
    id_spec    CHAR(6),
    nazwa_spec NVARCHAR(30) NOT NULL,
    placa_min  MONEY        NOT NULL,
    placa_max  MONEY        NOT NULL,

    CONSTRAINT specjalizacje_primary
        PRIMARY KEY (id_spec),

    CONSTRAINT specjalizacje_id_spec
        CHECK (id_spec LIKE '[A-Z][A-Z]_[A-Z][A-Z][A-Z]'),

    CONSTRAINT specjalizacje_nazwa_format
        CHECK (nazwa_spec LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT specjalizacje_place
        CHECK (placa_min <= placa_max)
)
GO

CREATE TABLE lekarze
(
    id_lekarza  INT IDENTITY,
    oddzial     CHAR(2)     NOT NULL,
    zatrudniony DATE        NOT NULL,
    pensja      MONEY       NOT NULL,
    imie        VARCHAR(30) NOT NULL,
    nazwisko    VARCHAR(30) NOT NULL,
    adres       INT         NOT NULL,

    CONSTRAINT lekarze_primary
        PRIMARY KEY (id_lekarza),

    CONSTRAINT lekarze_zatrudniony_value
        CHECK (zatrudniony >= '01-01-2000'),

    CONSTRAINT lekarze_imie_format
        CHECK (imie LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT lekarze_nazwisko_format
        CHECK (imie LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT lekarze_adres_foreign
        FOREIGN KEY (adres) REFERENCES adresy (id_adresu)
)
GO

CREATE TABLE profesje_lekarzy
(
    lekarz        INT,
    specjalizacja CHAR(6),
    bieglosc      NVARCHAR(7) NOT NULL,

    CONSTRAINT profesje_lekarzy_composite
        PRIMARY KEY (lekarz, specjalizacja),

    CONSTRAINT profesje_lekarzy_lekarz_foreign
        FOREIGN KEY (lekarz) REFERENCES lekarze (id_lekarza),

    CONSTRAINT profesje_lekarzy_specjalizacja_foreign
        FOREIGN KEY (specjalizacja) REFERENCES specjalizacje (id_spec),

    CONSTRAINT profesje_bieglosc_format
        CHECK (bieglosc IN (N'niska', N'średnia', N'wysoka'))
)
GO

CREATE TABLE oddzialy
(
    id_oddzialu    CHAR(2),
    nazwa_oddzialu NVARCHAR(40) NOT NULL,
    ordynator      INT,

    CONSTRAINT oddzialy_primary
        PRIMARY KEY (id_oddzialu),

    CONSTRAINT oddzialy_id_oddzialu_format
        CHECK (id_oddzialu LIKE '[A-Z][A-Z]'),

    CONSTRAINT oddzialy_nazwa_format
        CHECK (nazwa_oddzialu LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT oddzialy_ordynator_foreign
        FOREIGN KEY (ordynator) REFERENCES lekarze (id_lekarza)
)
GO

ALTER TABLE lekarze
    ADD CONSTRAINT lekarze_oddzial_foreign
        FOREIGN KEY (oddzial) REFERENCES oddzialy (id_oddzialu)
GO

CREATE TABLE pacjenci
(
    id_pacjenta INT IDENTITY,
    imie        NVARCHAR(30) NOT NULL,
    nazwisko    NVARCHAR(30) NOT NULL,
    adres       INT          NOT NULL,

    CONSTRAINT pacjenci_primary
        PRIMARY KEY (id_pacjenta),

    CONSTRAINT pacjenci_imie_format
        CHECK (imie LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT pacjenci_nazwisko_format
        CHECK (nazwisko LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT pacjenci_adres_foreign
        FOREIGN KEY (adres) REFERENCES adresy (id_adresu)
)
GO

CREATE TABLE zabiegi
(
    id_zabiegu  INT IDENTITY,
    pacjent     INT      NOT NULL,
    koszt       MONEY,
    rozpoczecie DATETIME NOT NULL,
    zakonczenie DATETIME NOT NULL,
    opis        NVARCHAR(200),

    CONSTRAINT zabiegi_primary
        PRIMARY KEY (id_zabiegu),

    CONSTRAINT zabiegi_pacjent_foreign
        FOREIGN KEY (pacjent) REFERENCES pacjenci (id_pacjenta),

    CONSTRAINT zabiegi_terminy
        CHECK (rozpoczecie < zakonczenie),

    CONSTRAINT zabiegi_opis_format
        CHECK (opis LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%')
)
GO

CREATE TABLE wykonawcy_zabiegu
(
    zabieg INT,
    lekarz INT,

    CONSTRAINT wykonawcy_zabiegu_primary
        PRIMARY KEY (zabieg, lekarz),

    CONSTRAINT wykonawcy_zabiegu_zabieg_foreign
        FOREIGN KEY (zabieg) REFERENCES zabiegi (id_zabiegu),

    CONSTRAINT wykonawcy_zabiegu_lekarz_foreign
        FOREIGN KEY (lekarz) REFERENCES lekarze (id_lekarza),
)
GO

CREATE TABLE badania
(
    id_badania   INT IDENTITY,
    pacjent      INT           NOT NULL,
    data_badania DATETIME      NOT NULL,
    koszt        MONEY,
    opis         NVARCHAR(200) NOT NULL,
    poprzednie   INT,

    CONSTRAINT badania_primary
        PRIMARY KEY (id_badania),

    CONSTRAINT badania_pacjent_foreign
        FOREIGN KEY (pacjent) REFERENCES pacjenci (id_pacjenta),

    CONSTRAINT badania_poprzednie_foreign
        FOREIGN KEY (poprzednie) REFERENCES badania (id_badania),

    CONSTRAINT badania_koszt_value
        CHECK (koszt IS NULL OR koszt >= 0)
)
GO

--#################################################################################################################--
--#																												  #--
--#														DANE    												  #--
--#																												  #--
--#################################################################################################################--


--	############# MIASTA ############# -- (9)


INSERT INTO miasta VALUES ('01-000', N'Warszawa', N'Mazowieckie')
INSERT INTO miasta VALUES ('30-000', N'Kraków', N'Małopolskie')
INSERT INTO miasta VALUES ('60-000', N'Poznań', N'Wielkopolskie')

INSERT INTO miasta VALUES ('26-600', N'Radom', N'Mazowieckie')
INSERT INTO miasta VALUES ('09-400', N'Płock', N'Mazowieckie')

INSERT INTO miasta VALUES ('33-100', N'Tarnów', N'Małopolskie')
INSERT INTO miasta VALUES ('33-300', N'Nowy Sącz', N'Małopolskie')

INSERT INTO miasta VALUES ('62-800', N'Kalisz', N'Wielkopolskie')
INSERT INTO miasta VALUES ('62-500', N'Konin', N'Wielkopolskie')
GO

--	############# ADRESY ############# -- (90)


--  dla lekarzy (30)
INSERT INTO adresy VALUES ('26-600', N'Diamentowa', '12', NULL)
INSERT INTO adresy VALUES ('30-000', N'Kryształowa', '95', NULL)
INSERT INTO adresy VALUES ('33-100', N'Skośna', '54', '1')
INSERT INTO adresy VALUES ('62-500', N'Skośna', '54', '4')
INSERT INTO adresy VALUES ('09-400', N'Dębowa', '6', NULL)
INSERT INTO adresy VALUES ('33-300', N'Dzika', '133', '1')
INSERT INTO adresy VALUES ('62-800', N'Dzika', '133', '1A')
INSERT INTO adresy VALUES ('01-000', N'Dzika', '133', '2')
INSERT INTO adresy VALUES ('62-800', N'Długa', '5C', NULL)
INSERT INTO adresy VALUES ('62-800', N'Zawiszy', '4', NULL)
INSERT INTO adresy VALUES ('62-800', N'Rębowskiego', '1', NULL)
INSERT INTO adresy VALUES ('30-000', N'Rębowskiego', '2', NULL)
INSERT INTO adresy VALUES ('26-600', N'Aleksandrowska', '7', NULL)
INSERT INTO adresy VALUES ('33-300', N'Mickiewicza', '90', NULL)
INSERT INTO adresy VALUES ('01-000', N'Okólna', '45', '3B')
INSERT INTO adresy VALUES ('33-100', N'Kolorowa', '31', NULL)
INSERT INTO adresy VALUES ('62-500', N'Tkaczy', '13', NULL)
INSERT INTO adresy VALUES ('26-600', N'Chmielna', '76', NULL)
INSERT INTO adresy VALUES ('33-300', N'Szeroka', '5A', NULL)
INSERT INTO adresy VALUES ('09-400', N'Jana Pawła', '9', NULL)
INSERT INTO adresy VALUES ('62-500', N'Kazimierza Wielkiego', '4', '2')
INSERT INTO adresy VALUES ('60-000', N'Kazimierza Wielkiego', '4', '6')
INSERT INTO adresy VALUES ('26-600', N'Gałczyńskiego', '3', NULL)
INSERT INTO adresy VALUES ('60-000', N'Witkacego', '59', NULL)
INSERT INTO adresy VALUES ('62-500', N'Kurpińskiego', '84', NULL)
INSERT INTO adresy VALUES ('62-800', N'Sosnowa', '33', '1A')
INSERT INTO adresy VALUES ('60-000', N'Mydlana', '48', NULL)
INSERT INTO adresy VALUES ('60-000', N'Obrońców Ojczyzny', '99', NULL)
INSERT INTO adresy VALUES ('62-500', N'Limanowskiego', '91', '6C')
INSERT INTO adresy VALUES ('62-500', N'Adamiaków', '5', '1B')

--dla klientów (60)
INSERT INTO adresy VALUES ('01-000', N'Polna', '106', NULL)
INSERT INTO adresy VALUES ('33-300', N'Leśna', '110', NULL)
INSERT INTO adresy VALUES ('33-100', N'Słoneczna', '140A', NULL)
INSERT INTO adresy VALUES ('62-500', N'Krótka', '72', NULL)
INSERT INTO adresy VALUES ('26-600', N'Szkolna', '32', '1')
INSERT INTO adresy VALUES ('26-600', N'Szkolna', '32', '2')
INSERT INTO adresy VALUES ('26-600', N'Ogrodowa', '112', NULL)
INSERT INTO adresy VALUES ('60-000', N'Lipowa', '16', NULL)
INSERT INTO adresy VALUES ('30-000', N'Łąkowa', '109C', NULL)
INSERT INTO adresy VALUES ('30-000', N'Brzozowa', '68', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kwiatowa', '11', NULL)
INSERT INTO adresy VALUES ('30-000', N'Kościelna', '4', '1')
INSERT INTO adresy VALUES ('09-400', N'Kościelna', '4', '2')
INSERT INTO adresy VALUES ('30-000', N'Kościelna', '4', '2B')
INSERT INTO adresy VALUES ('30-000', N'Sosnowa', '65', NULL)
INSERT INTO adresy VALUES ('60-000', N'Zielona', '91', NULL)
INSERT INTO adresy VALUES ('62-800', N'Parkowa', '131', '4')
INSERT INTO adresy VALUES ('60-000', N'Parkowa', '131', '7')
INSERT INTO adresy VALUES ('33-300', N'Akacjowa', '103', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kolejowa', '56B', '1')
INSERT INTO adresy VALUES ('62-800', N'Kolejowa', '56B', '2')
INSERT INTO adresy VALUES ('62-800', N'Kolejowa', '56B', '3')
INSERT INTO adresy VALUES ('62-500', N'Kolejowa', '56B', '4')
INSERT INTO adresy VALUES ('62-800', N'Iskry', '169', NULL)
INSERT INTO adresy VALUES ('62-500', N'Kluczborska', '197', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kontuszowa', '32', NULL)
INSERT INTO adresy VALUES ('09-400', N'Orlich Gniazd', '124', NULL)
INSERT INTO adresy VALUES ('60-000', N'Lazurowa', '35', NULL)
INSERT INTO adresy VALUES ('33-100', N'Łagowska', '185', '2C')
INSERT INTO adresy VALUES ('62-800', N'Miejska', '9', NULL)
INSERT INTO adresy VALUES ('60-000', N'Obrońców Tobruku', '111D', NULL)
INSERT INTO adresy VALUES ('60-000', N'Prometeusza', '93', NULL)
INSERT INTO adresy VALUES ('33-300', N'Pawła Stellerea', '115', NULL)
INSERT INTO adresy VALUES ('09-400', N'Kazubów', '190', NULL)
INSERT INTO adresy VALUES ('01-000', N'Kazimierza Wyki', '79', '4')
INSERT INTO adresy VALUES ('60-000', N'Jamesa Joycea', '74', NULL)
INSERT INTO adresy VALUES ('30-000', N'Tadeusza Kutrzeby', '32', NULL)
INSERT INTO adresy VALUES ('62-800', N'Szczotkarska', '53', NULL)
INSERT INTO adresy VALUES ('09-400', N'Strońska', '126', '2A')
INSERT INTO adresy VALUES ('30-000', N'Zenona Klemensiewicza', '34', NULL)
INSERT INTO adresy VALUES ('33-100', N'Zachodzącego Słońca', '28', NULL)
INSERT INTO adresy VALUES ('62-500', N'Stanisława Kunickiego', '156', NULL)
INSERT INTO adresy VALUES ('33-100', N'Sosnowiecka', '28A', NULL)
INSERT INTO adresy VALUES ('30-000', N'Józefa Wybickiego', '130', '5D')
INSERT INTO adresy VALUES ('01-000', N'Karola Miarki', '45', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kazimierza Deyny', '116', NULL)
INSERT INTO adresy VALUES ('26-600', N'Łęgi', '187', NULL)
INSERT INTO adresy VALUES ('60-000', N'Oławska', '32', '1B')
INSERT INTO adresy VALUES ('26-600', N'Okrętowa', '151', NULL)
INSERT INTO adresy VALUES ('01-000', N'Józefa Ignacego Kraszewskiego', '71', NULL)
INSERT INTO adresy VALUES ('09-400', N'Józefa Brandta', '5', NULL)
INSERT INTO adresy VALUES ('01-000', N'Jana Kędzierskiego', '73', '2D')
INSERT INTO adresy VALUES ('60-000', N'Górczewska', '137', NULL)
INSERT INTO adresy VALUES ('33-100', N'Gołuchowska', '1C', NULL)
INSERT INTO adresy VALUES ('09-400', N'Zeusa', '130', NULL)
INSERT INTO adresy VALUES ('60-000', N'Budy', '105', NULL)
INSERT INTO adresy VALUES ('33-100', N'Czakowa', '78', NULL)
INSERT INTO adresy VALUES ('60-000', N'Nowej Huty', '138A', '3C')
INSERT INTO adresy VALUES ('33-300', N'Bronisława Markiewicza', '22', NULL)
INSERT INTO adresy VALUES ('30-000', N'Kampinoska', '145', NULL)
GO


--	############# SPECJALIZACJE ############# -- (10)


INSERT INTO specjalizacje VALUES ('AL_ERG', 'Alergologia', 3500, 6900)
INSERT INTO specjalizacje VALUES ('AN_EST', 'Anestezjologia', 5200, 10300)
INSERT INTO specjalizacje VALUES ('CH_KLP', 'Chirurgia klatki piersiowej', 7200, 16900)
INSERT INTO specjalizacje VALUES ('CH_ONK', 'Chirurgia onkologiczna', 9600, 24500)
INSERT INTO specjalizacje VALUES ('CH_PLA', 'Chirurgia plastyczna', 8500, 19900)
INSERT INTO specjalizacje VALUES ('DE_RMA', 'Dermatologia', 3800, 8500)
INSERT INTO specjalizacje VALUES ('KA_RDI', 'Kardiologia', 4400, 11400)
INSERT INTO specjalizacje VALUES ('MD_PRA', 'Medycyna Pracy', 3200, 6100)
INSERT INTO specjalizacje VALUES ('OK_ULI', 'Okulistyka', 4900, 9600)
INSERT INTO specjalizacje VALUES ('ON_KOL', 'Onkologia', 6700, 14300)
GO

--	################ ODDZIAŁY ################ -- (8)


INSERT INTO oddzialy VALUES ('CH', N'Chirurgiczny', NULL)
INSERT INTO oddzialy VALUES ('ON', N'Onkologiczny', NULL)
INSERT INTO oddzialy VALUES ('AL', N'Alergologiczny', NULL)
INSERT INTO oddzialy VALUES ('DE', N'Dermatologiczny', NULL)
INSERT INTO oddzialy VALUES ('KA', N'Kardiologiczny', NULL)
INSERT INTO oddzialy VALUES ('AN', N'Anestezjologiczny', NULL)
INSERT INTO oddzialy VALUES ('OK', N'Okulistyczny', NULL)
INSERT INTO oddzialy VALUES ('PO', N'Poradnia', NULL)
GO

--	################ LEKARZE ################# -- (30)


INSERT INTO lekarze VALUES ('CH', '2002-01-03', 16900, N'Robert', N'Malinowski', 1)
INSERT INTO lekarze VALUES ('CH', '2005-02-06', 9700, N'Bogumił', N'Nowicki', 2)
INSERT INTO lekarze VALUES ('CH', '2008-07-28', 7400, N'Hanna', N'Nowak', 3)
INSERT INTO lekarze VALUES ('CH', '2005-01-01', 14900, N'Marcel', N'Stępień', 4)
INSERT INTO lekarze VALUES ('CH', '2003-09-21', 9600, N'Mariola', N'Majewska', 5)

INSERT INTO lekarze VALUES ('CH', '2014-03-01', 22200, N'Waldemar', N'Mazur', 6)
INSERT INTO lekarze VALUES ('CH', '2012-02-21', 10600, N'Jolanta', N'Pawłowska', 7)

INSERT INTO lekarze VALUES ('CH', '2007-07-01', 15700, N'Mariola', N'Górska', 8)
INSERT INTO lekarze VALUES ('CH', '2008-05-30', 14700, N'Krystian', N'Błaszczyk', 9)
INSERT INTO lekarze VALUES ('CH', '2003-11-29', 9100, N'Emil', N'Zalewski', 10)


INSERT INTO lekarze VALUES ('ON', '2012-06-06', 12100, N'Wiesława', N'Wróblewska', 11)
INSERT INTO lekarze VALUES ('ON', '2007-08-02', 9200, N'Sylwester', N'Woźniak', 12)
INSERT INTO lekarze VALUES ('ON', '2003-06-26', 8100, N'Lech', N'Szymczak', 13)


INSERT INTO lekarze VALUES ('AL', '2009-07-17', 6200, N'Stefan', N'Wysocki', 14)
INSERT INTO lekarze VALUES ('AL', '2009-06-06', 5500, N'Renata', N'Pawłowska', 15)
INSERT INTO lekarze VALUES ('AL', '2016-07-10', 5100, N'Maciej', N'Walczak', 16)
INSERT INTO lekarze VALUES ('AL', '2005-03-09', 4200, N'Marta', N'Przybylska', 17)
INSERT INTO lekarze VALUES ('AL', '2020-08-31', 4300, N'Małgorzata', N'Ziółkowska', 18)


INSERT INTO lekarze VALUES ('DE', '2004-01-17', 8300, N'Grzegorz', N'Sikorski', 19)
INSERT INTO lekarze VALUES ('DE', '2016-01-02', 5100, N'Józef', N'Szewczyk', 20)


INSERT INTO lekarze VALUES ('KA', '2003-05-18', 10500, N'Szczepan', N'Borowski', 21)
INSERT INTO lekarze VALUES ('KA', '2014-06-06', 5000, N'Emil', N'Walczak', 22)


INSERT INTO lekarze VALUES ('AN', '2003-04-20', 10200, N'Mikołaj', N'Szulc', 23)
INSERT INTO lekarze VALUES ('AN', '2004-01-23', 7600, N'Halina', N'Sokołowska', 24)
INSERT INTO lekarze VALUES ('AN', '2007-11-29', 6200, N'Halina', N'Jakubowska', 25)
INSERT INTO lekarze VALUES ('AN', '2004-08-05', 8500, N'Hubert', N'Andrzejewski', 26)


INSERT INTO lekarze VALUES ('OK', '2010-08-20', 9400, N'Lech', N'Adamski', 27)
INSERT INTO lekarze VALUES ('OK', '2004-02-03', 6700, N'Aneta', N'Górska', 28)
INSERT INTO lekarze VALUES ('OK', '2003-05-06', 7700, N'Wiesława', N'Baran', 29)


INSERT INTO lekarze VALUES ('PO', '2008-02-01', 5600, N'Cezary', N'Król', 30)
GO

--ordynatorzy


UPDATE oddzialy SET ordynator = 1 WHERE id_oddzialu = 'CH'
UPDATE oddzialy SET ordynator = 11 WHERE id_oddzialu = 'ON'
UPDATE oddzialy SET ordynator = 14 WHERE id_oddzialu = 'AL'
UPDATE oddzialy SET ordynator = 19 WHERE id_oddzialu = 'DE'
UPDATE oddzialy SET ordynator = 21 WHERE id_oddzialu = 'KA'
UPDATE oddzialy SET ordynator = 23 WHERE id_oddzialu = 'AN'
UPDATE oddzialy SET ordynator = 27 WHERE id_oddzialu = 'OK'
-- zakładamy, że poradnia nie posiada ordynatora
GO

--	################ PROFESJE LEKARZY ################# -- (30)

INSERT INTO profesje_lekarzy VALUES (1, 'CH_KLP', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (2, 'CH_KLP', N'średnia')
INSERT INTO profesje_lekarzy VALUES (3, 'CH_KLP', N'średnia')
INSERT INTO profesje_lekarzy VALUES (4, 'CH_KLP', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (5, 'CH_KLP', N'niska')

INSERT INTO profesje_lekarzy VALUES (6, 'CH_ONK', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (7, 'CH_ONK', N'niska')

INSERT INTO profesje_lekarzy VALUES (8, 'CH_PLA', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (9, 'CH_PLA', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (10, 'CH_PLA', N'średnia')


INSERT INTO profesje_lekarzy VALUES (11, 'ON_KOL', N'średnia')
INSERT INTO profesje_lekarzy VALUES (12, 'ON_KOL', N'niska')
INSERT INTO profesje_lekarzy VALUES (13, 'ON_KOL', N'średnia')


INSERT INTO profesje_lekarzy VALUES (14, 'AL_ERG', N'średnia')
INSERT INTO profesje_lekarzy VALUES (15, 'AL_ERG', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (16, 'AL_ERG', N'średnia')
INSERT INTO profesje_lekarzy VALUES (17, 'AL_ERG', N'niska')
INSERT INTO profesje_lekarzy VALUES (18, 'AL_ERG', N'niska')


INSERT INTO profesje_lekarzy VALUES (19, 'DE_RMA', N'średnia')
INSERT INTO profesje_lekarzy VALUES (20, 'DE_RMA', N'niska')


INSERT INTO profesje_lekarzy VALUES (21, 'KA_RDI', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (22, 'KA_RDI', N'niska')


INSERT INTO profesje_lekarzy VALUES (23, 'AN_EST', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (24, 'AN_EST', N'średnia')
INSERT INTO profesje_lekarzy VALUES (25, 'AN_EST', N'niska')
INSERT INTO profesje_lekarzy VALUES (26, 'AN_EST', N'średnia')


INSERT INTO profesje_lekarzy VALUES (27, 'OK_ULI', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (28, 'OK_ULI', N'średnia')
INSERT INTO profesje_lekarzy VALUES (29, 'OK_ULI', N'średnia')


INSERT INTO profesje_lekarzy VALUES (30, 'MD_PRA', N'średnia')


--lekarze z wieloma specjalnościami (5)


INSERT INTO profesje_lekarzy VALUES (1, 'CH_ONK', N'średnia')
INSERT INTO profesje_lekarzy VALUES (1, 'CH_PLA', N'średnia')

INSERT INTO profesje_lekarzy VALUES (7, 'ON_KOL', N'średnia')

INSERT INTO profesje_lekarzy VALUES (15, 'DE_RMA', N'niska')

INSERT INTO profesje_lekarzy VALUES (27, 'AN_EST', N'niska')
GO

--	################ PACJĘI ################# -- (60)


INSERT INTO pacjenci VALUES (N'Dominik', N'Wróblewski', 31)
INSERT INTO pacjenci VALUES (N'Marian', N'Urbański', 32)
INSERT INTO pacjenci VALUES (N'Marzena', N'Kowalczyk', 33)
INSERT INTO pacjenci VALUES (N'Sara', N'Pietrzak', 34)
INSERT INTO pacjenci VALUES (N'Teresa', N'Stępień', 35)
INSERT INTO pacjenci VALUES (N'Klaudia', N'Pawlak', 36)
INSERT INTO pacjenci VALUES (N'Katarzyna', N'Kalinowski', 37)
INSERT INTO pacjenci VALUES (N'Igor', N'Baran', 38)
INSERT INTO pacjenci VALUES (N'Mariola', N'Zawadzki', 39)
INSERT INTO pacjenci VALUES (N'Milena', N'Włodarczyk', 40)
INSERT INTO pacjenci VALUES (N'Jadwiga', N'Jasiński', 41)
INSERT INTO pacjenci VALUES (N'Patryk', N'Kowalski', 42)
INSERT INTO pacjenci VALUES (N'Konrad', N'Zając', 43)
INSERT INTO pacjenci VALUES (N'Bartłomiej', N'Cieślak', 44)
INSERT INTO pacjenci VALUES (N'Karina', N'Górski', 45)
INSERT INTO pacjenci VALUES (N'Samanta', N'Rutkowski', 46)
INSERT INTO pacjenci VALUES (N'Renata', N'Nowak', 47)
INSERT INTO pacjenci VALUES (N'Julia', N'Szulc', 48)
INSERT INTO pacjenci VALUES (N'Anna', N'Wilk', 49)
INSERT INTO pacjenci VALUES (N'Robert', N'Krupa', 50)
INSERT INTO pacjenci VALUES (N'Mirosława', N'Pawłowski', 51)
INSERT INTO pacjenci VALUES (N'Mariusz', N'Sokołowski', 52)
INSERT INTO pacjenci VALUES (N'Bartłomiej', N'Jakubowski', 53)
INSERT INTO pacjenci VALUES (N'Natalia', N'Piotrowski', 54)
INSERT INTO pacjenci VALUES (N'Zuzanna', N'Kubiak', 55)
INSERT INTO pacjenci VALUES (N'Zdzisław', N'Wojciechowski', 56)
INSERT INTO pacjenci VALUES (N'Andrzej', N'Baranowski', 57)
INSERT INTO pacjenci VALUES (N'Lech', N'Zieliński', 58)
INSERT INTO pacjenci VALUES (N'Igor', N'Wasilewski', 59)
INSERT INTO pacjenci VALUES (N'Zdzisław', N'Woźniak', 60)
INSERT INTO pacjenci VALUES (N'Bogumił', N'Rutkowski', 61)
INSERT INTO pacjenci VALUES (N'Krystyna', N'Wójcik', 62)
INSERT INTO pacjenci VALUES (N'Walenty', N'Sikorski', 63)
INSERT INTO pacjenci VALUES (N'Wojciech', N'Król', 64)
INSERT INTO pacjenci VALUES (N'Adam', N'Konieczny', 65)
INSERT INTO pacjenci VALUES (N'Patrycja', N'Czarnecki', 66)
INSERT INTO pacjenci VALUES (N'Jakub', N'Jasiński', 67)
INSERT INTO pacjenci VALUES (N'Magdalena', N'Andrzejewski', 68)
INSERT INTO pacjenci VALUES (N'Kamil', N'Król', 69)
INSERT INTO pacjenci VALUES (N'Andrzej', N'Kaczmarek', 70)
INSERT INTO pacjenci VALUES (N'Rafał', N'Olszewski', 71)
INSERT INTO pacjenci VALUES (N'Bartłomiej', N'Zawadzki', 72)
INSERT INTO pacjenci VALUES (N'Sabina', N'Nowakowski', 73)
INSERT INTO pacjenci VALUES (N'Sylwester', N'Pietrzak', 74)
INSERT INTO pacjenci VALUES (N'Krystyna', N'Jankowski', 75)
INSERT INTO pacjenci VALUES (N'Katarzyna', N'Jabłoński', 76)
INSERT INTO pacjenci VALUES (N'Damian', N'Głowacki', 77)
INSERT INTO pacjenci VALUES (N'Małgorzata', N'Czerwiński', 78)
INSERT INTO pacjenci VALUES (N'Wiktor', N'Konieczny', 79)
INSERT INTO pacjenci VALUES (N'Jakub', N'Kubiak', 80)
INSERT INTO pacjenci VALUES (N'Daniel', N'Woźniak', 81)
INSERT INTO pacjenci VALUES (N'Jędrzej', N'Maciejewski', 82)
INSERT INTO pacjenci VALUES (N'Marzena', N'Adamczyk', 83)
INSERT INTO pacjenci VALUES (N'Zofia', N'Cieślak', 84)
INSERT INTO pacjenci VALUES (N'Henryk', N'Głowacki', 85)
INSERT INTO pacjenci VALUES (N'Paulina', N'Rutkowski', 86)
INSERT INTO pacjenci VALUES (N'Małgorzata', N'Adamski', 87)
INSERT INTO pacjenci VALUES (N'Katarzyna', N'Zając', 88)
INSERT INTO pacjenci VALUES (N'Sebastian', N'Maciejewski', 89)
INSERT INTO pacjenci VALUES (N'Ireneusz', N'Maciejewski', 90)
GO

--	################ ZABIEGI ################# -- (30)


/* 1*/INSERT INTO zabiegi VALUES (1, 4600, '2017-08-19 12:00:00', '2017-08-19 12:45:00', N'Usunięcie tkanki raka płuc')
/* 2*/INSERT INTO zabiegi VALUES (1, 3300, '2018-04-24 16:30:00', '2018-04-24 17:30:00', N'Dalsze usunięcie tkanki raka płuc')
/* 3*/INSERT INTO zabiegi VALUES (1, 200, '2012-10-03 08:15:00', '2012-10-03 08:25:00', N'Wycięcie znamienia na prawej ręce')
/* 4*/INSERT INTO zabiegi VALUES (2, 0, '2016-12-03 10:20:00', '2016-12-03 10:40:00', N'Usunięcie zaćmy')
/* 5*/INSERT INTO zabiegi VALUES (3, 4400, '2007-06-16 13:05:00', '2007-06-16 16:20:00', N'Założenie bajpasów')
/* 6*/INSERT INTO zabiegi VALUES (4, 2600, '2013-04-11 18:10:00', '2013-04-11 20:30:00', N'Odsysanie tłuszczu z podbrzusza')
/* 7*/INSERT INTO zabiegi VALUES (4, 4400, '2007-06-18 15:30:00', '2007-06-18 16:00:00', N'Usunięcie nadmiaru tkanki tłuszczowej z twarzy')
/* 8*/INSERT INTO zabiegi VALUES (5, 900, '2008-12-09 10:12:00', '2008-12-09 10:37:00', N'Usunięcie zablokowanego jedzenia z przełyku')
/* 9*/INSERT INTO zabiegi VALUES (6, 1200, '2017-08-19 15:30:00', '2017-08-19 15:35:00', N'Wycięcie znamienia na twarzy')
/*10*/INSERT INTO zabiegi VALUES (6, 300, '2005-06-09 17:00:00', '2005-06-09 17:20:00', N'Usunięcie jaskry')
/*11*/INSERT INTO zabiegi VALUES (6, 200, '2008-02-09 14:40:00', '2008-02-09 14:55:00', N'Nastawieie ramienia')
/*12*/INSERT INTO zabiegi VALUES (7, 0, '2016-04-04 13:30:00', '2016-04-04 17:55:00', N'Rekonstrukcja czaszki po wypadku')
/*13*/INSERT INTO zabiegi VALUES (7, 300, '2005-04-10 12:20:00', '2005-04-10 12:30:00', N'Wycięcie znamienia z lewej nogi')
/*14*/INSERT INTO zabiegi VALUES (8, 1800, '2003-11-07 18:05:00', '2003-11-07 18:30:00', N'Ewisceracja lewego oka')
/*15*/INSERT INTO zabiegi VALUES (9, 1500, '2006-02-03 15:09:00', '2006-02-03 15:48:00', N'Zatrzymanie krwotoku wewnętrznego')
/*16*/INSERT INTO zabiegi VALUES (10, 3700, '2013-12-21 11:10:00', '2013-12-21 11:50:00', N'Podniesienie plastyczne podbródka')
/*17*/INSERT INTO zabiegi VALUES (10, 1300, '2014-06-30 19:13:00', '2014-06-30 19:27:00', N'Usunięcie kurzych łapek')
/*18*/INSERT INTO zabiegi VALUES (10, 1200, '2015-11-11 21:20:00', '2015-11-11 22:00:00', N'Depilacja laserowa')
/*19*/INSERT INTO zabiegi VALUES (10, 3100, '2016-03-10 08:00:00', '2016-03-10 10:10:00', N'Lifting biustu')
/*20*/INSERT INTO zabiegi VALUES (11, 4600, '2018-03-03 10:40:00', '2018-03-03 14:20:00', N'Usunięcie raka przełyku')
/*21*/INSERT INTO zabiegi VALUES (12, 2100, '2004-05-17 13:05:00', '2004-05-17 13:20:00', N'Opasanie gałki ocznej')
/*22*/INSERT INTO zabiegi VALUES (12, 4000, '2015-07-26 14:02:00', '2015-07-26 14:27:00', N'Założenie bajpasów')
/*23*/INSERT INTO zabiegi VALUES (13, 2200, '2018-06-05 15:15:00', '2018-06-05 15:25:00', N'Usunięcie zmian skórnych na nosie')
/*24*/INSERT INTO zabiegi VALUES (13, 1700, '2017-01-23 16:30:00', '2017-01-23 16:40:00', N'Usunięcie zmian skórnych na plecach')
/*25*/INSERT INTO zabiegi VALUES (13, 500, '2016-01-17 14:50:00', '2016-01-17 15:15:00', N'Usunięcie zmian skórnych na szyi')
/*26*/INSERT INTO zabiegi VALUES (14, 1400, '2014-11-26 07:00:00', '2014-11-26 09:30:00', N'Unieruchomienie szczęki')
/*27*/INSERT INTO zabiegi VALUES (15, 2900, '2008-12-13 12:30:00', '2008-12-13 13:00:00', N'Podanie chemii przeciw glejakowi')
/*28*/INSERT INTO zabiegi VALUES (16, 2300, '2004-07-05 13:40:00', '2004-07-05 14:10:00', N'Napromienianie guzów krtani')
/*29*/INSERT INTO zabiegi VALUES (17, 4400, '2019-09-23 14:20:00', '2019-09-23 15:10:00', N'Przeszczep serca')
/*30*/INSERT INTO zabiegi VALUES (18, 3100, '2008-01-18 12:15:00', '2008-01-18 12:30:00', N'Przeszczep lewego płuca')
GO

--	################ WYKONAWCY ZABIEGÓW ################# -- (30)

--1.
INSERT INTO wykonawcy_zabiegu VALUES (1, 1)
INSERT INTO wykonawcy_zabiegu VALUES (1, 28)
INSERT INTO wykonawcy_zabiegu VALUES (1, 23)

--2.
INSERT INTO wykonawcy_zabiegu VALUES (2, 2)
INSERT INTO wykonawcy_zabiegu VALUES (2, 23)

--3.
INSERT INTO wykonawcy_zabiegu VALUES (3, 19)

--4.
INSERT INTO wykonawcy_zabiegu VALUES (4, 28)
INSERT INTO wykonawcy_zabiegu VALUES (4, 26)

--5.
INSERT INTO wykonawcy_zabiegu VALUES (5, 4)
INSERT INTO wykonawcy_zabiegu VALUES (5, 21)
INSERT INTO wykonawcy_zabiegu VALUES (5, 23)

--6.
INSERT INTO wykonawcy_zabiegu VALUES (6, 9)
INSERT INTO wykonawcy_zabiegu VALUES (6, 23)


--7.
INSERT INTO wykonawcy_zabiegu VALUES (7, 8)
INSERT INTO wykonawcy_zabiegu VALUES (7, 23)


--8.
INSERT INTO wykonawcy_zabiegu VALUES (8, 5)
INSERT INTO wykonawcy_zabiegu VALUES (8, 23)


--9.
INSERT INTO wykonawcy_zabiegu VALUES (9, 10)
INSERT INTO wykonawcy_zabiegu VALUES (9, 23)


--10.
INSERT INTO wykonawcy_zabiegu VALUES (10, 29)
INSERT INTO wykonawcy_zabiegu VALUES (10, 26)

--11.
INSERT INTO wykonawcy_zabiegu VALUES (11, 2)
INSERT INTO wykonawcy_zabiegu VALUES (11, 23)

--12.
INSERT INTO wykonawcy_zabiegu VALUES (12, 1)
INSERT INTO wykonawcy_zabiegu VALUES (12, 23)
INSERT INTO wykonawcy_zabiegu VALUES (12, 27)


--13.
INSERT INTO wykonawcy_zabiegu VALUES (13, 19)
INSERT INTO wykonawcy_zabiegu VALUES (13, 23)

--14.
INSERT INTO wykonawcy_zabiegu VALUES (14, 29)
INSERT INTO wykonawcy_zabiegu VALUES (14, 23)

--15.
INSERT INTO wykonawcy_zabiegu VALUES (15, 4)
INSERT INTO wykonawcy_zabiegu VALUES (15, 23)

--16.
INSERT INTO wykonawcy_zabiegu VALUES (16, 9)

--17.
INSERT INTO wykonawcy_zabiegu VALUES (17, 10)

--18.
INSERT INTO wykonawcy_zabiegu VALUES (18, 10)

--19.
INSERT INTO wykonawcy_zabiegu VALUES (19, 8)
INSERT INTO wykonawcy_zabiegu VALUES (19, 23)

--20.
INSERT INTO wykonawcy_zabiegu VALUES (20, 7)
INSERT INTO wykonawcy_zabiegu VALUES (20, 23)

--21.
INSERT INTO wykonawcy_zabiegu VALUES (21, 28)
INSERT INTO wykonawcy_zabiegu VALUES (21, 24)

--22.
INSERT INTO wykonawcy_zabiegu VALUES (22, 1)
INSERT INTO wykonawcy_zabiegu VALUES (22, 21)
INSERT INTO wykonawcy_zabiegu VALUES (22, 23)

--23.
INSERT INTO wykonawcy_zabiegu VALUES (23, 15)

--24.
INSERT INTO wykonawcy_zabiegu VALUES (24, 20)
INSERT INTO wykonawcy_zabiegu VALUES (24, 15)

--25.
INSERT INTO wykonawcy_zabiegu VALUES (25, 20)
INSERT INTO wykonawcy_zabiegu VALUES (25, 19)

--26.
INSERT INTO wykonawcy_zabiegu VALUES (26, 1)
INSERT INTO wykonawcy_zabiegu VALUES (26, 23)

--27.
INSERT INTO wykonawcy_zabiegu VALUES (27, 12)

--28.
INSERT INTO wykonawcy_zabiegu VALUES (28, 13)

--29.
INSERT INTO wykonawcy_zabiegu VALUES (29, 1)
INSERT INTO wykonawcy_zabiegu VALUES (29, 22)
INSERT INTO wykonawcy_zabiegu VALUES (29, 23)
INSERT INTO wykonawcy_zabiegu VALUES (29, 25)

--30.
INSERT INTO wykonawcy_zabiegu VALUES (30, 4)
INSERT INTO wykonawcy_zabiegu VALUES (30, 5)
INSERT INTO wykonawcy_zabiegu VALUES (30, 23)
GO


--	################ BADANIA ################# -- (90)


/* 1*/INSERT INTO badania VALUES (1, '2017-08-10 12:00:00', 0, N'Badanie krwi pod kątem zmian onkologicznych.', NULL)
/* 2*/INSERT INTO badania VALUES (1, '2017-08-16 12:00:00', 0, N'Prześwietlenie klatki piersiowej - płuc.', 1)
/* 3*/INSERT INTO badania VALUES (1, '2017-08-18 12:00:00', 0, N'Bronchoskopia płuc.', 2)
/* 4*/INSERT INTO badania VALUES (1, '2018-04-23 16:30:00', 0, N'Prześwietlenie klatki piersiowej - płuc.', NULL)
/* 5*/INSERT INTO badania VALUES (1, '2012-09-28 08:15:00', 0, N'Badanie wycinka z prawej ręki.', NULL)
/* 6*/INSERT INTO badania VALUES (2, '2016-12-01 10:20:00', 400, N'Pomiar soczewki.', NULL)
/* 7*/INSERT INTO badania VALUES (3, '2007-06-04 13:05:00', 0, N'Echo serca.', NULL)
/* 8*/INSERT INTO badania VALUES (3, '2007-06-12 13:05:00', 0, N'EKG.', 7)
/* 9*/INSERT INTO badania VALUES (5, '2008-12-09 09:57:00', 0, N'Prześwietlenie odcinka szyjnego - przełyk.', NULL)
/*10*/INSERT INTO badania VALUES (6, '2017-08-10 15:30:00', 0, N'Badanie wycinka znamienia - twarz.', NULL)
/*11*/INSERT INTO badania VALUES (6, '2017-08-15 15:30:00', 0, N'Ponownienie badanie wycinka znamienia.', 10)
/*12*/INSERT INTO badania VALUES (6, '2005-06-02 17:00:00', 0, N'Zmierzenie ciśnienie dna oka.', NULL)
/*13*/INSERT INTO badania VALUES (6, '2008-02-09 14:10:00', 0, N'Prześwietlenie ramienia.', NULL)
/*14*/INSERT INTO badania VALUES (7, '2016-04-04 11:10:00', 0, N'Prześwietlenie czaszki.', NULL)
/*15*/INSERT INTO badania VALUES (7, '2016-04-04 11:20:00', 0, N'Badnie krwi na rezonans.', 14)
/*16*/INSERT INTO badania VALUES (7, '2016-04-04 12:10:00', 0, N'Rezonans magnetyczny czaszki z kontrastem.', 15)
/*17*/INSERT INTO badania VALUES (7, '2005-04-03 12:20:00', 800, N'Badanie wycinka - lewa noga.', NULL)
/*18*/INSERT INTO badania VALUES (8, '2003-11-02 18:05:00', 0, N'Badanie dna oka.', NULL)
/*19*/INSERT INTO badania VALUES (8, '2003-11-04 18:05:00', 0, N'Prześwietlenie gałki ocznej.', 18)
/*20*/INSERT INTO badania VALUES (9, '2006-02-03 14:55:00', 100, N'Badanie ciśnienia krwi.', NULL)
/*21*/INSERT INTO badania VALUES (10, '2016-03-03 08:00:00', 200, N'Prześwietlenie klatki piersiowej.', NULL)
/*22*/INSERT INTO badania VALUES (10, '2016-03-04 08:00:00', 0, N'Badanie krwii na rezonans.', 21)
/*23*/INSERT INTO badania VALUES (10, '2016-03-08 08:00:00', 0, N'Rezonans magnetyczny klatki piersiowej z kontrastem.', 22)
/*24*/INSERT INTO badania VALUES (11, '2018-03-01 10:40:00', 300, N'Badanie krwi pod kątem zmian onkologicznych.', NULL)
/*25*/INSERT INTO badania VALUES (11, '2018-03-02 10:40:00', 700, N'Rentgen odcinka szyjnego.', 24)
/*26*/INSERT INTO badania VALUES (12, '2004-05-16 13:05:00', 0, N'Badnie ciśnienia gałki ocznej.', NULL)
/*27*/INSERT INTO badania VALUES (12, '2015-07-17 14:02:00', 0, N'EKG.', NULL)
/*28*/INSERT INTO badania VALUES (12, '2015-07-20 14:02:00', 0, N'Rezonans serca.', 27)
/*29*/INSERT INTO badania VALUES (12, '2015-07-23 14:02:00', 0, N'Pomiar ciśnienia tętniczego.', 28)
/*30*/INSERT INTO badania VALUES (14, '2014-11-26 07:00:00', 0, N'Prześwietlenie czaszki.', NULL)
/*31*/INSERT INTO badania VALUES (15, '2008-12-05 12:30:00', 0, N'Badanie krwi pod kątem zmian onkologicznych.', NULL)
/*32*/INSERT INTO badania VALUES (15, '2008-12-10 12:30:00', 300, N'Prześwietlenie czaszki.', 31)
/*33*/INSERT INTO badania VALUES (16, '2004-06-30 13:40:00', 800, N'Badanie krwi pod kątem zmian onkologicznych.', NULL)
/*34*/INSERT INTO badania VALUES (16, '2004-06-30 13:40:00', 200, N'Prześwietlenie odcinka szyjnego.', 33)
/*35*/INSERT INTO badania VALUES (17, '2019-08-28 14:20:00', 0, N'EKG.', NULL)
/*36*/INSERT INTO badania VALUES (17, '2019-09-02 14:20:00', 0, N'Badanie krwii - nieprawidłowości.', 35)
/*37*/INSERT INTO badania VALUES (17, '2019-09-08 14:20:00', 0, N'Echo serca.', 36)
/*38*/INSERT INTO badania VALUES (17, '2019-09-10 14:20:00', 300, N'Próba wysiłkowa.', 37)
/*39*/INSERT INTO badania VALUES (17, '2019-09-22 14:20:00', 0, N'Ponowne badnie krwii.', 38)
/*40*/INSERT INTO badania VALUES (18, '2008-01-04 12:15:00', 0, N'Bronchoskopia płuc.', NULL)
/*41*/INSERT INTO badania VALUES (18, '2008-01-12 12:15:00', 200, N'Prześwietlenie klatki piersiowej.', 40)
/*42*/INSERT INTO badania VALUES (20, '2010-11-09 08:20:00', 0, N'Pomiar masy ciała i wzrostu i obwodu pasa.', NULL)
/*43*/INSERT INTO badania VALUES (24, '2016-08-03 16:30:00', 400, N'Badanie fizykalne jamy ustnej i gardła.', NULL)
/*44*/INSERT INTO badania VALUES (24, '2007-09-23 19:05:00', 300, N'Badanie fizykalne węzłów chłonnych.', NULL)
/*45*/INSERT INTO badania VALUES (25, '2016-03-17 08:10:00', 0, N'Kontrola okulistyczna.', NULL)
/*46*/INSERT INTO badania VALUES (26, '2012-06-11 11:25:00', 0, N'RTG klatki piersiowej.', NULL)
/*47*/INSERT INTO badania VALUES (27, '2012-06-06 12:05:00', 500, N'Badanie poziomu cholesterolu.', NULL)
/*48*/INSERT INTO badania VALUES (27, '2012-06-07 11:55:00', 0, N'Badanie poziomu glukozy w surowicy.', 47)
/*49*/INSERT INTO badania VALUES (27, '2012-07-01 10:55:00', 300, N'Pomiar elektrolitów.', 48)
/*50*/INSERT INTO badania VALUES (28, '2006-03-14 18:45:00', 0, N'Morfologia krwii.', NULL)
/*51*/INSERT INTO badania VALUES (28, '2014-07-12 15:15:00', 0, N'Pomiar ciśnienia tętniczego.', NULL)
/*52*/INSERT INTO badania VALUES (29, '2009-08-28 18:05:00', 0, N'Ocena ryzyka sercowo-naczyniowego', NULL)
/*53*/INSERT INTO badania VALUES (30, '2007-03-11 14:00:00', 0, N'Badanie moczu.', NULL)
/*54*/INSERT INTO badania VALUES (30, '2007-03-20 18:55:00', 0, N'OB.', 53)
/*55*/INSERT INTO badania VALUES (31, '2017-06-25 12:05:00', 0, N'RTG klatki piersiowej.', NULL)
/*56*/INSERT INTO badania VALUES (34, '2005-08-17 12:00:00', 0, N'Badanie fizykalne skóry.', NULL)
/*57*/INSERT INTO badania VALUES (34, '2005-08-18 10:20:00', 0, N'Badanie fizykalne jamy ustnej i gardła.', 56)
/*58*/INSERT INTO badania VALUES (34, '2005-08-22 16:45:00', 0, N'Badanie fizykalne węzłów chłonnych.', 57)
/*59*/INSERT INTO badania VALUES (34, '2005-09-23 18:50:00', 200, N'Badanie fizykalne tarczycy.', 58)
/*60*/INSERT INTO badania VALUES (36, '2008-06-13 08:15:00', 200, N'Morfologia krwii.', NULL)
/*61*/INSERT INTO badania VALUES (36, '2016-08-22 17:30:00', 0, N'Pomiar elektrolitów.', NULL)
/*62*/INSERT INTO badania VALUES (36, '2005-12-05 11:10:00', 0, N'Lipidogram.', NULL)
/*63*/INSERT INTO badania VALUES (37, '2014-03-27 10:00:00', 0, N'Badanie poziomu cholesterolu.', NULL)
/*64*/INSERT INTO badania VALUES (37, '2016-05-20 08:35:00', 0, N'Badanie poziomu glukozy w surowicy.', NULL)
/*65*/INSERT INTO badania VALUES (39, '2006-02-20 13:35:00', 0, N'Pomiar ciśnienia tętniczego.', NULL)
/*66*/INSERT INTO badania VALUES (40, '2016-02-06 16:00:00', 0, N'USG jamy brzusznej.', NULL)
/*67*/INSERT INTO badania VALUES (43, '2010-07-01 09:20:00', 0, N'Kontrola okulistyczna.', NULL)
/*68*/INSERT INTO badania VALUES (43, '2005-08-19 08:05:00', 600, N'Morfologia krwii.', NULL)
/*69*/INSERT INTO badania VALUES (43, '2006-12-31 18:10:00', 200, N'Pomiar masy ciała i wzrostu i obwodu pasa.', NULL)
/*70*/INSERT INTO badania VALUES (44, '2019-04-23 15:40:00', 700, N'Lipidogram.', NULL)
/*71*/INSERT INTO badania VALUES (45, '2003-02-14 11:00:00', 0, N'Pomiar elektrolitów.', NULL)
/*72*/INSERT INTO badania VALUES (45, '2017-02-23 12:10:00', 0, N'Pomiar ciśnienia tętniczego.', NULL)
/*73*/INSERT INTO badania VALUES (47, '2007-02-20 19:25:00', 600, N'Badanie fizykalne tarczycy.', NULL)
/*74*/INSERT INTO badania VALUES (47, '2015-07-13 14:05:00', 0, N'OB.', NULL)
/*75*/INSERT INTO badania VALUES (47, '2010-08-19 09:40:00', 900, N'Pomiar elektrolitów.', NULL)
/*76*/INSERT INTO badania VALUES (47, '2018-05-11 15:50:00', 0, N'Morfologia krwii.', NULL)
/*77*/INSERT INTO badania VALUES (48, '2018-05-17 08:45:00', 0, N'Badanie moczu.', NULL)
/*78*/INSERT INTO badania VALUES (48, '2015-11-27 18:30:00', 0, N'Ocena ryzyka sercowo-naczyniowego.', NULL)
/*79*/INSERT INTO badania VALUES (49, '2019-10-01 09:50:00', 0, N'RTG klatki piersiowej.', NULL)
/*80*/INSERT INTO badania VALUES (50, '2018-03-12 17:10:00', 0, N'Pomiar ciśnienia tętniczego.', NULL)
/*81*/INSERT INTO badania VALUES (51, '2007-12-28 17:25:00', 400, N'Badanie poziomu glukozy w surowicy.', NULL)
/*82*/INSERT INTO badania VALUES (51, '2005-01-11 12:25:00', 100, N'Badanie poziomu cholesterolu.', NULL)
/*83*/INSERT INTO badania VALUES (52, '2017-06-05 17:15:00', 0, N'Badanie fizykalne skóry.', NULL)
/*84*/INSERT INTO badania VALUES (52, '2009-08-21 08:30:00', 0, N'Badanie fizykalne jamy ustnej i gardła.', NULL)
/*85*/INSERT INTO badania VALUES (52, '2014-03-20 11:45:00', 0, N'Badanie fizykalne tarczycy.', NULL)
/*86*/INSERT INTO badania VALUES (53, '2006-11-06 09:30:00', 0, N'Badanie fizykalne węzłów chłonnych.', NULL)
/*87*/INSERT INTO badania VALUES (54, '2011-07-02 10:10:00', 0, N'RTG klatki piersiowej.', NULL)
/*88*/INSERT INTO badania VALUES (57, '2018-09-28 16:35:00', 700, N'Kontrola okulistyczna.', NULL)
/*89*/INSERT INTO badania VALUES (58, '2017-07-11 12:35:00', 0, N'USG jamy brzusznej.', NULL)
/*90*/INSERT INTO badania VALUES (60, '2018-02-27 19:35:00', 0, N'Lipidogram.', NULL)
GO


--#################################################################################################################--
--#																												  #--
--#							            ZAPYTANIA - 14 DZIELENIE, 15 REKURSYJNE      						      #--
--#																												  #--
--#################################################################################################################--



-- 1.   Podać 3 pierwsze nazwy miast, w których mieszkają pacjenci, którzy wydali najwięcej na zabiegi




SELECT TOP 3 nazwa AS 'miasta z pacjentami o największych wydatkach na zabiegi'
FROM zabiegi
INNER JOIN pacjenci P ON zabiegi.pacjent = P.id_pacjenta
INNER JOIN adresy A ON P.adres = A.id_adresu
INNER JOIN miasta M ON A.miasto = M.kod_pocztowy
GROUP BY pacjent, nazwa
ORDER BY sum(koszt) DESC
GO



-- 2.   Podać łączne obciążenie finansowe szpitala wynikające z konieczności wypłaty pensji wszystkim pracownikom
--      w roku 2010 po odliczeniu opłat za badania i zabiegi



SELECT (SELECT sum(pensja) FROM lekarze WHERE DATEPART(YEAR, zatrudniony) <= 2010) - sum(koszt)
FROM (SELECT koszt
      FROM zabiegi, pacjenci
      WHERE pacjent = id_pacjenta AND DATEPART(YEAR, rozpoczecie) = 2010
      UNION ALL
      SELECT koszt
      FROM badania, pacjenci
      WHERE pacjent = id_pacjenta AND DATEPART(YEAR, data_badania) = 2010) AS KWOTY(koszt)
GO



-- 3.   Podać lekarza, którzy wykonał najwięcej płatnych zabiegów w 2017



SELECT TOP 1 id_lekarza, imie, nazwisko, count(*) as N'ilość płatnych zabiegów'
FROM lekarze
INNER JOIN wykonawcy_zabiegu WZ ON lekarze.id_lekarza = WZ.lekarz
INNER JOIN zabiegi Z ON WZ.zabieg = Z.id_zabiegu
WHERE koszt > 0 AND datepart(YEAR, rozpoczecie) = 2017
GROUP BY id_lekarza, imie, nazwisko
ORDER BY N'ilość płatnych zabiegów' DESC
GO



-- 4.   Podać imiona i nazwiska pacjentów, którzy mieli wykonany przynajmniej jeden zabieg bez obecności chirurga,
--      a nie mieli wykonanego żadnego badania.



SELECT imie, nazwisko
FROM pacjenci
WHERE id_pacjenta NOT IN (SELECT pacjent FROM badania)
  AND id_pacjenta IN (SELECT pacjent FROM zabiegi)
  AND id_pacjenta NOT IN (
    SELECT Z.pacjent
    FROM zabiegi Z
    INNER JOIN wykonawcy_zabiegu WZ ON Z.id_zabiegu = WZ.zabieg
    INNER JOIN lekarze L ON WZ.lekarz = L.id_lekarza
    INNER JOIN profesje_lekarzy PL ON L.id_lekarza = PL.lekarz
    WHERE PL.specjalizacja LIKE 'CH%')
GO



-- 5.   Podać minimalne zarobki pracowników zatrudnionych w kolejnych latach według roku zatrudnienia. Brane pod uwagę
--      są tylko lata, podczas których zatrudnionych było min 3 pracowników, a minimalna pensja przekracza 6000.
--      Wyniki posortować malejąco.



SELECT DATEPART(YEAR, zatrudniony) AS rok, min(pensja) AS N'minimalna pensja'
FROM lekarze
GROUP BY DATEPART(YEAR, zatrudniony)
HAVING COUNT(*) > 2 AND min(pensja) > 6000
ORDER BY N'minimalna pensja' DESC
GO



-- 6.   Podać maksymalne kwoty dla specjalizacji pracowników na każdym oddziale posortować rosnąco



SELECT O.nazwa_oddzialu, max(placa_max) AS  N'najwyższa możliwa pensja'
FROM lekarze L, oddzialy O, profesje_lekarzy PL, specjalizacje S
WHERE L.oddzial = O.id_oddzialu
  AND L.id_lekarza = PL.lekarz
  AND PL.specjalizacja = S.id_spec
GROUP BY O.nazwa_oddzialu
ORDER BY N'najwyższa możliwa pensja'
GO



-- 7.   Podać pełny adres oraz sumę wydatków pacjenta z największą sumą wydatków za zabiegi



SELECT TOP 1 M.nazwa, M.wojewodztwo, A.nr_domu, A.nr_lokalu, sum(Z.koszt) AS kwota
FROM pacjenci P
INNER JOIN zabiegi Z ON P.id_pacjenta = Z.pacjent
INNER JOIN adresy A ON P.adres = A.id_adresu
INNER JOIN miasta M ON A.miasto = M.kod_pocztowy
GROUP BY M.nazwa, M.wojewodztwo, A.nr_domu, A.nr_lokalu
ORDER BY KWOTA DESC
GO



-- 8.   Pogrupować średnie zarobki lekarzy mieszkających w każdym województwie, zatrudnionych w pierwszą sobotą
--      miesiąca. Posortować po kwocie malejąco



SELECT M.wojewodztwo, avg(pensja) as N'średnia pensja wojewódzka'
FROM lekarze L, adresy A, miasta M
WHERE L.adres = A.id_adresu AND A.miasto = M.kod_pocztowy AND
      DATEPART(WEEKDAY, L.zatrudniony) = 7 AND DATEPART(DAY, L.zatrudniony) < 8
GROUP BY M.wojewodztwo
ORDER BY N'średnia pensja wojewódzka' DESC
GO



-- 9.   Porównać wydatki kobiet i mężczyzn na badania i zabiegi w sierpniu 2017 roku



SELECT sum(iif(right(imie, 1) = 'a', koszt, 0)) AS 'Panie',
       sum(iif(right(imie, 1) <> 'a', koszt, 0)) AS 'Panowie'
FROM (SELECT koszt, imie, rozpoczecie
      FROM zabiegi, pacjenci
      WHERE pacjent = id_pacjenta
      UNION ALL
      SELECT koszt, imie, data_badania
      FROM badania, pacjenci
      WHERE pacjent = id_pacjenta) AS ZSBS(koszt, imie, termin)
WHERE datepart(YEAR, termin) = 2017 AND datepart(MONTH, termin) = 8
GO



-- 10.   Podać imiona, nazwiska i miasta zamieszkania pacjentów oraz imiona i nazwiska lekarzy, którzy ich operowali,
--       a mieszkają w tym samym mieście. Uwzględnić zabiegi przed 2008 rokiem



SELECT DISTINCT concat(P.imie, ' ', P.nazwisko) AS 'Pacjent',
                concat(L.imie, ' ', L.nazwisko) AS 'Lekarz',
                M.nazwa
FROM pacjenci P
INNER JOIN zabiegi Z ON P.id_pacjenta = Z.pacjent
INNER JOIN wykonawcy_zabiegu WZ ON Z.id_zabiegu = WZ.zabieg
INNER JOIN lekarze L ON WZ.lekarz = L.id_lekarza
INNER JOIN adresy AL ON L.adres = AL.id_adresu
INNER JOIN adresy AP ON AP.id_adresu = P.adres
INNER JOIN miasta M ON AP.miasto = M.kod_pocztowy
WHERE AP.miasto = AL.miasto
  AND DATEPART(YEAR, Z.rozpoczecie) < 2008
ORDER BY M.nazwa
GO



-- 11.  Zliczyć ilość każdej biegłości dla wszystkich lekarzy szpitala niebędących lekarzami medycyny pracy. W przypadku
--      wielu specjalizacji zliczyć tylko tę, w której lekarz jest najbieglejszy.



SELECT sum(iif(bieglosc = 'wysoka', 1, 0))   AS N'Wysoka',
       sum(iif(bieglosc = N'średnia', 1, 0)) AS N'Średnia',
       sum(iif(bieglosc = 'niska', 1, 0))    AS N'Niska'
FROM profesje_lekarzy PL1
WHERE iif(PL1.bieglosc = 'wysoka', 3, iif(PL1.bieglosc = N'średnia', 2, 1)) = (
    SELECT max(iif(PL2.bieglosc = 'wysoka', 3, iif(PL2.bieglosc = N'średnia', 2, 1)))
    FROM profesje_lekarzy PL2
    WHERE PL1.lekarz = PL2.lekarz
)
GO



-- 12.  Podać minimalną płacę z mniej płatnej specjalizacji i maksymalną płacę z najbardziej płatnej specjalizacji
--      lekarzy posiadających więcej niż jedną profesję. Przy każdej parze liczb wyświetlić ich imię i nazwisko jako
--      jeden ciąg znaków oraz podać ich ID.



SELECT min(S.placa_min) AS min, max(S.placa_max) AS max, (L.imie + ' ' + L.nazwisko) AS nazwa, L.id_lekarza
FROM specjalizacje S
INNER JOIN profesje_lekarzy PL ON S.id_spec = PL.specjalizacja
INNER JOIN lekarze L ON PL.lekarz = L.id_lekarza
GROUP BY L.imie, L.nazwisko, L.id_lekarza
HAVING COUNT(*) > 1
ORDER BY max DESC
GO



-- 13.  Wypisać imiona, nazwiska oraz liczbę prezprowadzonych zabiegów dla pacjentów, którzy mieli wykonane przynajmniej
--      3 zabiegi i lekarze wykonujący te zabiegi nie byli chirurgami. Posortować po liczbie zabiegów malejąco



SELECT P.imie, P.nazwisko, count(*) AS N'liczba zabiegów'
FROM pacjenci P
INNER JOIN zabiegi Z ON P.id_pacjenta = Z.pacjent
WHERE id_zabiegu IN
      (
          SELECT zabieg
          FROM wykonawcy_zabiegu
          INNER JOIN lekarze L ON wykonawcy_zabiegu.lekarz = L.id_lekarza
          INNER JOIN profesje_lekarzy PL ON L.id_lekarza = PL.lekarz
          WHERE left(PL.specjalizacja, 2) <> 'CH'
      )
GROUP BY P.imie, P.nazwisko
HAVING count(*) > 2
ORDER BY N'liczba zabiegów' DESC
GO



-- 14.  (DZIELENIE) Podać imiona, nazwiska i ID tych anestezjologów, którzy byli obecni podczas wszystkich zabiegów
--      wykonywanych przez chirurga dowolnej specjalizacji innej niż plastycznej.



SELECT imie, nazwisko, id_lekarza
FROM lekarze L1, profesje_lekarzy PL1
WHERE id_lekarza = lekarz
  AND specjalizacja = 'AN_EST'
  AND NOT EXISTS
    (
        SELECT *
        FROM wykonawcy_zabiegu WZ, lekarze L, profesje_lekarzy PL
        WHERE WZ.lekarz = L.id_lekarza
          AND L.id_lekarza = PL.lekarz
          AND left(PL.specjalizacja, 2) = 'CH'
          AND right(PL.specjalizacja, 3) <> 'PLA'
          AND NOT EXISTS
            (
                SELECT *
                FROM wykonawcy_zabiegu
                WHERE lekarz = L1.id_lekarza
                  AND zabieg = WZ.zabieg
            )
    )
GO



-- 15.  (REKURENCJA) Wypisać ilość badań, które pociągnęły za sobą dokładnie więcej niż 1 i mniej niż 4 inne badania.
--      Pogrupować po ilości pociągniętych za sobą badań.



WITH B1(id_badania, poprzednie, poziom) AS
         (SELECT id_badania, poprzednie, 1 AS poziom
          FROM badania
          UNION ALL
          (SELECT B2.id_badania, B1.poprzednie, poziom + 1
           FROM badania B2, B1
           WHERE B2.poprzednie = B1.id_badania)),
     B2(id_badania, poziom) AS
         (SELECT DISTINCT id_badania, max(poziom) AS N'pociągnięte badania'
          FROM B1 B
          WHERE poziom BETWEEN 2 AND 3
            AND poprzednie IS NOT NULL
            AND NOT exists(SELECT id_badania FROM B1 WHERE poprzednie = B.id_badania)
          GROUP BY id_badania)
SELECT poziom AS N'długość serii', count(*) AS N'ilość'
FROM B2
GROUP BY poziom
GO



--#################################################################################################################--
--#																												  #--
--#										       PROCEDURY FUNKCJE WYZWALACZE    						              #--
--#																												  #--
--#################################################################################################################--



--  PROCEDURA 1 - procedura dodająca nowego lekarza z określonymi w przekazanej tabeli specjalizacjami.
--  W przypadku pensji wyższej niż maksymalna spośród wszystkich wybranych specjalizacji, zostaje przypisana najwyższa,
--  z tych specjalizacji. W przypadku daty zatrudnienia wyższej niż obecny dzień, zostaje wybrana dzisiejsza data.

CREATE TYPE SPECLIST AS TABLE ( spec_id CHAR(6), spec_bieg VARCHAR(7) )
GO

CREATE OR ALTER PROCEDURE PROCEDURA1(@imie VARCHAR(30), @nazwisko VARCHAR(30), @adres INT, @spec SPECLIST READONLY,
                            @data_zatrudnienia DATE, @pensja MONEY = 4000, @oddzial CHAR(2) = 'CH') AS
BEGIN
    IF @data_zatrudnienia > GETDATE()
        SET @data_zatrudnienia = GETDATE()

    DECLARE @max_placa MONEY = (SELECT max(placa_max) FROM specjalizacje, @spec WHERE id_spec = spec_id)
    IF @pensja > @max_placa
        SET @pensja = @max_placa

    DECLARE @nowe_id INT

    DECLARE @OutputTable TABLE (id INT)
    INSERT INTO lekarze OUTPUT inserted.id_lekarza INTO @OutputTable
    VALUES (@oddzial, @data_zatrudnienia, @pensja, @imie, @nazwisko, @adres)

    SET @nowe_id = (SELECT TOP 1 id FROM @OutputTable)

    DECLARE @current_sepc_id CHAR(6), @current_spec_bieg VARCHAR(7)
    DECLARE cur CURSOR FOR (SELECT * FROM @spec)
    OPEN cur
    FETCH NEXT FROM cur INTO @current_sepc_id, @current_spec_bieg

    WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO profesje_lekarzy VALUES (@nowe_id, @current_sepc_id, @current_spec_bieg)
            FETCH cur INTO @current_sepc_id, @current_spec_bieg
        END

    CLOSE cur
    DEALLOCATE cur

END
GO

-- DECLARE @specjalizacje SPECLIST
-- INSERT @specjalizacje VALUES ('CH_KLP', N'średnia'), ('CH_PLA', 'niska')
-- EXEC PROCEDURA1 'JAN', 'KOWALSKI', 30, @specjalizacje, '2018-01-01', 40000 GO



-- PROCEDURA 2 - procedura podwyższające pensje pracowników o zadaną kwotę zaokrągloną do max(max profesja).
-- Procedura zwraca przez ostatni parametr ilość pensji, które by przekroczyły limit. Istnieje możliwość zwiększenia
-- pensji wszystkich pracowników poprzez podanie ciągu pustego jako oddział.

CREATE OR ALTER PROCEDURE PROCEDURA2(@ilosc_przekroczonych INT OUTPUT, @pensja MONEY = 300, @oddzial CHAR(2) = 'CH') AS
BEGIN
    IF @pensja < 0
        SET @pensja = 0

    DECLARE cur CURSOR FOR (SELECT id_lekarza, pensja FROM lekarze WHERE oddzial = @oddzial OR @oddzial = '')
    OPEN cur

    DECLARE @id_lekarza INT, @aktualna_pensja MONEY, @max_pensja MONEY
    FETCH NEXT FROM cur INTO @id_lekarza, @aktualna_pensja

    WHILE @@fetch_status = 0
        BEGIN
            SET @max_pensja = (
                SELECT max(placa_max)
                FROM specjalizacje S, profesje_lekarzy PL
                WHERE S.id_spec = PL.specjalizacja
                  AND PL.lekarz = @id_lekarza
            )
            IF @aktualna_pensja + @pensja > @max_pensja
                BEGIN
                    SET @aktualna_pensja = @max_pensja
                    SET @ilosc_przekroczonych += 1
                END
            ELSE SET @aktualna_pensja += @pensja
            UPDATE lekarze SET pensja = @aktualna_pensja WHERE id_lekarza = @id_lekarza
            FETCH NEXT FROM cur INTO @id_lekarza, @aktualna_pensja
        END

    CLOSE cur
    DEALLOCATE cur
END
GO

-- DECLARE @ilosc INT = 0
-- EXEC PROCEDURA2 @ilosc OUTPUT, 3000, ''



-- PROCEDURA 3 - procedura usuwająca z bazy informacje o wszystkich zabiegach wybranego pacjenta przed
-- wskazaną datą. Procedura zwraca ciąg znaków przechowujący imię i nazwisko oraz ilość usuniętych zabiegów.

CREATE OR ALTER PROCEDURE PROCEDURA3(@log VARCHAR(100) OUTPUT, @pacjent INT, @data DATE = '2010-01-01') AS
BEGIN
    SET @log = (SELECT imie + ' ' + nazwisko + ' ' FROM pacjenci WHERE id_pacjenta = @pacjent)
    SET @log += N'usunięte zabiegi: '

    DELETE
    FROM wykonawcy_zabiegu
    WHERE zabieg IN (SELECT id_zabiegu FROM zabiegi WHERE pacjent = @pacjent AND rozpoczecie < @data)

    DECLARE @usuniete_zabiegi AS TABLE ( zabieg INT )
    DELETE
    FROM zabiegi
    OUTPUT deleted.id_zabiegu INTO @usuniete_zabiegi
    WHERE pacjent = @pacjent AND rozpoczecie < @data

    SET @log += (SELECT cast(count(zabieg) AS VARCHAR(4)) + ' ' FROM @usuniete_zabiegi)
END
GO

-- SELECT * from zabiegi WHERE pacjent = 10
-- DECLARE @log VARCHAR(100)
-- EXEC PROCEDURA3 @log OUTPUT, 10, '2016-03-04'
-- SELECT * from zabiegi WHERE pacjent = 10
-- PRINT @log
-- GO



--#################################################################################################################--
--#																												  #--
--#										                FUNKCJE     						                      #--
--#																												  #--
--#################################################################################################################--



-- FUNKCJA - funkcja zwracająca łączne zarobki lekarzy o określonej specjalizacji z tytułu wykonanych zabiegów dla
--           danego roku i miasta. Jeśli podany kod pocztowy jest NULL wtedy brane pod uwagę są wszystkie miasta

CREATE OR ALTER FUNCTION FUNKCJA(@spec CHAR(6) = 'CH_KLP', @rok INT = 2007, @miasto VARCHAR(6) = NULL) RETURNS MONEY AS
BEGIN
    DECLARE @value MONEY = (SELECT sum(koszt) FROM zabiegi
    INNER JOIN wykonawcy_zabiegu WZ ON zabiegi.id_zabiegu = WZ.zabieg
    INNER JOIN lekarze L ON WZ.lekarz = L.id_lekarza
    INNER JOIN profesje_lekarzy PL ON L.id_lekarza = PL.lekarz
    INNER JOIN adresy A ON L.adres = A.id_adresu
    WHERE specjalizacja = @spec
      AND datepart(YEAR, rozpoczecie) = @rok
      AND (miasto = @miasto OR @miasto IS NULL))

    RETURN iif(@value IS NULL, 0, @value)
END
GO

SELECT dbo.FUNKCJA(DEFAULT, DEFAULT, '62-500') AS N'wywołanie'



--#################################################################################################################--
--#																												  #--
--#										            WYZWALACZE    						                          #--
--#																												  #--
--#################################################################################################################--



-- WYZWALACZ1 - wyzwalacz, który wymusza minimum poziom średni w przypadku 2 zabiegów i wysoki w przypadku min 3
--              zabiegów w momencie aktualizacji poziomu biegłości danego lekarza w danej dziedzinie przy wcześniej
--              wymienionej liczbie przeprowadzonych zabiegów z innym lekarzem o tej profesji.

CREATE OR ALTER TRIGGER WYZWALACZ1
    ON profesje_lekarzy
    INSTEAD OF UPDATE AS
    BEGIN
        DECLARE @lekarz INT, @profesja CHAR(6), @bieglosc NVARCHAR(7)

        SELECT @lekarz = lekarz, @profesja = specjalizacja, @bieglosc = bieglosc FROM inserted

        DECLARE @ilosc_mentorskich_zabiegow INT =

            (SELECT count(*)
             FROM zabiegi Z
             INNER JOIN wykonawcy_zabiegu WZ ON Z.id_zabiegu = WZ.zabieg
             WHERE WZ.lekarz = @lekarz
               AND id_zabiegu IN (
                 SELECT zabieg
                 FROM wykonawcy_zabiegu WZ2
                 INNER JOIN profesje_lekarzy PL ON WZ2.lekarz = PL.lekarz
                 WHERE PL.specjalizacja = @profesja AND WZ2.lekarz <> @lekarz))

        IF @ilosc_mentorskich_zabiegow > 2
        BEGIN
            SET @bieglosc = N'wysoka'
        END
        ELSE IF @ilosc_mentorskich_zabiegow > 1
        BEGIN
            SET @bieglosc = IIF(@bieglosc = N'niska', N'średnia', @bieglosc)
        END
        UPDATE profesje_lekarzy SET bieglosc = @bieglosc WHERE lekarz = @lekarz AND specjalizacja = @profesja
    END
GO

-- SELECT * from profesje_lekarzy WHERE lekarz = 20 AND specjalizacja = 'DE_RMA'
-- UPDATE profesje_lekarzy SET bieglosc = 'niska' WHERE lekarz = 20 AND specjalizacja = 'DE_RMA'
-- SELECT * from profesje_lekarzy WHERE lekarz = 20 AND specjalizacja = 'DE_RMA'



-- WYZWALACZ2 - wyzwalacz logujący informacje o wszystkich badaniach pacjenta w momencie dodania nowego badania
--              dla niego.



CREATE OR ALTER TRIGGER WYZWALACZ2
    ON badania
    AFTER INSERT AS
BEGIN
    DECLARE @log NVARCHAR(3000) = N'Badania pacjęta: ', @pacjent INT
    SELECT @pacjent = pacjent FROM inserted

    SELECT @log + imie + ' ' + nazwisko + + CHAR(13)
    FROM pacjenci WHERE id_pacjenta = @pacjent

    DECLARE @string VARCHAR(200)
    DECLARE cur CURSOR FOR (SELECT 'Koszt: ' + cast(koszt AS VARCHAR(7)) + CHAR(9) + opis + CHAR(13)
    FROM badania WHERE pacjent = @pacjent)

    OPEN cur

    FETCH NEXT FROM cur INTO @string
    WHILE @@fetch_status = 0
        BEGIN
            SET @log += @string
            FETCH NEXT FROM cur INTO @string
        END

    CLOSE cur
    DEALLOCATE cur
    PRINT @log + 'Koniec'
END
GO

-- INSERT INTO badania VALUES (1, GETDATE(), 300, 'Badanie przesiewowe', NULL)



-- WYZWALACZ3 - wyzwalacz aktualizujący płacę lekarza w przypadku, gdy zostanie usunięta jego profesja, tak by mieściła
--              się w przedziale [min(min profesja) ; max(max profesja)] np. z powodu oszukiwania w CV.



CREATE OR ALTER TRIGGER WYZWALACZ3
    ON profesje_lekarzy
    AFTER DELETE
    AS
BEGIN
    DECLARE kursor CURSOR FOR
        SELECT id_lekarza, pensja, placa_min, placa_max
        FROM lekarze
        INNER JOIN (
            SELECT lekarz, MIN(placa_min) placa_min, MAX(placa_max) placa_max
            FROM profesje_lekarzy, specjalizacje
            WHERE id_spec = specjalizacja
            GROUP BY lekarz)
            AS widełki ON id_lekarza = lekarz

        WHERE pensja < placa_min
           OR pensja > placa_max --Może być bez tego sprawdzenia bo i tak sprawdza w kusorze

    DECLARE @id_lekarza INT, @pensja MONEY, @placa_min MONEY, @placa_max MONEY

    OPEN kursor
    FETCH NEXT FROM kursor INTO @id_lekarza, @pensja, @placa_min, @placa_max
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @placa_min > @pensja
                UPDATE lekarze SET pensja=@placa_min WHERE id_lekarza = @id_lekarza
            ELSE IF @placa_max < @pensja
                UPDATE lekarze SET pensja=@placa_max WHERE id_lekarza = @id_lekarza

            FETCH NEXT FROM kursor INTO @id_lekarza, @pensja, @placa_min, @placa_max
        END
    CLOSE kursor
    DEALLOCATE kursor
END
GO

--DELETE FROM profesje_lekarzy WHERE lekarz=1 AND specjalizacja='CH_KLP'

--Wyświetlenie lekarzy i ich widełków zarobków

-- SELECT id_lekarza, pensja, placa_min, placa_max FROM lekarze
-- INNER JOIN (SELECT lekarz, MIN(placa_min) placa_min,  MAX(placa_max) placa_max
--             FROM profesje_lekarzy, specjalizacje
--             WHERE id_spec=specjalizacja
--             GROUP BY lekarz)
--             AS widełki ON id_lekarza=lekarz
--
--  WHERE pensja < placa_min OR pensja > placa_max
--Można dodać sprawdzenie czy ktoś jest poza widełkami

--#################################################################################################################--
--#																												  #--
--#													    NARZĘDZIA  												  #--
--#																												  #--
--#################################################################################################################--


-- SELECT * FROM miasta
-- SELECT * FROM adresy
-- SELECT * FROM specjalizacje
-- SELECT * FROM lekarze
-- SELECT * FROM profesje_lekarzy
-- SELECT * FROM oddzialy
-- SELECT * FROM pacjenci
-- SELECT * FROM zabiegi
-- SELECT * FROM wykonawcy_zabiegu
-- SELECT * FROM badania
--
-- USE master
-- GO


--#################################################################################################################--
--#																												  #--
--#													    KONIEC  												  #--
--#																												  #--
--#################################################################################################################--
