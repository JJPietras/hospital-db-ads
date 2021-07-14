USE testing;

INSERT INTO users(name)
VALUES('ABC');

-- Cleaning, separate transactions
SELECT SLEEP(12);

DELETE FROM users
WHERE name = 'ABC';