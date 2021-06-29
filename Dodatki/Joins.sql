-- CREATE TABLE users (
--     id INT PRIMARY KEY IDENTITY,
--     name NVARCHAR(30)
-- )

-- CREATE TABLE skills (
--     id INT PRIMARY KEY IDENTITY,
--     user_id INT,
--     name NVARCHAR(30)
-- )

-- INSERT INTO users VALUES     ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry')
-- INSERT INTO skills VALUES    (1, 'Dancing'), (1, 'Skiing'), (3, 'Playing'),
--                              (4, 'Fighting'), (16, 'Singing'), (17, 'Eating')


-- ============================================== --


-- INNER JOINS
SELECT *
FROM users
INNER JOIN skills S ON users.id = S.user_id

-- OR (SAME RESULT)
SELECT *
FROM users
JOIN skills S ON users.id = S.user_id


-- ============================================== --


-- LEFT JOINS
SELECT *
FROM users
LEFT JOIN skills S ON users.id = S.user_id

-- OR (SAME RESULT)
SELECT *
FROM users
LEFT OUTER JOIN skills S ON users.id = S.user_id

-- WITHOUT "CENTER"
SELECT *
FROM users
LEFT JOIN skills S ON users.id = S.user_id
WHERE user_id IS NULL


-- ============================================== --


-- RIGHT JOINS
SELECT *
FROM users
RIGHT JOIN skills S ON users.id = S.user_id

-- OR (SAME RESULT)
SELECT *
FROM users
RIGHT OUTER JOIN skills S ON users.id = S.user_id

-- WITHOUT "CENTER"
SELECT *
FROM users
RIGHT JOIN skills S ON users.id = S.user_id
WHERE users.id IS NULL


-- ============================================== --


-- FULL OUTER JOINS
SELECT *
FROM users
FULL OUTER JOIN skills S ON users.id = S.user_id

-- OR (SAME RESULT)
SELECT *
FROM users
FULL JOIN skills S ON users.id = S.user_id

-- WITHOUT "CENTER"
SELECT *
FROM users
FULL JOIN skills S ON users.id = S.user_id
WHERE users.id IS NULL OR user_id IS NULL

-- EMULATION (WHEN OUTER IS NOT AVAILABLE)
-- eg. in SQLITE
SELECT S.id, S.user_id, S.name, U.name
FROM users U
LEFT JOIN skills S ON U.id = S.user_id
UNION ALL
SELECT S.id, S.user_id, S.name, U.name
FROM skills S
LEFT JOIN users U ON S.user_id = U.id
WHERE U.id IS NULL


-- ============================================== --


-- SELF JOINS -> Use when table references itself
-- eg. employee => manager
SELECT *
FROM users u1, users u2
WHERE u1.id <> u2.id -- or e.manager_id = b.empolyee_id

-- ALTERNATIVELY
SELECT *
FROM users u1
JOIN users u2 ON u1.id <> u2.id

-- INCLUDING JOINED DUPLICATES (CROSS JOIN)
SELECT *
FROM users u1, users u2


-- ============================================== --


-- CROSS JOINS -> Cartesian Product
-- (everyone with everyone) => many rows
SELECT *
FROM users
CROSS JOIN skills

-- OR
SELECT *
FROM users, skills;


-- ============================================== --

-- UNIONS (must have the same num of cols in both queries)
-- UNION without duplicates => DISTINCT
SELECT id, name
FROM users
UNION
SELECT id, name
FROM skills;

-- OTHER EXAMPLE => no duplications
SELECT id, name
FROM users
UNION
SELECT id, name
FROM users;

-- UNION ALL => With duplicates
-- Notice concatenation, not sorted
SELECT id, name
FROM users
UNION ALL
SELECT id, name
FROM skills;

-- OTHER EXAMPLE => duplications occurs
SELECT id, name
FROM users
UNION ALL
SELECT id, name
FROM users;