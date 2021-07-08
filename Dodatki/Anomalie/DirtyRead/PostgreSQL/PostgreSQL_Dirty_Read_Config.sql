-- CREATE TABLE users (
--     id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
--     name VARCHAR(30)
-- );
--
-- INSERT INTO users(name) VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry');


-- In PostgreSQL, you can request any of the four standard transaction isolation levels.

-- But internally, there are only two distinct isolation levels, which correspond to the
-- levels Read Committed and Serializable.

-- When you select the level Read Uncommitted you really get Read Committed, and when you
-- select Repeatable Read you really get Serializable, so the actual isolation level might
-- be stricter than what you select.

-- This is permitted by the SQL standard: the four isolation levels only define which
-- phenomena must not happen, they do not define which phenomena must happen.