#!/usr/bin/env bash

set -x

ADMIN_PW=$(cat /dev/urandom | LC_CTYPE=c tr -dc 'a-zA-Z0-9' | head -c16)
USER_PW=$(cat /dev/urandom | LC_CTYPE=c tr -dc 'a-zA-Z0-9' | head -c16)
HOST_PORT=$((32768 + RANDOM))

cat > postgressetup.sql <<EOF
create database instagram4k;
create user instagram4k_app with password '$USER_PW';
grant connect on database instagram4k to instagram4k_app;
EOF

docker build -t instagram4k_postgres .

docker run --name instagram4k_db -e POSTGRES_PASSWORD="$ADMIN_PW" -d -p "$HOST_PORT":5432 -it instagram4k_postgres

rm postgressetup.sql

cat > config.properties <<EOF
db.user=instagram4k_app
db.password=$USER_PW
db.url=jdbc:postgresql://localhost:$HOST_PORT/instagram4k
EOF

sleep 5s

./gradlew flywayMigrate

./gradlew generateInstagram4KJooqSchemaSource