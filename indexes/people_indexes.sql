SHOW INDEX FROM people;

EXPLAIN ANALYZE
SELECT *
FROM people
WHERE last_name = 'Smith';

CREATE INDEX idx_last_name ON people(last_name);

EXPLAIN ANALYZE
SELECT *
FROM people
WHERE last_name = 'Smith';

EXPLAIN ANALYZE
SELECT *
FROM people
WHERE first_name = 'Aaron'
  AND last_name = 'Smith';

CREATE INDEX idx_full_name_first_last ON people(first_name, last_name);

EXPLAIN ANALYZE
SELECT *
FROM people
WHERE first_name = 'Aaron'
  AND last_name = 'Smith';

DROP INDEX idx_full_name_first_last ON people;

CREATE INDEX idx_full_name_last_first ON people(last_name, first_name);

EXPLAIN ANALYZE
SELECT *
FROM people
WHERE first_name = 'Aaron'
  AND last_name = 'Smith';

SHOW INDEX FROM people;
