# SQL / MySQL — Cheat Sheet 

Relational database management system for data storage, querying, and manipulation.

---

## 👤 Database & User Management

Create and manage databases and user accounts.

```sql
-- Create database
CREATE DATABASE myapp;  -- Create new database (default collation/charset)
CREATE DATABASE myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;  -- Explicit encoding

-- Select database for use
USE myapp;  -- Select database for subsequent commands

-- List databases and tables
SHOW DATABASES;  -- List all databases
SHOW TABLES;  -- List tables in current database
SHOW CREATE DATABASE myapp;  -- Show CREATE statement (charset, collation)

-- Drop database
DROP DATABASE myapp;  -- Delete database and all contents (careful!)
DROP DATABASE IF EXISTS myapp;  -- Only drop if exists (no error if missing)

-- User management
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password123';  -- Create local user
CREATE USER 'appuser'@'%' IDENTIFIED BY 'password123';  -- Create user from any host
CREATE USER 'appuser'@'192.168.1.%' IDENTIFIED BY 'password123';  -- Create user from subnet

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON myapp.* TO 'appuser'@'localhost';  -- Grant table permissions
GRANT ALL PRIVILEGES ON myapp.* TO 'appuser'@'localhost';  -- Grant all permissions
GRANT ALL PRIVILEGES ON *.* TO 'appuser'@'localhost';  -- Grant global permissions

-- Remove permissions
REVOKE INSERT, UPDATE ON myapp.* FROM 'appuser'@'localhost';  -- Revoke specific privileges

-- Manage user passwords
SET PASSWORD FOR 'appuser'@'localhost' = PASSWORD('newpassword');  -- Change password
RENAME USER 'appuser'@'localhost' TO 'newappuser'@'localhost';  -- Rename user

-- Remove user
DROP USER 'appuser'@'localhost';  -- Delete user account

-- Flush privileges
FLUSH PRIVILEGES;  -- Reload privilege tables (apply changes immediately)

-- Show user permissions
SHOW GRANTS FOR 'appuser'@'localhost';  -- List user's permissions
```

---

## DDL — Create, Alter, Drop

Define and modify table structure.

```sql
-- Create table
CREATE TABLE users (  -- Create new table
  id INT PRIMARY KEY AUTO_INCREMENT,  -- Primary key with auto-increment
  username VARCHAR(50) NOT NULL UNIQUE,  -- String, required, unique
  email VARCHAR(100) NOT NULL,
  age INT CHECK (age >= 18),  -- Check constraint (MySQL 8.0.16+)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Default current time
  is_active BOOLEAN DEFAULT TRUE,
  profile_data JSON,  -- JSON column
  FOREIGN KEY (department_id) REFERENCES departments(id)  -- Foreign key constraint
);

-- Show table structure
DESCRIBE users;  -- Show column definitions (same as DESC)
SHOW COLUMNS FROM users;  -- Alternative syntax
SHOW CREATE TABLE users;  -- Show full CREATE statement

-- Add column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);  -- Add new column
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER username;  -- Specific position

-- Modify column
ALTER TABLE users MODIFY COLUMN age INT NOT NULL;  -- Change column definition
ALTER TABLE users CHANGE COLUMN age user_age INT;  -- Change column name and definition

-- Rename table
ALTER TABLE users RENAME TO app_users;  -- Rename table
ALTER TABLE users RENAME AS app_users;  -- Alternative syntax

-- Drop column
ALTER TABLE users DROP COLUMN phone;  -- Delete column

-- Add constraint
ALTER TABLE users ADD PRIMARY KEY (id);  -- Add primary key
ALTER TABLE users ADD UNIQUE KEY unique_email (email);  -- Add unique constraint
ALTER TABLE users ADD INDEX idx_created (created_at);  -- Add index

-- Drop constraint
ALTER TABLE users DROP INDEX unique_email;  -- Remove unique index/constraint
ALTER TABLE users DROP FOREIGN KEY fk_dept;  -- Remove foreign key

-- Drop table
DROP TABLE users;  -- Delete table structure and data
DROP TABLE IF EXISTS users;  -- Only drop if exists (no error if missing)
TRUNCATE TABLE users;  -- Delete all rows but keep structure (faster than DELETE)
```

