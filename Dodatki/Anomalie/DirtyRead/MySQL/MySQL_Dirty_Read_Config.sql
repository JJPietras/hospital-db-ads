# CREATE TABLE users (
#     id INT PRIMARY KEY AUTO_INCREMENT,
#     name NVARCHAR(30)
# );
#
# INSERT INTO users(name) VALUES ('Adam'), ('Rowan'), ('Ben'), ('Elie'), ('Thomas'), ('Larry');


# Necessary in fetch script -> default is READ REPEATABLE
# that prevents Dirty Read Anomaly and Non-Repeatable Reads
# SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;