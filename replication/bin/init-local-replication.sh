#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPLICATION_DIR="$PROJECT_ROOT/replication"

MYSQL_BASE="/usr/local/mysql"
MYSQLD="$MYSQL_BASE/bin/mysqld"
MYSQL="$MYSQL_BASE/bin/mysql"
MYSQLADMIN="$MYSQL_BASE/bin/mysqladmin"

SOURCE_CNF="$REPLICATION_DIR/source.cnf"
REPLICA_CNF="$REPLICATION_DIR/replica.cnf"

SOURCE_DATA="$REPLICATION_DIR/data/source"
REPLICA_DATA="$REPLICATION_DIR/data/replica"
SOURCE_SOCKET="$REPLICATION_DIR/run/source.sock"
REPLICA_SOCKET="$REPLICATION_DIR/run/replica.sock"

log() {
  printf '[replication-lab] %s\n' "$1"
}

fail() {
  printf '[replication-lab] ERROR: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing required file: $1"
}

require_executable() {
  [[ -x "$1" ]] || fail "Missing executable: $1"
}

mysql_ping() {
  local socket="$1"
  "$MYSQLADMIN" --protocol=SOCKET --socket="$socket" -uroot ping >/dev/null 2>&1
}

wait_for_mysql() {
  local name="$1"
  local socket="$2"

  for _ in {1..60}; do
    if mysql_ping "$socket"; then
      log "$name is ready"
      return 0
    fi
    sleep 1
  done

  fail "$name did not become ready on socket $socket"
}

initialize_datadir() {
  local name="$1"
  local cnf="$2"
  local datadir="$3"

  if [[ -d "$datadir/mysql" ]]; then
    log "$name data directory already initialized"
    return 0
  fi

  if [[ -n "$(find "$datadir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    fail "$name data directory is not empty but does not look initialized: $datadir"
  fi

  log "Initializing $name data directory"
  "$MYSQLD" --defaults-file="$cnf" --initialize-insecure
}

start_instance() {
  local name="$1"
  local cnf="$2"
  local socket="$3"

  if mysql_ping "$socket"; then
    log "$name is already running"
    return 0
  fi

  log "Starting $name"
  "$MYSQLD" --defaults-file="$cnf" --daemonize
  wait_for_mysql "$name" "$socket"
}

run_sql_file() {
  local name="$1"
  local socket="$2"
  local sql_file="$3"

  log "Running $name: ${sql_file#$PROJECT_ROOT/}"
  "$MYSQL" --protocol=SOCKET --socket="$socket" -uroot < "$sql_file"
}

verify_replication() {
  log "Waiting for verification row to appear on replica"

  for _ in {1..30}; do
    local count
    count="$(
      "$MYSQL" --protocol=SOCKET --socket="$REPLICA_SOCKET" -uroot --batch --skip-column-names \
        -e "SELECT COUNT(*) FROM replication_lab.replication_check WHERE message = 'replication is working';" 2>/dev/null || true
    )"

    if [[ "${count:-0}" -gt 0 ]]; then
      log "Replication verified"
      return 0
    fi

    sleep 1
  done

  fail "Replication verification row did not appear on the replica"
}

main() {
  require_executable "$MYSQLD"
  require_executable "$MYSQL"
  require_executable "$MYSQLADMIN"
  require_file "$SOURCE_CNF"
  require_file "$REPLICA_CNF"
  require_file "$REPLICATION_DIR/01_source_replication_user.sql"
  require_file "$REPLICATION_DIR/02_replica_connect_to_source.sql"
  require_file "$REPLICATION_DIR/03_verify_replication.sql"

  mkdir -p "$SOURCE_DATA" "$REPLICA_DATA" "$REPLICATION_DIR/run" "$REPLICATION_DIR/logs"

  initialize_datadir "source" "$SOURCE_CNF" "$SOURCE_DATA"
  initialize_datadir "replica" "$REPLICA_CNF" "$REPLICA_DATA"

  start_instance "source" "$SOURCE_CNF" "$SOURCE_SOCKET"
  start_instance "replica" "$REPLICA_CNF" "$REPLICA_SOCKET"

  run_sql_file "source replication user setup" "$SOURCE_SOCKET" "$REPLICATION_DIR/01_source_replication_user.sql"
  run_sql_file "replica connection setup" "$REPLICA_SOCKET" "$REPLICATION_DIR/02_replica_connect_to_source.sql"
  run_sql_file "source verification data setup" "$SOURCE_SOCKET" "$REPLICATION_DIR/03_verify_replication.sql"

  verify_replication

  log "Done"
  log "Source socket:  $SOURCE_SOCKET"
  log "Replica socket: $REPLICA_SOCKET"
}

main "$@"
