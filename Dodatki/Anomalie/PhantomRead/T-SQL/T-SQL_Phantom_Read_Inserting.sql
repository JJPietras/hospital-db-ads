use Testing;

INSERT INTO users
VALUES ('ABC')

-- Cleaning, separate transactions
WAITFOR DELAY '00:00:12'

DELETE FROM users
WHERE name = 'ABC'