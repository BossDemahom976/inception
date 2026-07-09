all:
	mkdir -p /home/homohame/data/wordpress
	mkdir -p /home/homohame/data/mariadb
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

fclean: down
	docker system prune -a

.PHONY: all down clean
