FROM debian:bookworm

RUN apt update -y && apt upgrade -y
RUN apt install nginx vim curl openssl -y

RUN mkdir -p /etc/nginx/ssl /var/run/nginx
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=homohame.42.fr/UID=homohame"

RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]