## Data types

[INT, VARCHAR, TEXT, DATE, TIMESTAMP, DECIMAL, JSON, ENUM, SET, BLOB]

```sql
CREATE TABLE products (
  id INT PRIMARY KEY,  -- Integer
  sku VARCHAR(20) UNIQUE,  -- Variable-length string
  description TEXT,  -- Long text (up to 65K)
  price DECIMAL(10,2),  -- Decimal: 10 digits total, 2 decimal places
  stock SMALLINT,  -- Smaller integer (2 bytes)
  release_date DATE,  -- Date YYYY-MM-DD
  updated_at TIMESTAMP,  -- Timestamp with time
  metadata JSON,  -- JSON object
  category ENUM('electronics', 'books', 'clothing'),  -- Fixed set of values
  tags SET('sale', 'featured', 'new'),  -- Multiple selections
  image BLOB  -- Binary large object
);
```

---

## DML — Select, Insert, Update, Delete

Query and manipulate data.

```sql
-- Select all columns
SELECT * FROM users;  -- Retrieve all data
SELECT * FROM users WHERE age > 18;  -- With condition
SELECT * FROM users LIMIT 10;  -- Limit results to 10 rows
SELECT * FROM users LIMIT 10 OFFSET 20;  -- Pagination: skip 20, get 10

-- Select specific columns
SELECT id, username, email FROM users;  -- Only these columns
SELECT id, username, email AS user_email FROM users;  -- Alias column

-- Distinct values
SELECT DISTINCT department_id FROM users;  -- Remove duplicates

-- Insert single row
INSERT INTO users (username, email, age) VALUES ('alice', 'alice@example.com', 25);
## Column order must match values order

-- Insert multiple rows
INSERT INTO users (username, email, age) VALUES
  ('bob', 'bob@example.com', 30),
  ('charlie', 'charlie@example.com', 28);

-- Insert with SELECT
INSERT INTO users_backup SELECT * FROM users WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
## Copy old data to backup table

-- Update rows
UPDATE users SET age = 26 WHERE id = 1;  -- Update single user
UPDATE users SET age = age + 1 WHERE created_at < '2020-01-01';  -- Increment by condition
UPDATE users SET is_active = FALSE, updated_at = NOW() WHERE age < 18;  -- Multiple columns

-- Delete rows
DELETE FROM users WHERE id = 1;  -- Delete specific row
DELETE FROM users WHERE age < 18;  -- Delete multiple rows (careful!)
DELETE FROM users;  -- Delete all rows (VERY CAREFUL!)
## Use transactions to test before committing

-- Delete with condition using IN
DELETE FROM users WHERE id IN (1, 2, 3);  -- Delete multiple specific IDs
DELETE FROM users WHERE id NOT IN (SELECT id FROM users_active);  -- Complex deletion
```

---

## Joins

Combine data from multiple tables.

```sql
-- INNER JOIN (only matching rows)
SELECT u.id, u.username, d.name
FROM users u
INNER JOIN departments d ON u.department_id = d.id;
## Only returns users WITH assigned departments

-- LEFT JOIN (all left table rows, matching right)
SELECT u.id, u.username, d.name
FROM users u
LEFT JOIN departments d ON u.department_id = d.id;
## Returns all users; department name NULL if not assigned

-- RIGHT JOIN (all right table rows, matching left)
SELECT u.username, d.name
FROM users u
RIGHT JOIN departments d ON u.department_id = d.id;
## Returns all departments; user names NULL if no users in department

-- CROSS JOIN (cartesian product)
SELECT * FROM users CROSS JOIN departments;
## Creates all possible combinations (careful with large tables!)

-- Self join (join table to itself)
SELECT e1.name AS employee, e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;
## Useful for hierarchical data (manager relationships)

-- Multiple joins
SELECT u.username, d.name, r.role_name
FROM users u
INNER JOIN departments d ON u.department_id = d.id
INNER JOIN roles r ON u.role_id = r.id;
## Chain joins to combine many tables

-- Join with WHERE clause
SELECT u.id, u.username, d.name
FROM users u
LEFT JOIN departments d ON u.department_id = d.id
WHERE d.name = 'Engineering' OR d.name IS NULL;
## Filter after join (WHERE) vs during join (ON)
```

