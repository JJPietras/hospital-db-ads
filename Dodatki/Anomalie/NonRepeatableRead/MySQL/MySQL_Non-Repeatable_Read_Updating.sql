USE testing;

UPDATE users
SET name = 'ABC'
WHERE id = 1;

-- Cleaning, separate transactions
SELECT SLEEP(12);

UPDATE users
SET name = 'Adam'
WHERE id = 1;