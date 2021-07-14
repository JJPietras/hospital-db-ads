# CREATE TABLE users (
#     id INT PRIMARY KEY AUTO_INCREMENT,
#     name NVARCHAR(30)
# );
#
# INSERT INTO users(name) VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry');


-- default isolation level is REPEATABLE READ
-- that prevents Dirty Read Anomaly, Non-Repeatable Reads and due to fact that
-- MySQL does not offer pure REPEATABLE READ it is actually SERIALIZABLE, so it
-- does prevent Phantom Reads.

-- in order to simulate this behaviour, it's necessary to change the
-- transaction isolation level to READ COMMITED using:

-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Phantom Read problem:

--      one buyer might purchase a product without being aware of a better offer
--      that was added right after the user has finished fetching the offer list

--      Insertion matching SELECT predicate can occur during read-only transaction