all:
	mkdir -p homohame/data/wordpress
	mkdir -p homohame/data/mariadb
	docker compose up -d --build

down:
	docker compose down -v

clean: down
	docker system prune -a
	rm -rf homohame

.PHONY: all down clean