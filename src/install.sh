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

# NGINX x PHP

chown -R root:root /var/www/*
chmod -R 755 /var/www/*
mkdir /var/www/localhost

cp localhost.conf /etc/nginx/sites-available/localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

cp test.html /var/www/localhost/test.html
cp info.php /var/www/localhost/info.php
