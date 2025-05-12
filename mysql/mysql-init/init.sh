#!/bin/bash
set -e
set -x

: "${GUACADMIN_USER:?Missing GUACADMIN_USER}"
: "${GUACADMIN_PASS:?Missing GUACADMIN_PASS}"
: "${GUAC_USER:?Missing GUAC_USER}"
: "${GUAC_PASS:?Missing GUAC_PASS}"
: "${CONNECTION_NAME:?Missing CONNECTION_NAME}"
: "${APP_HOSTNAME:?Missing APP_HOSTNAME}"
: "${APP_HOSTPORT:?Missing APP_HOSTPORT}"

INIT_DIR="/docker-entrypoint-initdb.d"
mkdir -p "$INIT_DIR"

envsubst < /mysql-init/03_create-users.template.txt > "/mysql-init/03_create-users.sql"
envsubst < /mysql-init/02_create-connection.template.txt > "/mysql-init/02_create-connection.sql"
cat \
  /mysql-init/01_create-schema.sql \
  /mysql-init/02_create-connection.sql \
  /mysql-init/03_create-users.sql > "$INIT_DIR/init.sql"

echo "Generated init.sql — ready for MySQL init"
exec docker-entrypoint.sh "$@"