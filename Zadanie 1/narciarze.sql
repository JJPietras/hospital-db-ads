use model;

GO

if exists(select 1 from master.dbo.sysdatabases where name = 'narciarze') drop database narciarze
GO
CREATE DATABASE narciarze
GO

USE narciarze;
GO

CREATE TABLE kraje (
    id_kraju int NOT NULL identity(1,1) PRIMARY KEY,
    kraj char(3) NOT NULL UNIQUE
);
 
GO

CREATE TABLE skocznie (
    id_skoczni int NOT NULL identity(1,1) PRIMARY KEY,
    miasto varchar(36),
    id_kraju int NOT NULL,
    nazwa varchar(36),
    k int,
    sedz int,
    constraint FKSkocznieKraje foreign key (id_kraju) references kraje(id_kraju)
);

GO 
 
CREATE TABLE trenerzy (
    id_trenera int NOT NULL identity(1,1) PRIMARY KEY,
    id_kraju integer NOT NULL,
    imie_t varchar(36),
    nazwisko_t varchar(36),
    data_ur_t smalldatetime,
    constraint FKTrenerzyKraje foreign key (id_kraju) references kraje(id_kraju)
);

GO
 
CREATE TABLE zawodnicy (
    id_skoczka int NOT NULL identity(1,1) PRIMARY KEY,
    imie varchar(36),
    nazwisko varchar(36),
    id_kraju int NOT NULL,
    data_ur smalldatetime,
    wzrost int,
    waga int,
    constraint FKZawodnicyKraje foreign key (id_kraju) references kraje(id_kraju)
);
 
GO

CREATE TABLE zawody (
    id_zawodow int NOT NULL identity(1,1) PRIMARY KEY,
    id_skoczni int NOT NULL,
    DATA smalldatetime,
    constraint FKZawodySkocznie foreign key (id_skoczni) references skocznie(id_skoczni)
);

GO
 
CREATE TABLE uczestnictwa_w_zawodach (
    id_zawodow int NOT NULL,
    id_skoczka int NOT NULL,
    constraint PKUczestnictwa PRIMARY KEY(id_zawodow, id_skoczka),
    constraint FKUczZaw foreign key (id_zawodow) references zawody(id_zawodow),
    constraint FKUczSkocz foreign key (id_skoczka) references zawodnicy(id_skoczka)
);

GO
 
INSERT INTO kraje VALUES ('AUT');
INSERT INTO kraje VALUES ('FIN');
INSERT INTO kraje VALUES ('GER');
INSERT INTO kraje VALUES ('JPN');
INSERT INTO kraje VALUES ('NOR');
INSERT INTO kraje VALUES ('POL');
INSERT INTO kraje VALUES ('USA');

GO
 
INSERT INTO skocznie VALUES ('Zakopane', 6, 'Wielka Krokiew', 120, 134);
INSERT INTO skocznie VALUES ('Garmisch-Partenkirchen', 3, 'Wielka Skocznia Olimpijska', 115, 125);
INSERT INTO skocznie VALUES ('Oberstdorf', 3, 'Skocznia Heiniego Klopfera', 185, 211);
INSERT INTO skocznie VALUES ('Oberstdorf', 3, 'Grosse Schattenberg', 120, 134);
INSERT INTO skocznie VALUES ('Willingen', 3, 'Grosse Muhlenkopfschanze', 130, 145);
INSERT INTO skocznie VALUES ('Kuopio', 2, 'Puijo', 120, 131);
INSERT INTO skocznie VALUES ('Lahti', 2, 'Salpausselka', 116, 128);
INSERT INTO skocznie VALUES ('Trondheim', 5, 'Granasen', 120, 132);
 
GO
 
