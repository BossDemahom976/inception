all:
	mkdir -p /Users/homohame/data/wordpress
	mkdir -p /Users/homohame/data/mariadb
	docker compose up -d --build

down:
	docker compose down

clean: down
	docker system prune -a
	rm -rf /Users/homohame/data

.PHONY: all down clean