# CREATE TABLE users (
#     id INT PRIMARY KEY AUTO_INCREMENT,
#     name NVARCHAR(30)
# );
#
# INSERT INTO users(name) VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry');


-- default isolation level is REPEATABLE READ
-- that prevents Dirty Read Anomaly and Non-Repeatable Reads

-- InnoDB REPEATABLE-READ transaction isolation level prevents phantom rows,
-- but only if your SELECT query is a non-locking query.

-- in order to simulate this behaviour, it's necessary to change the
-- transaction isolation level to READ COMMITED using:

-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Non-Repeatable Read problem:

--      client might order a product based on a stock quantity value
--      that is no longer a positive integer

--      Changes to the existing rows can occur during read-only transaction