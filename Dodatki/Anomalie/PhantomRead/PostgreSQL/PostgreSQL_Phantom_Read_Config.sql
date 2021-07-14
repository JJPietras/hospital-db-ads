-- CREATE TABLE users (
--     id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
--     name VARCHAR(30)
-- );
--
-- INSERT INTO users(name) VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry');


-- default isolation level is READ COMMITED
-- that prevents Dirty Read Anomaly, but does not prevent Non-Repeatable Reads
-- nor Phantom Reads

-- Phantom Read problem:

--      one buyer might purchase a product without being aware of a better offer
--      that was added right after the user has finished fetching the offer list

--      Insertion matching SELECT predicate can occur during read-only transaction