-- //===============================================//
--
--              PROJEKT SZPITAL
--
--  Autor:   	Jakub Pietras       (224404)
--  Autor:   	Patryk Amsolik      (224301)
--  Zajęcia: 	Wtorek 14:00-15:30
--	Termin:		16.06.2020
--
--	IDE:		MS SQL Server Management Studio 18
--	IDE:		JetBrains DataGrip 2020.1
--
--	Tabele: 	10
--  Kwerendy: 	15
--
-- //===============================================//


--#################################################################################################################--
--#																												  #--
--#													DEFINICJA													  #--
--#																												  #--
--#################################################################################################################--


IF DB_ID('szpital') IS NOT NULL
    DROP DATABASE szpital
GO

CREATE DATABASE szpital
GO

USE szpital
GO

-- lekarze
-- pacjeci
-- oddziały
-- specjalizacje
-- profesje_lekarzy
-- wykonawcy_zabiegu
-- zabiegi
-- badania
-- adresy
-- miasta

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
    id_spec    CHAR(5),
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
    oddzial     INT         NOT NULL,
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
    specjalizacja CHAR(5),
    bieglosc      NVARCHAR(7) NOT NULL,

    CONSTRAINT profesje_lekarzy_composite
        PRIMARY KEY (lekarz, specjalizacja),

    CONSTRAINT profesje_lekarzy_lekarz_foreign
        FOREIGN KEY (lekarz) REFERENCES lekarze (id_lekarza),

    CONSTRAINT profesje_lekarzy_specjalizacja_foreign
        FOREIGN KEY (specjalizacja) REFERENCES specjalizacje (id_spec),

    CONSTRAINT profesje_bieglosc_format
        CHECK (bieglosc IN ('niska', 'srednia', 'wysoka'))
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
        CHECK (nazwa_oddzialu LIKE '[A-Z][A-Z]'),

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

