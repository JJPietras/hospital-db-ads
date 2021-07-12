USE testing;

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
# SELECT @@transaction_ISOLATION;

START TRANSACTION;

SELECT *
FROM users
WHERE id = 1;

SELECT SLEEP(10);

SELECT *
FROM users
WHERE id = 1;

COMMIT;


-- Preventions:

--  Do not change default isolation level or change it to
--  Repeatable read
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

--  Explicit Update Lock
--  (blocks everything except SELECT & SELECT FOR SHARE)
    START TRANSACTION;

    SELECT *
    FROM users
    WHERE id = 1
    FOR UPDATE;

    SELECT SLEEP(10);

    SELECT *
    FROM users
    WHERE id = 1;

    COMMIT;