INSERT INTO trenerzy VALUES (1, 'Alexander', 'Pointner', NULL);
INSERT INTO trenerzy VALUES (2, 'Tommi', 'Nikunen', NULL);
INSERT INTO trenerzy VALUES (5, 'Mika', 'Kojonkoski', '1963-04-19');
INSERT INTO trenerzy VALUES (6, NULL, 'Kuttin', '1971-01-05');
INSERT INTO trenerzy VALUES (3, 'Wolfang', 'Steiert', '1963-04-19');
INSERT INTO trenerzy VALUES (4, 'Hirokazu', 'Yagi', NULL);
 
GO
 
INSERT INTO zawodnicy VALUES ('Marcin', 'BACHLEDA', 6, '1982-09-04', 166, 56);
INSERT INTO zawodnicy VALUES ('Robert', 'MATEJA', 6, '1976-05-31', 180, 63);
INSERT INTO zawodnicy VALUES ('Alexander', 'HERR', 3, '1978-10-04', 173, 65);
INSERT INTO zawodnicy VALUES ('Stephan', 'HOCKE', 3, '1983-10-20', 178, 59);
INSERT INTO zawodnicy VALUES ('Martin', 'SCHMITT', 3, '1978-01-29', 181, 64);
INSERT INTO zawodnicy VALUES ('Michael', 'UHRMANN', 3, '1978-09-09', 184, 64);
INSERT INTO zawodnicy VALUES ('Georg', 'SPAETH', 3, '1981-02-24', 187, 68);
INSERT INTO zawodnicy VALUES ('Matti', 'HAUTAMAEKI', 2, '1981-07-14', 174, 57);
INSERT INTO zawodnicy VALUES ('Tami', 'KIURU', 2, '1976-09-13', 183, 59);
INSERT INTO zawodnicy VALUES ('Janne', 'AHONEN', 2, '1977-05-11', 184, 67);
INSERT INTO zawodnicy VALUES ('Martin', 'HOELLWARTH', 1, '1974-04-13', 182, 67);
INSERT INTO zawodnicy VALUES ('Thomas', 'MORGENSTERN', 1, '1986-10-30', 174, 57);
INSERT INTO zawodnicy VALUES ('Tommy', 'INGEBRIGTSEN', 5, '1977-08-08', 179, 56);
INSERT INTO zawodnicy VALUES ('Bjoern-Einar', 'ROMOEREN', 5, '1981-04-01', 182, 63);
INSERT INTO zawodnicy VALUES ('Roar', 'LJOEKELSOEY', 5, '1976-05-31', 175, 62);
INSERT INTO zawodnicy VALUES ('Alan', 'ALBORN', 7, '1980-12-13', 177, 57);
INSERT INTO zawodnicy VALUES ('Adam', 'MA?YSZ', 6, '1977-12-03', 169, 60);

GO
 
INSERT INTO zawody VALUES (1, '2007-01-23');
INSERT INTO zawody VALUES (7, '2006-11-15');
INSERT INTO zawody VALUES (3, '2006-12-26');
INSERT INTO zawody VALUES (3, '2006-12-28');
INSERT INTO zawody VALUES (6, '2006-12-29');

GO
 
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 1);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 2);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 3);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 5);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 6);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 7);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 10);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 11);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 12);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 13);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 14);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 15);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 16);
INSERT INTO uczestnictwa_w_zawodach VALUES (1, 17);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 1);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 2);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 3);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 5);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 6);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 8);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 9);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 10);
INSERT INTO uczestnictwa_w_zawodach VALUES (2, 14);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 2);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 4);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 5);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 8);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 11);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 12);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 13);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 15);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 16);
INSERT INTO uczestnictwa_w_zawodach VALUES (3, 17);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 2);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 3);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 5);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 6);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 7);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 8);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 9);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 10);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 12);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 13);
INSERT INTO uczestnictwa_w_zawodach VALUES (4, 14);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 1);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 4);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 5);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 6);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 7);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 11);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 12);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 13);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 14);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 16);
INSERT INTO uczestnictwa_w_zawodach VALUES (5, 17);

GO
