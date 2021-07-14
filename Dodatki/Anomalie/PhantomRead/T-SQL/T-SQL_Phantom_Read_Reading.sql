USE Testing;

-- DBCC USEROPTIONS;

BEGIN TRAN;

SELECT *
FROM users

WAITFOR DELAY '00:00:10'

SELECT *
FROM users

COMMIT TRAN;


-- Preventions:

--  Serializable isolation level
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    -- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

--  Range Share Lock for whole transaction
    BEGIN TRAN;

    SELECT *
    FROM users
    WITH(HOLDLOCK)

    WAITFOR DELAY '00:00:10'

    SELECT *
    FROM users

    COMMIT TRAN;