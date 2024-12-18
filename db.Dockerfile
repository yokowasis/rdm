FROM mysql:5.7

COPY src/initdb/rdm.sql /docker-entrypoint-initdb.d/