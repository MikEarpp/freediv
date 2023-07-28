#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 <DB_USER> <DB_PASSWORD> <DB_NAME>"
  exit 1
fi

DB_USER="$1"
DB_PASSWORD="$2"
DB_NAME="$3"

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "Tous les arguments doivent être fournis : <DB_USER> <DB_PASSWORD> <DB_NAME>"
  exit 1
fi

psql -U postgres << EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
CREATE DATABASE $DB_NAME;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
\q
EOF
