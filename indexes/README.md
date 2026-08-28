# Indexes Lab

This lab is about understanding how indexes change the way MySQL reads data from the `people` table.

The target is to compare query behavior before and after adding indexes, then decide which indexes are useful for common lookup patterns.

## What This Lab Tests

The SQL in `people_indexes.sql` focuses on these cases:

1. Searching by `first_name`
2. Searching by `last_name`
3. Searching by both `first_name` and `last_name`
4. Comparing single-column indexes with a composite index
5. Checking how many rows MySQL reads while executing queries

## Main Idea

Without a useful index, MySQL may need to scan many rows to find matching records.

With a useful index, MySQL can jump directly to a smaller part of the table, which usually reduces the number of rows read and improves query time.

## Files

- `people_indexes.sql`: SQL statements used to test and compare index behavior.

## Query Flow

First, the lab runs simple `SELECT` and `EXPLAIN ANALYZE` statements against the `people` table.

These queries show the baseline behavior before adding extra indexes:

```sql
SELECT *
FROM people
WHERE first_name = 'Aaron';
```

```sql
SELECT *
FROM people
WHERE last_name = 'Smith';
```

Then the lab creates indexes:

```sql
CREATE INDEX idx_first_name ON people(first_name);
CREATE INDEX idx_last_name ON people(last_name);
```

These indexes help MySQL search efficiently when the `WHERE` clause filters by one of those columns.

The lab also tests composite indexes:

```sql
CREATE INDEX idx_full_name ON people(first_name, last_name);
```

and then replaces it with:

```sql
CREATE INDEX idx_full_name ON people(last_name, first_name);
```

This is important because column order matters in composite indexes.

## Composite Index Takeaway

An index on:

```sql
(first_name, last_name)
```

is best when queries start by filtering on `first_name`.

An index on:

```sql
(last_name, first_name)
```

is best when queries start by filtering on `last_name`, or when the query filters by both `last_name` and `first_name`.

For this query:

```sql
SELECT *
FROM people
WHERE last_name = 'Aaron'
  AND first_name = 'Smith';
```

the index `(last_name, first_name)` is the better match.

## What To Look For

When running `EXPLAIN ANALYZE`, look for:

- Whether MySQL uses an index
- How many rows MySQL expects to read
- How many rows MySQL actually reads
- Whether the query performs a table scan
- Whether the composite index is used

The final status query:

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_rows_read';
```

helps show how many InnoDB rows have been read globally by the server.

## Important Note

The script drops `idx_first_name` near the end:

```sql
DROP INDEX idx_first_name ON people;
```

That means the final index state is not the same as the middle of the lab.

Run the file step by step in the SQL console if you want to observe how each index changes the query plan.
