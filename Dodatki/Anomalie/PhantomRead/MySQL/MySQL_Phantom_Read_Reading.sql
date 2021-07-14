USE testing;

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
# SELECT @@transaction_ISOLATION;

START TRANSACTION;

SELECT *
FROM users;

SELECT SLEEP(10);

SELECT *
FROM users;

COMMIT;


-- Preventions:

--  Do not change default isolation level (if non-blocked SELECT is used)
--  or change it to SERIALIZABLE
    SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;