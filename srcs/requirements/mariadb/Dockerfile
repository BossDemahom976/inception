FROM debian:bookworm

RUN apt update -y && apt upgrade -y
RUN apt-get install mariadb-server -y

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY /conf/mariadb_script.sh /usr/local/bin/mariadb_script.sh
RUN chmod +x /usr/local/bin/mariadb_script.sh

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/mariadb_script.sh" ]