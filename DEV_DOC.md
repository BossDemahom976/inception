# Developer Documentation — Inception

This guide explains how to set up, build, and manage the Inception infrastructure from a developer's perspective.

---

## Prerequisites

Before starting, make sure your Virtual Machine has the following installed:

```bash
# Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect

# Docker Compose plugin
sudo apt-get install docker-compose-plugin

# make
sudo apt-get install make

# Verify
docker --version
docker compose version
make --version
```

---

## Repository Structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                        ← gitignored, must be created manually
│   ├── credentials.txt             ← WordPress admin password
│   ├── db_password.txt             ← MariaDB user password
│   └── db_root_password.txt        ← MariaDB root password
└── srcs/
    ├── .env                        ← Non-sensitive config variables
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/               ← MariaDB config files
        │   └── tools/              ← Init scripts
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/               ← NGINX config + TLS cert
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/               ← php-fpm config
            └── tools/              ← WP-CLI setup scripts
```

---

## Environment Setup from Scratch

### 1. Clone the repository

```bash
git clone <repo_url> inception
cd inception
```

### 2. Create the secrets directory and files

These files are **gitignored** — you must create them manually. Never commit them.

```bash
mkdir -p secrets

echo "your_db_user_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/credentials.txt

# Restrict permissions
chmod 600 secrets/*.txt
```

### 3. Configure the `.env` file

Edit `srcs/.env` to match your environment:

```dotenv
DOMAIN_NAME=homohame.42.fr

# MySQL/MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# WordPress admin
WP_ADMIN_USER=homohame_admin
WP_ADMIN_EMAIL=homohame@student.42.fr
WP_USER=editor
WP_USER_EMAIL=editor@student.42.fr
```

> Passwords are NOT stored here — they are loaded from `secrets/` files at runtime.

### 4. Configure the domain name

Add the domain to `/etc/hosts` on your VM (and on your host if you want to access it from a browser outside the VM):

```bash
echo "127.0.0.1 homohame.42.fr" | sudo tee -a /etc/hosts
```

### 5. Create the data directories

The named volumes mount to these paths on the host. Create them beforehand to avoid permission issues:

```bash
mkdir -p /home/homohame/data/wordpress
mkdir -p /home/homohame/data/mariadb
```

---

## Building and Launching the Project

### Build and start

```bash
make
```

This runs:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Images are built from scratch using the local Dockerfiles. The `--build` flag ensures images are rebuilt even if they already exist.

### Rebuild a single service

```bash
docker compose -f srcs/docker-compose.yml up -d --build nginx
```

### Stop containers (preserve volumes)

```bash
make down
# equivalent to: docker compose -f srcs/docker-compose.yml down
```

### Full cleanup

```bash
make fclean
# equivalent to: docker compose -f srcs/docker-compose.yml down --rmi all
```

> This removes containers and images but does **not** delete volume data at `/home/homohame/data/`.

To also wipe volume data:

```bash
sudo rm -rf /home/homohame/data/wordpress /home/homohame/data/mariadb
```

---

## Managing Containers and Volumes

### Useful Docker Compose commands

```bash
# List running containers
docker compose -f srcs/docker-compose.yml ps

# View logs (follow mode)
docker compose -f srcs/docker-compose.yml logs -f

# Shell into a container
docker compose -f srcs/docker-compose.yml exec nginx sh
docker compose -f srcs/docker-compose.yml exec wordpress sh
docker compose -f srcs/docker-compose.yml exec mariadb sh

# Restart a single service
docker compose -f srcs/docker-compose.yml restart wordpress
```

### Inspect volumes

```bash
# List all Docker volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

### Check network

```bash
# List networks
docker network ls

# Inspect the project network
docker network inspect srcs_inception-network
```

---

## Where Data Is Stored and How It Persists

### Named volumes

The project uses two Docker named volumes defined in `docker-compose.yml`:

| Volume name | Mounted in container | Host path |
|---|---|---|
| `srcs_wordpress` | `/var/www/html` (wordpress container) | `/home/homohame/data/wordpress` |
| `srcs_mariadb` | `/var/lib/mysql` (mariadb container) | `/home/homohame/data/mariadb` |

The `driver_opts` in `docker-compose.yml` bind the named volumes to specific host paths:

```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/homohame/data/wordpress
  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/homohame/data/mariadb
```

### Persistence behavior

- Stopping containers (`make down`) does **not** affect volume data.
- Removing images (`make fclean`) does **not** affect volume data.
- Data only disappears if you manually delete the directories at `/home/homohame/data/`.

### Docker secrets

Secrets are mounted at runtime as read-only files inside each container at `/run/secrets/<secret_name>`. They are never stored in environment variables or image layers, making them invisible to `docker inspect`.

---

## TLS Certificate

The NGINX container uses a self-signed TLS certificate generated with OpenSSL during image build:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx.key \
  -out /etc/ssl/certs/nginx.crt \
  -subj "/C=FR/ST=Paris/O=42/CN=homohame.42.fr"
```

This certificate is baked into the NGINX image. It is self-signed, so browsers will show a warning — this is expected for a local dev environment.

---

## Common Issues

### Port 443 already in use

```bash
sudo lsof -i :443
# Kill the process using the port, then retry make
```

### Permission denied on /home/homohame/data

```bash
sudo chown -R $USER:$USER /home/homohame/data
```

### WordPress not connecting to the database

Check that MariaDB is fully initialized before WordPress starts. The WordPress entrypoint script should include a wait loop. Check logs:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
```

### Containers exit immediately

Make sure you are not using infinite loop hacks (`tail -f`, `sleep infinity`, `while true`) as entrypoints. Use proper daemon foreground commands instead (e.g., `php-fpm8 -F`, `nginx -g 'daemon off;'`, `mysqld_safe`).