---

## Indexes

Optimize query performance with indexes.

```sql
-- Create index
CREATE INDEX idx_username ON users(username);  -- Single column index
CREATE INDEX idx_email_active ON users(email, is_active);  -- Composite index (email first)

-- Create unique index
CREATE UNIQUE INDEX idx_email ON users(email);  -- Enforce uniqueness

-- Create full-text index (for text search)
CREATE FULLTEXT INDEX ft_description ON products(description);

-- List indexes
SHOW INDEXES FROM users;  -- Show all indexes on table
SHOW INDEX FROM users;  -- Alternative syntax

-- Drop index
DROP INDEX idx_username ON users;  -- Remove index

-- Query using index (explain)
EXPLAIN SELECT * FROM users WHERE username = 'alice';  # Shows execution plan
EXPLAIN SELECT * FROM users WHERE age > 25;  # Check if index used

-- Index best practices
-- Create index on: frequently queried columns, JOIN conditions, WHERE clauses
-- Avoid over-indexing: slows writes, uses disk space
-- Composite indexes: order columns by selectivity (most selective first)
```

## Composite index order

[Put most selective columns first for optimal performance]

```sql
-- For common query: WHERE is_active = TRUE AND age > 25
CREATE INDEX idx_active_age ON users(is_active, age);  -- Correct order
## Not: CREATE INDEX idx_age_active ON users(age, is_active);
```

---

## Transactions

Group statements into atomic operations.

```sql
-- Basic transaction
START TRANSACTION;  -- Begin transaction (or BEGIN)
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;  -- Save changes
## If error, ROLLBACK instead to undo all changes

-- Rollback (undo changes)
START TRANSACTION;
DELETE FROM users WHERE id = 1;
ROLLBACK;  -- Undo delete; user still exists

-- Savepoint (nested rollback)
START TRANSACTION;
INSERT INTO users VALUES (...);
SAVEPOINT sp1;
INSERT INTO orders VALUES (...);  -- Might fail
ROLLBACK TO sp1;  -- Undo INSERT orders, keep INSERT users
COMMIT;  -- Commit the user insert

-- Isolation levels
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  -- Dirty reads allowed (fast)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- Default; reads committed data
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;  -- Snapshot isolation
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;  -- Full isolation; slow

-- Check transaction status
SHOW ENGINE INNODB STATUS;  -- Show InnoDB transaction info (for debugging)
```

## ACID properties

[Atomicity, Consistency, Isolation, Durability ensure data integrity]

```sql
-- Example: transfer money (must be atomic)
START TRANSACTION;
  UPDATE accounts SET balance = balance - 500 WHERE id = 1;
  UPDATE accounts SET balance = balance + 500 WHERE id = 2;
COMMIT;
## If first update succeeds but second fails: ROLLBACK ensures both are undone
```

---

## Useful Functions

Common aggregate and scalar functions.

