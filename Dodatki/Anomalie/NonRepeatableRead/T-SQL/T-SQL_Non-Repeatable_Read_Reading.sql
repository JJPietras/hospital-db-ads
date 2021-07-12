USE Testing;

-- DBCC USEROPTIONS;

BEGIN TRAN;

SELECT *
FROM users
WHERE id = 1

WAITFOR DELAY '00:00:10'

SELECT *
FROM users
WHERE id = 1

COMMIT TRAN;


-- Preventions:

--  Repeatable read isolation level
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    -- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

--  Explicit Update Lock
    BEGIN TRAN;

    SELECT *
    FROM users
    WITH(UPDLOCK)
    WHERE id = 1

    WAITFOR DELAY '00:00:10'

    SELECT *
    FROM users
    WHERE id = 1

    COMMIT TRAN;