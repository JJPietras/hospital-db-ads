use Testing;

-- DBCC USEROPTIONS;

UPDATE users
SET name = 'ABC'
WHERE id = 1

-- Cleaning, separate transactions
WAITFOR DELAY '00:00:12'

UPDATE users
SET name = 'Adam'
WHERE id = 1