#!/bin/sh

apt-get update
apt-get -y upgrade
apt-get -y install nano
apt-get -y install mariadb-server
apt-get -y install wget
apt-get -y install php php-cli php-cgi php-mbstring
apt-get -y install php-fpm
apt-get -y install php-mysql
apt-get -y install nginx
apt-get -y install libnss3-tools

mkdir /var/www/localhost

cp localhost_index_on /etc/nginx/sites-available/localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

cp -r wordpress /var/www/localhost/wordpress
rm -r wordpress
cp -r phpMyAdmin /var/www/localhost/phpMyAdmin
rm -r phpMyAdmin
