FROM debian:buster-slim

COPY src/install.sh ./
COPY src/run.sh ./
COPY src/exit.sh ./
COPY src/testdb.sh ./
COPY src/localhost.conf ./
COPY src/info.php ./
COPY src/todo_list.php ./
COPY src/test.html ./

RUN sh install.sh
