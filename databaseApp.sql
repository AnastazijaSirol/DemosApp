DROP DATABASE IF EXISTS trgovina;
CREATE DATABASE trgovina;
USE trgovina;
CREATE TABLE kupac (
id INTEGER NOT NULL,
ime VARCHAR(10) NOT NULL,
prezime VARCHAR(15) NOT NULL,
PRIMARY KEY (id)
);
CREATE TABLE zaposlenik (
id INTEGER NOT NULL,
ime VARCHAR(10) NOT NULL,
prezime VARCHAR(15) NOT NULL,
oib CHAR(11) NOT NULL,
datum_zaposlenja DATETIME NOT NULL,
PRIMARY KEY (id)
);
CREATE TABLE artikl (
id INTEGER NOT NULL,
naziv VARCHAR(20) NOT NULL,
cijena NUMERIC(10,2) NOT NULL,
PRIMARY KEY (id)
);
 
CREATE TABLE racun (
  id INTEGER NOT NULL,
  id_zaposlenik INTEGER NOT NULL,
  id_kupac INTEGER NOT NULL,
  broj VARCHAR(100) NOT NULL,
  datum_izdavanja DATETIME NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik (id),
  FOREIGN KEY (id_kupac) REFERENCES kupac (id)
);
CREATE TABLE stavka_racun (
  id INTEGER NOT NULL,
  id_racun INTEGER NOT NULL,
  id_artikl INTEGER NOT NULL,
  kolicina INTEGER NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_racun) REFERENCES racun (id) ON DELETE CASCADE,
  FOREIGN KEY (id_artikl) REFERENCES artikl (id),
  UNIQUE (id_racun, id_artikl)
);

INSERT INTO kupac VALUES (1, 'Lea', 'Fabris'),
                         (2, 'David', 'Sirotić'),
                         (3, 'Tea', 'Bibić');
INSERT INTO zaposlenik VALUES 
  (11, 'Marko', 'Marić', '123451', STR_TO_DATE('01.10.2020.', '%d.%m.%Y.')),
  (12, 'Toni', 'Milovan', '123452', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.')),
  (13, 'Tea', 'Marić', '123453', STR_TO_DATE('02.10.2020.', '%d.%m.%Y.'));
INSERT INTO artikl VALUES (21, 'Puding', 5.99),
                          (22, 'Milka čokolada', 30.00),
                          (23, 'Čips', 9);
INSERT INTO racun VALUES 
  (31, 11, 1, '00001', STR_TO_DATE('05.10.2020.', '%d.%m.%Y.')),
  (32, 12, 2, '00002', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.')),
  (33, 12, 1, '00003', STR_TO_DATE('06.10.2020.', '%d.%m.%Y.'));
INSERT INTO stavka_racun VALUES (41, 31, 21, 2),
                                (42, 31, 22, 5),
                                (43, 32, 22, 1),
                                (44, 32, 23, 1),
                                (45, 33, 22, 1);
   
-- procedura koja vraća stavke računa
DELIMITER //

CREATE PROCEDURE stavke_racuna(IN racun_id INT)
BEGIN
    SELECT 
        a.naziv,
        s.kolicina,
        a.cijena,
        (s.kolicina * a.cijena) AS ukupno
    FROM stavka_racun s
    JOIN artikl a ON s.id_artikl = a.id
    WHERE s.id_racun = racun_id;
END//

DELIMITER ;

CALL stavke_racuna(31)