```sql
-- Aggregate functions (work on groups)
SELECT COUNT(*) FROM users;  -- Total number of rows
SELECT COUNT(DISTINCT department_id) FROM users;  -- Distinct departments
SELECT AVG(age) FROM users;  -- Average age
SELECT SUM(salary) FROM employees;  -- Total salary
SELECT MAX(age), MIN(age) FROM users;  -- Oldest and youngest

-- Group by
SELECT department_id, COUNT(*) as emp_count, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id;
## Aggregate per group

-- Having clause (filter groups)
SELECT department_id, AVG(salary) as avg_sal
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 50000;
## WHERE filters rows; HAVING filters groups

-- String functions
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM users;  -- Concatenate strings
SELECT UPPER(username) FROM users;  -- Uppercase
SELECT LOWER(email) FROM users;  -- Lowercase
SELECT LENGTH(description) FROM products;  -- String length
SELECT SUBSTRING(email, 1, 10) FROM users;  -- Extract substring

-- Date functions
SELECT NOW();  -- Current timestamp
SELECT CURDATE();  -- Current date
SELECT DATE_ADD(NOW(), INTERVAL 30 DAY);  -- Add 30 days
SELECT DATE_SUB(NOW(), INTERVAL 1 MONTH);  -- Subtract 1 month
SELECT YEAR(created_at), MONTH(created_at), DAY(created_at) FROM users;  -- Extract parts
SELECT DATEDIFF(NOW(), created_at) as days_since_creation FROM users;  -- Days between dates

-- Math functions
SELECT ROUND(3.14159, 2);  -- Round to 2 decimals: 3.14
SELECT ABS(-10);  -- Absolute value: 10
SELECT CEIL(3.2);  -- Ceiling: 4
SELECT FLOOR(3.8);  -- Floor: 3

-- Conditional functions
SELECT IF(age >= 18, 'Adult', 'Minor') FROM users;  -- Simple if-else
SELECT CASE
  WHEN age < 13 THEN 'Child'
  WHEN age < 18 THEN 'Teen'
  ELSE 'Adult'
END AS age_group FROM users;  -- Multiple conditions

-- NULL handling
SELECT IFNULL(phone, 'N/A') FROM users;  -- Use 'N/A' if phone is NULL
SELECT COALESCE(phone, email, 'No contact') FROM users;  -- First non-NULL value
```

---

## Backup & Restore

Export and import databases.

```bash
# Backup entire database
mysqldump -u root -p myapp > myapp_backup.sql  # Dump to file
mysqldump -u root -p --all-databases > full_backup.sql  # All databases
mysqldump -u root -p myapp --single-transaction --quick > myapp.sql  # Live backup (no lock)
## --single-transaction: consistent snapshot without locking (InnoDB)
## --quick: faster dump for large databases

# Backup specific table
mysqldump -u root -p myapp users > users_table.sql  # Single table

# Restore from backup
mysql -u root -p myapp < myapp_backup.sql  # Restore single database
mysql -u root -p < full_backup.sql  # Restore all databases

# Selective restore (table only)
mysql -u root -p myapp < users_table.sql  # Restore into same/different database

# Compressed backup
mysqldump -u root -p myapp | gzip > myapp_backup.sql.gz  # Compressed dump
zcat myapp_backup.sql.gz | mysql -u root -p myapp  # Restore compressed backup

# Check backup integrity
mysql -u root -p < myapp_backup.sql --no-data  # Validate syntax only
```

## Backup strategy

[Regular incremental backups, test restores, verify integrity]

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p"$MYSQL_PASSWORD" --single-transaction myapp | gzip > /backups/myapp_${DATE}.sql.gz
find /backups -name "myapp_*.sql.gz" -mtime +30 -delete  # Delete backups older than 30 days
```

---

## Performance Optimization

Common query tuning techniques.

```sql
-- Check query execution plan
EXPLAIN SELECT * FROM users WHERE username = 'alice';  # Shows full scan vs index use
EXPLAIN FORMAT=JSON SELECT * FROM users WHERE username = 'alice';  # Detailed JSON output

-- Analyze table (update statistics)
ANALYZE TABLE users;  -- MySQL uses stats for query optimization

-- Optimize table (defragment)
OPTIMIZE TABLE users;  -- Reclaim space, rebuild indexes (locks table briefly)

-- Find slow queries
SET GLOBAL slow_query_log = 'ON';  -- Enable slow query logging
SET GLOBAL long_query_time = 2;  -- Log queries taking > 2 seconds

-- Common performance issues
-- 1. Missing indexes on WHERE, JOIN, ORDER BY columns
-- 2. Selecting * instead of needed columns
-- 3. N+1 problem: query in loop vs single JOIN
-- 4. Subqueries in SELECT (execute for every row)
-- 5. LIKE with leading wildcard (full table scan)

-- Bad: N+1 queries
SELECT * FROM orders;
foreach order:
  SELECT * FROM users WHERE id = order.user_id;  -- Repeated query
## Good: single JOIN
SELECT o.*, u.* FROM orders o JOIN users u ON o.user_id = u.id;
```
