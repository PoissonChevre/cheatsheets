# SQL — Sysadmin Cheat Sheet

The database tasks of a sysadmin / cloud admin: install, connect, users and rights, backup and restore, monitoring, remote access. MySQL/MariaDB and PostgreSQL side by side.

---

## Install and service

```bash
# MariaDB (or MySQL: package mysql-server, service mysql/mysqld)
apt install mariadb-server              # RHEL: dnf install mariadb-server
systemctl enable --now mariadb
mariadb-secure-installation             # Root password, remove test DB and anonymous users

# PostgreSQL
apt install postgresql                  # RHEL: dnf install postgresql-server
postgresql-setup --initdb               # RHEL only: create the data folder
systemctl enable --now postgresql
```

| | MySQL / MariaDB | PostgreSQL |
|---|---|---|
| Port | 3306 | 5432 |
| Server config | `/etc/mysql/` (Debian), `/etc/my.cnf.d/` (RHEL) | `/etc/postgresql/<ver>/main/` (Debian), `/var/lib/pgsql/data/` (RHEL) |
| Access rules | Users `'name'@'host'` | `pg_hba.conf` |
| Data | `/var/lib/mysql` | `/var/lib/postgresql` (Debian), `/var/lib/pgsql` (RHEL) |
| Logs | `journalctl -u mariadb`, `/var/log/mysql/` | `journalctl -u postgresql`, `log/` in the data folder |

---

## Connect

```bash
# MySQL / MariaDB
sudo mysql                                      # Local root via socket (no password)
mysql -u app -p -h db.example.com -P 3306 app   # User, ask password, host, port, database
mysql -u app -p -e "SHOW DATABASES;"            # One command
mysql -u app -p --ssl-mode=REQUIRED -h ...      # TLS (cloud databases); MariaDB: --ssl

# PostgreSQL
sudo -u postgres psql                           # Local superuser
psql -h db.example.com -U app -d app            # Host, user, database
psql "postgresql://app@db.example.com:5432/app?sslmode=require"
psql -U app -d app -c "SELECT now();"           # One command
```

### Password files (scripts, cron)

```ini
# ~/.my.cnf (chmod 600)
[client]
user=backup
password=secret
host=localhost
```

```
# ~/.pgpass (chmod 600) — host:port:database:user:password
db.example.com:5432:app:app:secret
```

Never put a password after `-p` on the command line: it stays in the shell history and in `ps`.

---

## Explore

| Task | MySQL / MariaDB | PostgreSQL (`psql`) |
|---|---|---|
| Databases | `SHOW DATABASES;` | `\l` (`\l+` = with size) |
| Use a database | `USE app;` | `\c app` |
| Tables | `SHOW TABLES;` | `\dt` |
| Table structure | `DESCRIBE users;` | `\d users` |
| Users | `SELECT user, host FROM mysql.user;` | `\du` |
| Version | `SELECT VERSION();` | `SELECT version();` |
| Current user | `SELECT CURRENT_USER();` | `SELECT current_user;` |
| Help | `help` | `\?` (psql), `\h` (SQL) |
| Quit | `exit` | `\q` |

---

## Databases, users, rights

### MySQL / MariaDB

```sql
CREATE DATABASE app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'app'@'localhost' IDENTIFIED BY 'S3cret!';
CREATE USER 'app'@'10.0.0.%' IDENTIFIED BY 'S3cret!';    -- From a subnet ('%' = any host)
GRANT ALL PRIVILEGES ON app.* TO 'app'@'localhost';      -- All rights on one database
GRANT SELECT ON app.* TO 'readonly'@'%';                 -- Read-only

SHOW GRANTS FOR 'app'@'localhost';
REVOKE INSERT, UPDATE ON app.* FROM 'app'@'localhost';
ALTER USER 'app'@'localhost' IDENTIFIED BY 'N3wS3cret!'; -- Change password
DROP USER 'app'@'localhost';
DROP DATABASE app;
```

`'app'@'localhost'` and `'app'@'%'` are **two different users** with their own password and rights.
`FLUSH PRIVILEGES` is only needed after editing the `mysql.*` tables by hand, not after `CREATE USER` or `GRANT`.

Backup user (for `mysqldump`):

