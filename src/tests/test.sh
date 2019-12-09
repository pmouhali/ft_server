#!/bin/sh

cp test.html /var/www/localhost/test.html
cp info.php /var/www/localhost/info.php
cp todo_list.php /var/www/localhost/todo_list.php

service mysql start

echo "CREATE DATABASE testdb;" | mysql -u root
echo "CREATE USER 'test'@'localhost';" | mysql -u root
echo "SET password FOR 'test'@'localhost' = password('password');" | mysql -u root
echo "GRANT ALL ON testdb.* TO 'test'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;" | mysql -u root
echo "FLUSH PRIVILEGES" | mysql -u root

echo "CREATE TABLE testdb.todo_list (item_id INT AUTO_INCREMENT, content VARCHAR(255), PRIMARY KEY(item_id));" | mysql -u root

echo "INSERT INTO testdb.todo_list (content) VALUES ('Get a pig.');" | mysql -u root
echo "INSERT INTO testdb.todo_list (content) VALUES ('Train it.');" | mysql -u root
echo "INSERT INTO testdb.todo_list (content) VALUES ('???');" | mysql -u root
echo "INSERT INTO testdb.todo_list (content) VALUES ('Make profit.');" | mysql -u root

echo "SELECT * FROM testdb.todo_list;" | mysql -u root

echo -e "Si tout s'est bien passé, la table todo_list est remplie de 4 items.\nOn peut voir à localhost/todo_list.php si la connection à la db est ok.\nOptionnel : delete la base de test et l'user après les vérifications :\n- ouvrir la console sql (mysql -u root) et envoyer les querys suivantes :\n'DROP DATABASE testdb;'\n'DROP USER test;'"
