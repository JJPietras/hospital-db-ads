-- CREATE TABLE users (
--     id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
--     name VARCHAR(30)
-- );
--
-- INSERT INTO users(name) VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry');


-- default isolation level is READ COMMITED
-- that prevents Dirty Read Anomaly, but does not prevent Non-Repeatable Reads

-- Non-Repeatable Read problem:

--      client might order a product based on a stock quantity value
--      that is no longer a positive integer

--      Changes to the existing rows can occur during read-only transaction