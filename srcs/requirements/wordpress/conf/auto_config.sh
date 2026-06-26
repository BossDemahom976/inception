#!/bin/bash

wp config create	--allow-root \
					--dbname=${SQL_DATABASE} \
					--dbuser=${SQL_USER} \
					--dbpass=${SQL_PASSWORD} \
					--dbhost=mariadb:3306 --path=/var/www/wordpress
wp core install		--allow-root \
					--url="https://${DOMAIN_NAME}" \
					--title=${WP_TITLE} \
					--admin_user=${WP_ADMIN} \
					--admin_password=${WP_ADMIN_PASSWORD} \
					--admin_email=${WP_ADMIN_EMAIL} \
					--path=/var/www/wordpress
wp user create		--allow-root \
					${WP_USER} ${WP_USER_MAIL} --role=author \
					--path=/var/www/wordpress

mkdir -p /run/php

exec php-fpm8.2 -F