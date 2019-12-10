FROM debian:buster-slim

COPY src/install.sh ./
COPY src/run.sh ./
COPY src/exit.sh ./

COPY src/tests ./tests
COPY src/localhost.conf ./

COPY src/wordpress ./wordpress
COPY src/phpMyAdmin ./phpMyAdmin

COPY src/wordpress.sql ./

COPY src/ssl_certif ./ssl_certif

RUN sh install.sh