CREATE TABLE pacjeci
(
    id_pacjenta INT IDENTITY,
    imie        NVARCHAR(30) NOT NULL,
    nazwisko    NVARCHAR(30) NOT NULL,
    adres       INT          NOT NULL,

    CONSTRAINT pacjeci_primary
        PRIMARY KEY (id_pacjenta),

    CONSTRAINT pacjeci_imie_format
        CHECK (imie LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT pacjeci_nazwisko_format
        CHECK (nazwisko LIKE N'[A-ZĆŁŚŻŹ][a-ząćęłńóśżź]%'),

    CONSTRAINT pacjeci_adres_foreign
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
        FOREIGN KEY (pacjent) REFERENCES pacjeci (id_pacjenta),

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
        FOREIGN KEY (pacjent) REFERENCES pacjeci (id_pacjenta),

    CONSTRAINT badania_poprzednie_foreign
        FOREIGN KEY (poprzednie) REFERENCES badania (id_badania),

    CONSTRAINT badania_koszt_value
        CHECK (koszt IS NULL OR koszt > 0)
)
GO

--#################################################################################################################--
--#																												  #--
--#														DANE    												  #--
--#																												  #--
--#################################################################################################################--


--	############# MIASTA ############# -- (9)


INSERT INTO miasta VALUES ('01-000', N'Warszawa',  N'Mazowieckie')
INSERT INTO miasta VALUES ('30-000', N'Kraków',    N'Małopolskie')
INSERT INTO miasta VALUES ('60-000', N'Poznań',    N'Wielkopolskie')

INSERT INTO miasta VALUES ('26-600', N'Radom',     N'Mazowieckie')
INSERT INTO miasta VALUES ('09-400', N'Płock',     N'Mazowieckie')

INSERT INTO miasta VALUES ('33-100', N'Tarnów',    N'Małopolskie')
INSERT INTO miasta VALUES ('33-300' ,N'Nowy Sącz', N'Małopolskie')

INSERT INTO miasta VALUES ('62-800', N'Kalisz',    N'Wielkopolskie')
INSERT INTO miasta VALUES ('62-500', N'Konin',     N'Wielkopolskie')


--	############# ADRESY ############# -- (90)


--  dla lekarzy (30)
INSERT INTO adresy VALUES ('26-600', N'Diamentowa',          '12', NULL)
INSERT INTO adresy VALUES ('30-000', N'Kryształowa',         '95', NULL)
INSERT INTO adresy VALUES ('33-100', N'Skośna',              '54',  '1')
INSERT INTO adresy VALUES ('62-500', N'Skośna',              '54',  '4')
INSERT INTO adresy VALUES ('09-400', N'Dębowa',               '6', NULL)
INSERT INTO adresy VALUES ('33-300', N'Dzika',              '133',  '1')
INSERT INTO adresy VALUES ('62-800', N'Dzika',              '133', '1A')
INSERT INTO adresy VALUES ('01-000', N'Dzika',              '133',  '2')
INSERT INTO adresy VALUES ('62-800', N'Długa',               '5C', NULL)
INSERT INTO adresy VALUES ('62-800', N'Zawiszy',              '4', NULL)
INSERT INTO adresy VALUES ('62-800', N'Rębowskiego',          '1', NULL)
INSERT INTO adresy VALUES ('30-000', N'Rębowskiego',          '2', NULL)
INSERT INTO adresy VALUES ('26-600', N'Aleksandrowska',       '7', NULL)
INSERT INTO adresy VALUES ('33-300', N'Mickiewicza',         '90', NULL)
INSERT INTO adresy VALUES ('01-000', N'Okólna',              '45', '3B')
INSERT INTO adresy VALUES ('33-100', N'Kolorowa',            '31', NULL)
INSERT INTO adresy VALUES ('62-500', N'Tkaczy',              '13', NULL)
INSERT INTO adresy VALUES ('26-600', N'Chmielna',            '76', NULL)
INSERT INTO adresy VALUES ('33-300', N'Szeroka',             '5A', NULL)
INSERT INTO adresy VALUES ('09-400', N'Jana Pawła',           '9', NULL)
INSERT INTO adresy VALUES ('62-500', N'Kazimierza Wielkiego', '4',  '2')
INSERT INTO adresy VALUES ('60-000', N'Kazimierza Wielkiego', '4',  '6')
INSERT INTO adresy VALUES ('26-600', N'Gałczyńskiego',        '3', NULL)
INSERT INTO adresy VALUES ('60-000', N'Witkacego',           '59', NULL)
INSERT INTO adresy VALUES ('62-500', N'Kurpińskiego',        '84', NULL)
INSERT INTO adresy VALUES ('62-800', N'Sosnowa',             '33', '1A')
INSERT INTO adresy VALUES ('60-000', N'Mydlana',             '48', NULL)
INSERT INTO adresy VALUES ('60-000', N'Obrońców Ojczyzny',   '99', NULL)
INSERT INTO adresy VALUES ('62-500', N'Limanowskiego',       '91', '6C')
INSERT INTO adresy VALUES ('62-500', N'Adamiaków',            '5', '1B')

--dla klientów (60)
INSERT INTO adresy VALUES ('01-000', N'Polna',                        '106', NULL)
INSERT INTO adresy VALUES ('33-300', N'Leśna',                        '110', NULL)
INSERT INTO adresy VALUES ('33-100', N'Słoneczna',                   '140A', NULL)
INSERT INTO adresy VALUES ('62-500', N'Krótka',                        '72', NULL)
INSERT INTO adresy VALUES ('26-600', N'Szkolna',                       '32',  '1')
INSERT INTO adresy VALUES ('26-600', N'Szkolna',                       '32',  '2')
INSERT INTO adresy VALUES ('26-600', N'Ogrodowa',                     '112', NULL)
INSERT INTO adresy VALUES ('60-000', N'Lipowa',                        '16', NULL)
INSERT INTO adresy VALUES ('30-000', N'Łąkowa',                      '109C', NULL)
INSERT INTO adresy VALUES ('30-000', N'Brzozowa',                      '68', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kwiatowa',                      '11', NULL)
INSERT INTO adresy VALUES ('30-000', N'Kościelna',                      '4',  '1')
INSERT INTO adresy VALUES ('09-400', N'Kościelna',                      '4',  '2')
INSERT INTO adresy VALUES ('30-000', N'Kościelna',                      '4', '2B')
INSERT INTO adresy VALUES ('30-000', N'Sosnowa',                       '65', NULL)
INSERT INTO adresy VALUES ('60-000', N'Zielona',                       '91', NULL)
INSERT INTO adresy VALUES ('62-800', N'Parkowa',                      '131',  '4')
INSERT INTO adresy VALUES ('60-000', N'Parkowa',                      '131',  '7')
INSERT INTO adresy VALUES ('33-300', N'Akacjowa',                     '103', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kolejowa',                     '56B',  '1')
INSERT INTO adresy VALUES ('62-800', N'Kolejowa',                     '56B',  '2')
INSERT INTO adresy VALUES ('62-800', N'Kolejowa',                     '56B',  '3')
INSERT INTO adresy VALUES ('62-500', N'Kolejowa',                     '56B',  '4')
INSERT INTO adresy VALUES ('62-800', N'Iskry',                        '169', NULL)
INSERT INTO adresy VALUES ('62-500', N'Kluczborska',                  '197', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kontuszowa',                    '32', NULL)
INSERT INTO adresy VALUES ('09-400', N'Orlich Gniazd',                '124', NULL)
INSERT INTO adresy VALUES ('60-000', N'Lazurowa',                      '35', NULL)
INSERT INTO adresy VALUES ('33-100', N'Łagowska',                     '185', '2C')
INSERT INTO adresy VALUES ('62-800', N'Miejska',                        '9', NULL)
INSERT INTO adresy VALUES ('60-000', N'Obrońców Tobruku',            '111D', NULL)
INSERT INTO adresy VALUES ('60-000', N'Prometeusza',                   '93', NULL)
INSERT INTO adresy VALUES ('33-300', N'Pawła Stellerea',              '115', NULL)
INSERT INTO adresy VALUES ('09-400', N'Kazubów',                      '190', NULL)
INSERT INTO adresy VALUES ('01-000', N'Kazimierza Wyki',               '79',  '4')
INSERT INTO adresy VALUES ('60-000', N'Jamesa Joycea',                 '74', NULL)
INSERT INTO adresy VALUES ('30-000', N'Tadeusza Kutrzeby',             '32', NULL)
INSERT INTO adresy VALUES ('62-800', N'Szczotkarska',                  '53', NULL)
INSERT INTO adresy VALUES ('09-400', N'Strońska',                     '126', '2A')
INSERT INTO adresy VALUES ('30-000', N'Zenona Klemensiewicza',         '34', NULL)
INSERT INTO adresy VALUES ('33-100', N'Zachodzącego Słońca',           '28', NULL)
INSERT INTO adresy VALUES ('62-500', N'Stanisława Kunickiego',        '156', NULL)
INSERT INTO adresy VALUES ('33-100', N'Sosnowiecka',                  '28A', NULL)
INSERT INTO adresy VALUES ('30-000', N'Józefa Wybickiego',            '130', '5D')
INSERT INTO adresy VALUES ('01-000', N'Karola Miarki',                 '45', NULL)
INSERT INTO adresy VALUES ('62-800', N'Kazimierza Deyny',             '116', NULL)
INSERT INTO adresy VALUES ('26-600', N'Łęgi',                         '187', NULL)
INSERT INTO adresy VALUES ('60-000', N'Oławska',                       '32', '1B')
INSERT INTO adresy VALUES ('26-600', N'Okrętowa',                     '151', NULL)
INSERT INTO adresy VALUES ('01-000', N'Józefa Ignacego Kraszewskiego', '71', NULL)
INSERT INTO adresy VALUES ('09-400', N'Józefa Brandta',                 '5', NULL)
INSERT INTO adresy VALUES ('01-000', N'Jana Kędzierskiego',            '73', '2D')
INSERT INTO adresy VALUES ('60-000', N'Górczewska',                   '137', NULL)
INSERT INTO adresy VALUES ('33-100', N'Gołuchowska',                   '1C', NULL)
INSERT INTO adresy VALUES ('09-400', N'Zeusa',                        '130', NULL)
INSERT INTO adresy VALUES ('60-000', N'Budy',                         '105', NULL)
INSERT INTO adresy VALUES ('33-100', N'Czakowa',                       '78', NULL)
INSERT INTO adresy VALUES ('60-000', N'Nowej Huty',                  '138A', '3C')
INSERT INTO adresy VALUES ('33-300', N'Bronisława Markiewicza',        '22', NULL)
INSERT INTO adresy VALUES ('30-000', N'Kampinoska',                   '145', NULL)


--	############# SPECJALIZACJE ############# -- (10)


INSERT INTO specjalizacje VALUES ('AL_ERG', 'Alergologia',                 3500,  6900)
INSERT INTO specjalizacje VALUES ('AN_EST', 'Anestezjologia',              5200, 10300)
INSERT INTO specjalizacje VALUES ('CH_KLP', 'Chirurgia klatki piersiowej', 7200, 16900)
INSERT INTO specjalizacje VALUES ('CH_ONK', 'Chirurgia onkologiczna',      9600, 24500)
INSERT INTO specjalizacje VALUES ('CH_PLA', 'Chirurgia plastyczna',        8500, 19900)
INSERT INTO specjalizacje VALUES ('DE_RMA', 'Dermatologia',                3800,  8500)
INSERT INTO specjalizacje VALUES ('KA_RDI', 'Kardiologia',                 4400, 11400)
INSERT INTO specjalizacje VALUES ('MD_PRA', 'Medycyna Pracy',              3200,  6100)
INSERT INTO specjalizacje VALUES ('OK_ULI', 'Okulistyka',                  4900,  9600)
INSERT INTO specjalizacje VALUES ('ON_KOL', 'Onkologia',                   6700, 14300)


--	################ ODDZIAŁY ################ -- (8)


INSERT INTO oddzialy VALUES ('CH', N'Chirurgiczny',      NULL)
INSERT INTO oddzialy VALUES ('ON', N'Onkologiczny',      NULL)
INSERT INTO oddzialy VALUES ('AL', N'Alergologiczny',    NULL)
INSERT INTO oddzialy VALUES ('DE', N'Dermatologiczny',   NULL)
INSERT INTO oddzialy VALUES ('KA', N'Kardiologiczny',    NULL)
INSERT INTO oddzialy VALUES ('AN', N'Anestezjologiczny', NULL)
INSERT INTO oddzialy VALUES ('OK', N'Okulistyczny',      NULL)
INSERT INTO oddzialy VALUES ('PO', N'Poradnia',          NULL)


--	################ LEKARZE ################# -- (30)


INSERT INTO lekarze VALUES ('CH', '03.01.2002', 16900, N'Robert',     N'Malinowski',    1)
INSERT INTO lekarze VALUES ('CH', '06.02.2005',  9700, N'Bogumił',    N'Nowicki',       2)
INSERT INTO lekarze VALUES ('CH', '28.07.2008',  7400, N'Hanna',      N'Nowak',         3)
INSERT INTO lekarze VALUES ('CH', '01.01.2005', 14900, N'Marcel',     N'Stępień',       4)
INSERT INTO lekarze VALUES ('CH', '21.09.2003',  9600, N'Mariola',    N'Majewska',      5)

INSERT INTO lekarze VALUES ('CH', '01.03.2014', 22200, N'Waldemar',   N'Mazur',         6)
INSERT INTO lekarze VALUES ('CH', '21.02.2012', 10600, N'Jolanta',    N'Pawłowska',     7)

INSERT INTO lekarze VALUES ('CH', '01.07.2007', 15700, N'Mariola',    N'Górska',        8)
INSERT INTO lekarze VALUES ('CH', '30.05.2008', 14700, N'Krystian',   N'Błaszczyk',     9)
INSERT INTO lekarze VALUES ('CH', '29.11.2003',  9100, N'Emil',       N'Zalewski',     10)


INSERT INTO lekarze VALUES ('ON', '06.06.2012', 12100, N'Wiesława',   N'Wróblewska',   11)
INSERT INTO lekarze VALUES ('ON', '02.08.2007',  9200, N'Sylwester',  N'Woźniak',      12)
INSERT INTO lekarze VALUES ('ON', '26.06.2017',  8100, N'Lech',       N'Szymczak',     13)


INSERT INTO lekarze VALUES ('AL', '17.07.2009',  6200, N'Stefan',     N'Wysocki',      14)
INSERT INTO lekarze VALUES ('AL', '06.06.2009',  5500, N'Renata',     N'Pawłowska',    15)
INSERT INTO lekarze VALUES ('AL', '10.07.2016',  5100, N'Maciej',     N'Walczak',      16)
INSERT INTO lekarze VALUES ('AL', '09.03.2005',  4200, N'Marta',      N'Przybylska',   17)
INSERT INTO lekarze VALUES ('AL', '31.08.2020',  4300, N'Małgorzata', N'Ziółkowska',   18)


INSERT INTO lekarze VALUES ('DE', '17.01.2009',  8300, N'Grzegorz',   N'Sikorski',     19)
INSERT INTO lekarze VALUES ('DE', '09.02.2016',  5100, N'Józef',      N'Szewczyk',     20)


INSERT INTO lekarze VALUES ('KA', '18.05.2006', 10500, N'Szczepan',   N'Borowski',     21)
INSERT INTO lekarze VALUES ('KA', '06.06.2014',  5000, N'Emil',       N'Walczak',      22)


INSERT INTO lekarze VALUES ('AN', '20.04.2003', 10200, N'Mikołaj',    N'Szulc',        23)
INSERT INTO lekarze VALUES ('AN', '23.10.2017',  7600, N'Halina',     N'Sokołowska',   24)
INSERT INTO lekarze VALUES ('AN', '29.11.2016',  6200, N'Halina',     N'Jakubowska',   25)
INSERT INTO lekarze VALUES ('AN', '05.08.2010',  8500, N'Hubert',     N'Andrzejewski', 26)


INSERT INTO lekarze VALUES ('OK', '20.08.2010',  9400, N'Lech',       N'Adamski',      27)
INSERT INTO lekarze VALUES ('OK', '03.08.2004',  6700, N'Aneta',      N'Górska',       28)
INSERT INTO lekarze VALUES ('OK', '06.05.2003',  7700, N'Wiesława',   N'Baran',        29)


INSERT INTO lekarze VALUES ('PO', '01.02.2008',  5600, N'Cezary',     N'Król',         30)


--ordynatorzy


UPDATE oddzialy SET ordynator =  1 WHERE id_oddzialu = 'CH'
UPDATE oddzialy SET ordynator = 11 WHERE id_oddzialu = 'ON'
UPDATE oddzialy SET ordynator = 14 WHERE id_oddzialu = 'AL'
UPDATE oddzialy SET ordynator = 19 WHERE id_oddzialu = 'DE'
UPDATE oddzialy SET ordynator = 21 WHERE id_oddzialu = 'KA'
UPDATE oddzialy SET ordynator = 23 WHERE id_oddzialu = 'AN'
UPDATE oddzialy SET ordynator = 27 WHERE id_oddzialu = 'OK'
-- zakładamy, że poradnia nie posiada ordynatora


--	################ PROFESJE LEKARZY ################# -- (30)


INSERT INTO profesje_lekarzy VALUES (1,  'CH_KLP', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (2,  'CH_KLP', N'średnia')
INSERT INTO profesje_lekarzy VALUES (3,  'CH_KLP', N'średnia')
INSERT INTO profesje_lekarzy VALUES (4,  'CH_KLP', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (5,  'CH_KLP', N'niska')

INSERT INTO profesje_lekarzy VALUES (6,  'CH_ONK', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (7,  'CH_ONK', N'niska')

INSERT INTO profesje_lekarzy VALUES (8,  'CH_PLA', N'wysoka')
INSERT INTO profesje_lekarzy VALUES (9,  'CH_PLA', N'wysoka')
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


INSERT INTO profesje_lekarzy VALUES (1,  'CH_ONK', N'średnia')
INSERT INTO profesje_lekarzy VALUES (1,  'CH_PLA', N'średnia')

INSERT INTO profesje_lekarzy VALUES (7,  'ON_KOL', N'średnia')

INSERT INTO profesje_lekarzy VALUES (15, 'DE_RMA', N'niskie')

INSERT INTO profesje_lekarzy VALUES (27, 'AN_EST', N'niskie')


--	################ PACJĘI ################# -- (60)


INSERT INTO pacjeci VALUES (N'Dominik',     N'Wróblewski',      31)
INSERT INTO pacjeci VALUES (N'Marian',      N'Urbański',        32)
INSERT INTO pacjeci VALUES (N'Marzena',     N'Kowalczyk',       33)
INSERT INTO pacjeci VALUES (N'Sara',        N'Pietrzak',        34)
INSERT INTO pacjeci VALUES (N'Teresa',      N'Stępień',         35)
INSERT INTO pacjeci VALUES (N'Klaudia',     N'Pawlak',          36)
INSERT INTO pacjeci VALUES (N'Katarzyna',   N'Kalinowski',      37)
INSERT INTO pacjeci VALUES (N'Igor',        N'Baran',           38)
INSERT INTO pacjeci VALUES (N'Mariola',     N'Zawadzki',        39)
INSERT INTO pacjeci VALUES (N'Milena',      N'Włodarczyk',      40)
INSERT INTO pacjeci VALUES (N'Jadwiga',     N'Jasiński',        41)
INSERT INTO pacjeci VALUES (N'Patryk',      N'Kowalski',        42)
INSERT INTO pacjeci VALUES (N'Konrad',      N'Zając',           43)
INSERT INTO pacjeci VALUES (N'Bartłomiej',  N'Cieślak',         44)
INSERT INTO pacjeci VALUES (N'Karina',      N'Górski',          45)
INSERT INTO pacjeci VALUES (N'Samanta',     N'Rutkowski',       46)
INSERT INTO pacjeci VALUES (N'Renata',      N'Nowak',           47)
INSERT INTO pacjeci VALUES (N'Julia',       N'Szulc',           48)
INSERT INTO pacjeci VALUES (N'Anna',        N'Wilk',            49)
INSERT INTO pacjeci VALUES (N'Robert',      N'Krupa',           50)
INSERT INTO pacjeci VALUES (N'Mirosława',   N'Pawłowski',       51)
INSERT INTO pacjeci VALUES (N'Mariusz',     N'Sokołowski',      52)
INSERT INTO pacjeci VALUES (N'Bartłomiej',  N'Jakubowski',      53)
INSERT INTO pacjeci VALUES (N'Natalia',     N'Piotrowski',      54)
INSERT INTO pacjeci VALUES (N'Zuzanna',     N'Kubiak',          55)
INSERT INTO pacjeci VALUES (N'Zdzisław',    N'Wojciechowski',   56)
INSERT INTO pacjeci VALUES (N'Andrzej',     N'Baranowski',      57)
INSERT INTO pacjeci VALUES (N'Lech',        N'Zieliński',       58)
INSERT INTO pacjeci VALUES (N'Igor',        N'Wasilewski',      59)
INSERT INTO pacjeci VALUES (N'Zdzisław',    N'Woźniak',         60)
INSERT INTO pacjeci VALUES (N'Bogumił',     N'Rutkowski',       61)
INSERT INTO pacjeci VALUES (N'Krystyna',    N'Wójcik',          62)
INSERT INTO pacjeci VALUES (N'Walenty',     N'Sikorski',        63)
INSERT INTO pacjeci VALUES (N'Wojciech',    N'Król',            64)
INSERT INTO pacjeci VALUES (N'Adam',        N'Konieczny',       65)
INSERT INTO pacjeci VALUES (N'Patrycja',    N'Czarnecki',       66)
INSERT INTO pacjeci VALUES (N'Jakub',       N'Jasiński',        67)
INSERT INTO pacjeci VALUES (N'Magdalena',   N'Andrzejewski',    68)
INSERT INTO pacjeci VALUES (N'Kamil',       N'Król',            69)
INSERT INTO pacjeci VALUES (N'Andrzej',     N'Kaczmarek',       70)
INSERT INTO pacjeci VALUES (N'Rafał',       N'Olszewski',       71)
INSERT INTO pacjeci VALUES (N'Bartłomiej',  N'Zawadzki',        72)
INSERT INTO pacjeci VALUES (N'Sabina',      N'Nowakowski',      73)
INSERT INTO pacjeci VALUES (N'Sylwester',   N'Pietrzak',        74)
INSERT INTO pacjeci VALUES (N'Krystyna',    N'Jankowski',       75)
INSERT INTO pacjeci VALUES (N'Katarzyna',   N'Jabłoński',       76)
INSERT INTO pacjeci VALUES (N'Damian',      N'Głowacki',        77)
INSERT INTO pacjeci VALUES (N'Małgorzata',  N'Czerwiński',      78)
INSERT INTO pacjeci VALUES (N'Wiktor',      N'Konieczny',       79)
INSERT INTO pacjeci VALUES (N'Jakub',       N'Kubiak',          80)
INSERT INTO pacjeci VALUES (N'Daniel',      N'Woźniak',         81)
INSERT INTO pacjeci VALUES (N'Jędrzej',     N'Maciejewski',     82)
INSERT INTO pacjeci VALUES (N'Marzena',     N'Adamczyk',        83)
INSERT INTO pacjeci VALUES (N'Zofia',       N'Cieślak',         84)
INSERT INTO pacjeci VALUES (N'Henryk',      N'Głowacki',        85)
INSERT INTO pacjeci VALUES (N'Paulina',     N'Rutkowski',       86)
INSERT INTO pacjeci VALUES (N'Małgorzata',  N'Adamski',         87)
INSERT INTO pacjeci VALUES (N'Katarzyna',   N'Zając',           88)
INSERT INTO pacjeci VALUES (N'Sebastian',   N'Maciejewski',     89)
INSERT INTO pacjeci VALUES (N'Ireneusz',    N'Maciejewski',     90)


--	################ ZABIEGI ################# -- (30)


INSERT INTO zabiegi VALUES (1,  4600, '19.08.2017 12:00:00', '19.08.2017 12:45:00', N'Usunięcie tkanki raka płuc')
INSERT INTO zabiegi VALUES (1,  3300, '24.04.2018 16:30:00', '24.04.2018 17:30:00', N'Dalsze usunięcie tkanki raka płuc')
INSERT INTO zabiegi VALUES (1,   200, '03.10.2012 08:15:00', '03.10.2012 08:25:00', N'Wycięcie znamienia na prawej ręce')
INSERT INTO zabiegi VALUES (2,     0, '03.12.2016 10:20:00', '03.12.2016 10:40:00', N'Usunięcie zaćmy')
INSERT INTO zabiegi VALUES (3,  4400, '16.06.2007 13:05:00', '16.06.2007 16:20:00', N'Założenie bajpasów')
INSERT INTO zabiegi VALUES (4,  2600, '11.04.2013 18:10:00', '11.04.2013 20:30:00', N'Odsysanie tłuszczu z podbrzusza')
INSERT INTO zabiegi VALUES (4,  4400, '18.06.2007 15:30:00', '18.06.2007 16:00:00', N'Usunięcie nadmiaru thanki tłuszczowej z twarzy')
INSERT INTO zabiegi VALUES (5,   900, '09.12.2008 10:12:00', '09.12.2008 10:37:00', N'Usunięcie zablokowanego jedzenia z przełyku')
INSERT INTO zabiegi VALUES (6,  1200, '19.08.2017 15:30:00', '19.08.2017 15:35:00', N'Wycięcie znamienia na twarzy')
INSERT INTO zabiegi VALUES (6,   300, '09.06.2005 17:00:00', '09.06.2005 17:20:00', N'Usunięcie jaskry')
INSERT INTO zabiegi VALUES (6,   200, '09.02.2008 14:40:00', '09.02.2008 14:55:00', N'Nastawieie ramienia')
INSERT INTO zabiegi VALUES (7,     0, '04.04.2016 13:30:00', '04.04.2016 17:55:00', N'Rekonstrukcja czaszki po wypadku')
INSERT INTO zabiegi VALUES (7,   300, '10.04.2005 12:20:00', '10.04.2005 12:30:00', N'Wycięcie znamienia z lewej nogi')
INSERT INTO zabiegi VALUES (8,  1800, '07.11.2003 18:05:00', '07.11.2003 18:30:00', N'Ewisceracja lewego oka')
INSERT INTO zabiegi VALUES (9,  1500, '03.02.2006 15:09:00', '03.02.2006 15:48:00', N'Zatrzymanie krwotoku wewnętrznego')
INSERT INTO zabiegi VALUES (10, 3700, '21.12.2013 11:10:00', '21.12.2013 11:50:00', N'Podniesienie plastyczne podbródka')
INSERT INTO zabiegi VALUES (10, 1300, '30.06.2014 19:13:00', '30.06.2014 19:27:00', N'Usunięcie kurzych łapek')
INSERT INTO zabiegi VALUES (10, 1200, '11.11.2015 21:20:00', '11.11.2015 22:00:00', N'Depilacja laserowa')
INSERT INTO zabiegi VALUES (10, 3100, '10.03.2016 08:00:00', '10.03.2016 10:10:00', N'Lifting biustu')
INSERT INTO zabiegi VALUES (11, 4600, '03.03.2018 10:40:00', '03.03.2018 14:20:00', N'Usunięcie raka przełyku')
INSERT INTO zabiegi VALUES (12, 2100, '17.05.2004 13:05:00', '17.05.2004 13:20:00', N'Opasanie gałki ocznej')
INSERT INTO zabiegi VALUES (12, 4000, '26.07.2015 14:02:00', '26.07.2015 14:27:00', N'Założenie bajpasów')
INSERT INTO zabiegi VALUES (13, 2200, '05.06.2018 15:15:00', '05.06.2018 15:25:00', N'Usunięcie zmian skórnych na nosie')
INSERT INTO zabiegi VALUES (13, 1700, '23.01.2017 16:30:00', '23.01.2017 16:40:00', N'Usunięcie zmian skórnych na plecach')
INSERT INTO zabiegi VALUES (13,  500, '17.01.2016 14:50:00', '17.01.2016 15:15:00', N'Usunięcie zmian skórnych na szyi')
INSERT INTO zabiegi VALUES (14, 1400, '26.11.2014 07:00:00', '26.11.2014 09:30:00', N'Unieruchomienie szczęki')
INSERT INTO zabiegi VALUES (15, 2900, '13.12.2008 12:30:00', '13.12.2008 13:00:00', N'Podanie chemii przeciw glejakowi')
INSERT INTO zabiegi VALUES (16, 2300, '05.07.2004 13:40:00', '05.07.2004 14:10:00', N'Napromienianie guzów krtani')
INSERT INTO zabiegi VALUES (17, 4400, '23.09.2011 14:20:00', '23.09.2011 15:10:00', N'Przeszczep serca')
INSERT INTO zabiegi VALUES (18, 3100, '18.01.2008 12:15:00', '18.01.2008 12:30:00', N'Przeszczep lewego płuca')


--	################ WYKONAWCY ZABIEGÓW ################# -- (30)


INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()

INSERT INTO wykonawcy_zabiegu VALUES ()



--	################ BADANIA ################# -- (90)


INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()
INSERT INTO badania VALUES ()




--#################################################################################################################--
--#																												  #--
--#													    ZAPYTANIA  												  #--
--#																												  #--
--#################################################################################################################--



--#################################################################################################################--
--#																												  #--
--#										       PROCEDURY FUNKCJE WYZWALACZE    						              #--
--#																												  #--
--#################################################################################################################--




--#################################################################################################################--
--#																												  #--
--#													    NARZĘDZIA  												  #--
--#																												  #--
--#################################################################################################################--


SELECT * FROM miasta
SELECT * FROM adresy
SELECT * FROM specjalizacje
SELECT * FROM lekarze
SELECT * FROM profesje_lekarzy
SELECT * FROM oddzialy
SELECT * FROM pacjeci
SELECT * FROM zabiegi
SELECT * FROM wykonawcy_zabiegu
SELECT * FROM badania

USE master
GO


--#################################################################################################################--
--#																												  #--
--#													    KONIEC  												  #--
--#																												  #--
--#################################################################################################################--