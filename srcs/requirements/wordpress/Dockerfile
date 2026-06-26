FROM debian:bookworm

RUN apt update -y && apt upgrade -y && \
	apt-get install -y wget php-fpm php-mysql mariadb-client && \
	rm -rf /var/lib/apt/lists/*

RUN wget https://fr.wordpress.org/wordpress-7.0-fr_FR.tar.gz -P /var/www && \
	cd /var/www && tar -xzf wordpress-7.0-fr_FR.tar.gz && rm wordpress-7.0-fr_FR.tar.gz && \
	chown -R www-data:www-data /var/www/wordpress

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

COPY conf/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

ENTRYPOINT [ "/usr/local/bin/auto_config.sh"]