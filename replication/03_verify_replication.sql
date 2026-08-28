CREATE DATABASE IF NOT EXISTS replication_lab;

USE replication_lab;

CREATE TABLE IF NOT EXISTS replication_check (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  message VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

INSERT INTO replication_check (message)
VALUES ('replication is working');

SELECT *
FROM replication_check
ORDER BY id DESC
LIMIT 5;
