FROM mysql:5.7

COPY initdb/rdm.sql /docker-entrypoint-initdb.d/