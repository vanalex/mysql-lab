# Local MySQL Replication Lab

This folder contains the configuration and SQL needed to run a local source/replica replication setup.

Nothing in this folder runs automatically. Execute the commands manually when you want to create the lab.

## Goal

Create two independent MySQL server instances on the same machine:

- Source: writes happen here.
- Replica: reads binary log events from the source and replays them.

The setup uses your installed MySQL server binary:

```bash
/usr/local/mysql/bin/mysqld
```

and keeps the lab data inside this project under:

```text
replication/data/
```

## Files

- `source.cnf`: MySQL config for the source instance.
- `replica.cnf`: MySQL config for the replica instance.
- `01_source_replication_user.sql`: Creates the replication user on the source.
- `02_replica_connect_to_source.sql`: Configures the replica to follow the source.
- `03_verify_replication.sql`: Simple test queries to verify replication.
- `bin/init-local-replication.sh`: Initializes and starts the local lab automatically.

## Automated Local Setup

To run the full local setup from the project root:

```bash
bash replication/bin/init-local-replication.sh
```

The script performs the same steps described below:

- creates the runtime folders
- initializes missing source and replica data directories
- starts both MySQL instances
- creates the replication user
- connects the replica to the source
- inserts a verification row on the source
- waits until the verification row appears on the replica

The script does not delete existing data directories. If a data directory already exists and is initialized, it reuses it.

## Ports And Sockets

The two instances must not share ports, sockets, process IDs, or data directories.

This lab uses:

| Instance | Port | Socket |
| --- | ---: | --- |
| Source | `13306` | `replication/run/source.sock` |
| Replica | `13307` | `replication/run/replica.sock` |

## 1. Prepare Folders

Run this from the project root:

```bash
mkdir -p replication/data/source
mkdir -p replication/data/replica
mkdir -p replication/run
mkdir -p replication/logs
```

## 2. Initialize The Two Data Directories

Run this from the project root:

```bash
/usr/local/mysql/bin/mysqld \
  --defaults-file="$PWD/replication/source.cnf" \
  --initialize-insecure
```

```bash
/usr/local/mysql/bin/mysqld \
  --defaults-file="$PWD/replication/replica.cnf" \
  --initialize-insecure
```

`--initialize-insecure` creates the root account without a password. That is acceptable for a local throwaway lab, but not for production.

## 3. Start Source And Replica

Run this from the project root:

```bash
/usr/local/mysql/bin/mysqld \
  --defaults-file="$PWD/replication/source.cnf" \
  --daemonize
```

```bash
/usr/local/mysql/bin/mysqld \
  --defaults-file="$PWD/replication/replica.cnf" \
  --daemonize
```

## 4. Create The Replication User On The Source

Connect to the source:

```bash
/usr/local/mysql/bin/mysql \
  --socket="$PWD/replication/run/source.sock" \
  -uroot
```

Then run:

```sql
SOURCE replication/01_source_replication_user.sql;
```

## 5. Configure The Replica

Connect to the replica:

```bash
/usr/local/mysql/bin/mysql \
  --socket="$PWD/replication/run/replica.sock" \
  -uroot
```

Then run:

```sql
SOURCE replication/02_replica_connect_to_source.sql;
```

## 6. Check Replica Status

On the replica:

```sql
SHOW REPLICA STATUS\G
```

The important fields are:

- `Replica_IO_Running: Yes`
- `Replica_SQL_Running: Yes`
- `Last_IO_Error:` should be empty
- `Last_SQL_Error:` should be empty

## 7. Verify Replication

Connect to the source:

```bash
/usr/local/mysql/bin/mysql \
  --socket="$PWD/replication/run/source.sock" \
  -uroot
```

Then run:

```sql
SOURCE replication/03_verify_replication.sql;
```

Now connect to the replica:

```bash
/usr/local/mysql/bin/mysql \
  --socket="$PWD/replication/run/replica.sock" \
  -uroot
```

Then verify the row exists:

```sql
SELECT *
FROM replication_lab.replication_check;
```

If the row appears on the replica, replication is working.

## 8. Load This Project's People Data

After replication is running, load data only on the source.

Example:

```bash
/usr/local/mysql/bin/mysql \
  --socket="$PWD/replication/run/source.sock" \
  -uroot \
  < people.sql
```

Then check the replica:

```sql
SELECT COUNT(*)
FROM `mysql-lab`.people;
```

Any `CREATE INDEX`, `DROP INDEX`, `INSERT`, `UPDATE`, or `DELETE` you run on the source should be replicated to the replica.

## Stop The Lab

Use `mysqladmin` against each socket:

```bash
/usr/local/mysql/bin/mysqladmin \
  --socket="$PWD/replication/run/source.sock" \
  -uroot \
  shutdown
```

```bash
/usr/local/mysql/bin/mysqladmin \
  --socket="$PWD/replication/run/replica.sock" \
  -uroot \
  shutdown
```

## Reset The Lab

Stop both instances first, then delete only the generated runtime folders:

```bash
rm -rf replication/data replication/run replication/logs
```

After that, start again from step 1.