```sql
CREATE USER 'backup'@'localhost' IDENTIFIED BY '...';
GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES, EVENT, PROCESS ON *.* TO 'backup'@'localhost';
```

### PostgreSQL

```sql
CREATE ROLE app LOGIN PASSWORD 'S3cret!';
CREATE DATABASE app OWNER app;            -- The owner can create tables in it

CREATE ROLE readonly LOGIN PASSWORD '...';
GRANT CONNECT ON DATABASE app TO readonly;
GRANT pg_read_all_data TO readonly;       -- Read all tables (PostgreSQL 14+)

ALTER ROLE app PASSWORD 'N3wS3cret!';
ALTER DATABASE app OWNER TO app;
DROP DATABASE app;                        -- Nobody must be connected to it
DROP ROLE app;
```

In PostgreSQL, a **role** is a user (with `LOGIN`) or a group. Since PostgreSQL 15, normal users can't create tables in `public` unless they own the database.

---

## Basic SQL to check data

```sql
SELECT * FROM users LIMIT 10;
SELECT id, email FROM users WHERE created_at > '2026-01-01' ORDER BY created_at DESC;
SELECT COUNT(*) FROM users;
SELECT status, COUNT(*) FROM orders GROUP BY status;
SELECT u.email, o.total FROM users u JOIN orders o ON o.user_id = u.id WHERE o.total > 100;

-- Change data: always inside a transaction, check, then COMMIT
BEGIN;
UPDATE users SET active = false WHERE last_login < '2025-01-01';
SELECT COUNT(*) FROM users WHERE active = false;   -- Is it what you expected?
COMMIT;                                            -- Or ROLLBACK;

DELETE FROM sessions WHERE expires_at < NOW();
```

Run a SQL file: `mysql -u app -p app < script.sql` / `psql -U app -d app -f script.sql`.

---

## Backup and restore

### MySQL / MariaDB

```bash
mysqldump --single-transaction --routines --events app > app.sql      # One DB, no lock (InnoDB)
mysqldump --single-transaction --all-databases > all.sql
mysqldump --single-transaction app | gzip > app_$(date +%F).sql.gz
mysqldump --no-data app > schema.sql                                   # Structure only

mysql -e "CREATE DATABASE app"
mysql app < app.sql                                                    # Restore
gunzip -c app_2026-10-24.sql.gz | mysql app
```

MariaDB 11+ names them `mariadb-dump` and `mariadb` (the `mysql*` names still work).

### PostgreSQL

```bash
pg_dump -U postgres -Fc app > app.dump               # Custom format (compressed, flexible)
pg_dump -U postgres app > app.sql                    # Plain SQL
pg_dumpall -U postgres --globals-only > roles.sql    # Roles and passwords (not in pg_dump!)
pg_dumpall -U postgres > all.sql                     # Everything

createdb -U postgres -O app app
pg_restore -U postgres -d app app.dump               # --clean --if-exists = replace existing objects
psql -U postgres -d app -f app.sql                   # Plain SQL restore
pg_restore -l app.dump                               # List the content
```

### Daily backup script

```bash
#!/bin/bash
set -euo pipefail
DIR=/backups ; DATE=$(date +%F_%H%M)
mysqldump --defaults-extra-file=/root/.backup.cnf --single-transaction --routines app \
  | gzip > "$DIR/app_$DATE.sql.gz"
find "$DIR" -name "app_*.sql.gz" -mtime +14 -delete      # Keep 14 days
```

A backup is only good if the **restore** works: test it regularly on another server or container.

---

## Monitoring and troubleshooting

| Task | MySQL / MariaDB | PostgreSQL |
|---|---|---|
| Who is connected / running | `SHOW FULL PROCESSLIST;` | `SELECT pid, usename, datname, state, query FROM pg_stat_activity;` |
| Stop a query | `KILL QUERY 123;` | `SELECT pg_cancel_backend(123);` |
| Kill a connection | `KILL 123;` | `SELECT pg_terminate_backend(123);` |
| Connections now | `SHOW STATUS LIKE 'Threads_connected';` | `SELECT count(*) FROM pg_stat_activity;` |
| Max connections | `SHOW VARIABLES LIKE 'max_connections';` | `SHOW max_connections;` |
| Read a setting | `SHOW VARIABLES LIKE 'bind_address';` | `SHOW listen_addresses;` |
| Uptime, status | `SHOW GLOBAL STATUS;` / `status` | `SELECT now() - pg_postmaster_start_time();` |
| Query plan | `EXPLAIN SELECT ...;` | `EXPLAIN ANALYZE SELECT ...;` |

