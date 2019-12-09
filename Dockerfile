FROM debian:buster-slim

COPY src/install.sh ./
COPY src/run.sh ./
COPY src/exit.sh ./

COPY src/tests ./tests
COPY src/localhost.conf ./

COPY src/wordpress ./wordpress
COPY src/phpMyAdmin ./phpMyAdmin

COPY src/wordpress.sql ./

RUN sh install.sh
