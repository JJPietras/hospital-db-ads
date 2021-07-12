BEGIN TRANSACTION;

SELECT *
FROM users
WHERE id = 1;

SELECT pg_sleep(10);

SELECT *
FROM users
WHERE id = 1;

COMMIT TRANSACTION;


-- Preventions:

--  Repeatable read isolation level for transaction
--  (REPEATABLE READ == SERIALIZABLE for PostgreSQL)
    BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    SELECT *
    FROM users
    WHERE id = 1;

    SELECT pg_sleep(10);

    SELECT *
    FROM users
    WHERE id = 1;

    COMMIT TRANSACTION;


--  Explicit Shared Lock
--  (blocks everything except SELECT & SELECT FOR SHARE)
    BEGIN TRANSACTION;

    SELECT *
    FROM users
    WHERE id = 1
    FOR SHARE;

    SELECT pg_sleep(10);

    SELECT *
    FROM users
    WHERE id = 1;

    COMMIT TRANSACTION;