### Database sizes

```sql
-- MySQL / MariaDB
SELECT table_schema AS db, ROUND(SUM(data_length + index_length) / 1024 / 1024) AS size_mb
FROM information_schema.tables GROUP BY table_schema ORDER BY size_mb DESC;

-- PostgreSQL
SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database ORDER BY pg_database_size(datname) DESC;
SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) FROM pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC LIMIT 10;
```

### Slow queries

```sql
-- MySQL / MariaDB (persistent: same keys in the server config)
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;                       -- Seconds
SHOW VARIABLES LIKE 'slow_query_log_file';

-- PostgreSQL
ALTER SYSTEM SET log_min_duration_statement = '2s';   -- Written to postgresql.auto.conf
SELECT pg_reload_conf();
```

---

## Allow remote access

1. **Listen on the network**
   - MySQL/MariaDB: `bind-address = 0.0.0.0` in the server config (default 127.0.0.1).
   - PostgreSQL: `listen_addresses = '*'` in `postgresql.conf`.
2. **Allow the user**
   - MySQL/MariaDB: create `'app'@'10.0.0.%'` (not only `'app'@'localhost'`).
   - PostgreSQL: add a line in `pg_hba.conf`:
     ```
     # TYPE  DATABASE  USER  ADDRESS       METHOD
     host    app       app   10.0.0.0/24   scram-sha-256
     ```
3. **Restart / reload**: `systemctl restart mariadb` / `systemctl reload postgresql` (`listen_addresses` needs a restart).
4. **Firewall**: open 3306 or 5432 **only** for the clients' network (`ufw allow from 10.0.0.0/24 to any port 5432 proto tcp`).
5. **Test** from the client: `nc -zv db 5432`, then connect.

Never expose a database port to the internet.

---

## In a container

```bash
docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=change-me -e MARIADB_DATABASE=app \
  -e MARIADB_USER=app -e MARIADB_PASSWORD=change-me \
  -v dbdata:/var/lib/mysql -p 127.0.0.1:3306:3306 mariadb:11

docker run -d --name pg \
  -e POSTGRES_PASSWORD=change-me -e POSTGRES_DB=app \
  -v pgdata:/var/lib/postgresql/data -p 127.0.0.1:5432:5432 postgres:17

docker exec -it db mariadb -u root -p
docker exec -it pg psql -U postgres
docker exec db mariadb-dump -u root -p"$PASS" app > app.sql
docker exec -i pg psql -U postgres -d app < app.sql
```

The `-e` variables only work the **first** time, when the volume is empty.

---

## Managed cloud databases (RDS, Azure Database...)

- No real root: the admin user has limited rights (no `SUPER` in MySQL, not a full superuser in PostgreSQL).
- TLS is often required: `--ssl-mode=REQUIRED` / `sslmode=require`.
- Network access is set in the cloud (security group, firewall rules, private endpoint), not in `bind-address`.
- Backups, snapshots, version upgrades and failover are done by the provider: CLI or console. See [AWS](../aws/aws-cheatsheet.md) and [Azure](../azure/azure-cheatsheet.md).
- Settings are changed in parameter groups / server parameters, not in config files.
- `mysqldump` / `pg_dump` still work for exports and migrations.

---

## Pitfalls

- MySQL: `'user'@'localhost'` ≠ `'user'@'%'`. Check with `SELECT user, host FROM mysql.user;`.
- `SET PASSWORD ... = PASSWORD('x')` no longer works on MySQL 8: use `ALTER USER ... IDENTIFIED BY`.
- `mysqldump` without `--single-transaction` locks tables during the dump.
- `pg_dump` does not save roles: add `pg_dumpall --globals-only`.
- Remote access needs **all** steps: listen address, user/pg_hba, firewall (and SELinux port if changed).
- `UPDATE` / `DELETE` without `WHERE` changes every row: use `BEGIN` and check before `COMMIT`.
- `DROP DATABASE` has no undo: backup first.
- Passwords in scripts: option files with `chmod 600`, never on the command line.
