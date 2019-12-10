#!/bin/sh

service mysql start
echo "CREATE DATABASE wordpress;" | mysql -u root                     
echo "CREATE USER 'wordpress'@'localhost';" | mysql -u root           
echo "SET password FOR 'wordpress'@'localhost' = password('password');    " | mysql -u root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'password';" | mysql -u root 
echo "FLUSH PRIVILEGES;" | mysql -u root 
mysql wordpress -u root < wordpress.sql

cd ssl_certif
./mkcert -install
./mkcert localhost
cd ..

cp /var/www/html/index.nginx-debian.html /var/www/localhost/index.html

service nginx reload
service nginx configtest
service nginx start
service nginx status

/etc/init.d/php7.3-fpm start
/etc/init.d/php7.3-fpm status
