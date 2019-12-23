FROM debian:buster-slim

RUN apt-get -y update && apt-get -y install mariadb-server \ 
			wget \
			php \
			php-cli \
	 		php-cgi \
			php-mbstring \
			php-fpm \
			php-mysql \
			nginx \
			libnss3-tools

COPY srcs ./root/

WORKDIR /root/

ENTRYPOINT ["bash", "container_entrypoint.sh"]
