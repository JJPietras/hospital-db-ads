UPDATE users
SET name = 'ABC'
WHERE id = 1;

-- Cleaning, separate transactions
SELECT pg_sleep(12);

UPDATE users
SET name = 'Adam'
WHERE id = 1;