BEGIN TRANSACTION;

SELECT *
FROM users;

SELECT pg_sleep(10);

SELECT *
FROM users;

COMMIT TRANSACTION;


-- Preventions:

--  SERIALIZABLE isolation level for transaction
    BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    SELECT *
    FROM users;

    SELECT pg_sleep(10);

    SELECT *
    FROM users;

    COMMIT TRANSACTION;


--  Explicit (Advisory) Exclusive Lock
--  (blocks everything, 1 is arbitrary)
    BEGIN TRANSACTION;
    SELECT pg_advisory_xact_lock(1);

    SELECT *
    FROM users;

    SELECT pg_sleep(10);

    SELECT *
    FROM users;

    COMMIT TRANSACTION;