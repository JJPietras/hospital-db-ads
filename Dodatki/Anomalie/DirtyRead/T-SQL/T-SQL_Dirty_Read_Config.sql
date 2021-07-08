-- CREATE TABLE users (
--     id INT PRIMARY KEY IDENTITY,
--     name NVARCHAR(30)
-- )
--
-- INSERT INTO users VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry')

-- Necessary in fetch script -> default is READ COMMITED
-- that prevents Dirty Read Anomaly
-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;