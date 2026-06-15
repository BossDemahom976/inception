FROM debian:bookworm

RUN apt update -y && apt upgrade -y
RUN apt-get install -y wget
RUN apt-get install -y php-fpm php-mysql mariadb-client
RUN wget https://fr.wordpress.org/wordpress-7.0-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-7.0-fr_FR.tar.gz && rm wordpress-7.0-fr_FR.tar.gz
RUN chown -R www-data:www-data /var/www/wordpress
COPY /conf/www.conf/ /etc/php/8.2/fpm/pool.d/www.conf
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp
