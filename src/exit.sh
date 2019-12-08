#!/bin/sh

service mysql stop
service nginx stop
/etc/init.d/php7.3-fpm stop

exit
