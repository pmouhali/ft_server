#!/bin/sh

mkdir /var/www/localhost

cp localhost_index_on /etc/nginx/sites-available/localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

cp -r wordpress /var/www/localhost/wordpress
rm -r wordpress
cp -r phpMyAdmin /var/www/localhost/phpMyAdmin
rm -r phpMyAdmin

service mysql start
echo "CREATE DATABASE wordpress;" | mysql -u root                     
echo "CREATE USER 'wordpress'@'localhost';" | mysql -u root           
echo "SET password FOR 'wordpress'@'localhost' = password('password');    " | mysql -u root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'password';" | mysql -u root 
echo "FLUSH PRIVILEGES;" | mysql -u root 
mysql wordpress -u root < /root/wordpress.sql

cd ssl
chmod +x mkcert
./mkcert -install
./mkcert localhost
cd ..

service nginx reload
service nginx configtest
service nginx start
service nginx status

/etc/init.d/php7.3-fpm start
/etc/init.d/php7.3-fpm status

tail -f /var/log/nginx/access.log /var/log/nginx/error.log
