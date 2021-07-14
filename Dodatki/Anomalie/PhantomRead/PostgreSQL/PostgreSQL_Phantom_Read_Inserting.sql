BEGIN TRANSACTION;

--  Explicit (Advisory) Exclusive Lock
--  (will wait for reading tran to unlock)
--  (blocks everything, 1 is arbitrary)
SELECT pg_advisory_xact_lock(1);

INSERT INTO users(name)
VALUES('ABC');

COMMIT TRANSACTION;

-- Cleaning, separate transactions
SELECT pg_sleep(12);

DELETE FROM users
WHERE name = 'ABC';