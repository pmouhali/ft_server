#!/bin/sh

cp todo_list.php /var/www/localhost/todo_list.php

service mysql start

echo "CREATE DATABASE testdb;" | mysql -u root
echo "GRANT ALL ON testdb.* TO 'root@localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;" | mysql -u root
echo "FLUSH PRIVILEGES" | mysql -u root

echo "CREATE TABLE testdb.todo_list (item_id INT AUTO_INCREMENT, content VARCHAR(255), PRIMARY KEY(item_id));" | mysql -u root

echo "INSERT INTO testdb.todo_list (content) VALUES ('Get a pig.');" | mysql -u root
echo "INSERT INTO testdb.todo_list (content) VALUES ('Train it.');" | mysql -u root
echo "INSERT INTO testdb.todo_list (content) VALUES ('???');" | mysql -u root
echo "INSERT INTO testdb.todo_list (content) VALUES ('Make profit.');" | mysql -u root

echo "SELECT * FROM testdb.todo_list;" | mysql -u root

echo "Si tout s'est bien passé, la table todo_list est remplie de 4 items, on peut voir à localhost/todo_list.php si la connection à la db est ok. Ne pas oublier de delete la base de test après les vérifications. Ouvrir la console sql (mysql -u root) et envoyer la query suivante : 'DROP DATABASE testdb;'"
