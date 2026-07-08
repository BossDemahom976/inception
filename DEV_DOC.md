# Developer Documentation — Inception

This guide explains how to set up, build, and manage the Inception infrastructure from a developer's perspective.

---

## Prerequisites

Before starting, make sure your Virtual Machine has the following installed:

```bash
# curl
sudo apt install curl
# Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect

# Docker Compose plugin
sudo apt-get install docker-compose-plugin

# make
sudo apt-get install build-essential

# Verify
docker --version
docker compose version
make --version
```

---

## Environment Setup from Scratch

### 1. Clone the repository

```bash
git clone <repo_url> inception
cd inception
```

### 2. Configure the `.env` file

Edit `srcs/.env` to match your environment:

```dotenv
DOMAIN_NAME=homohame.42.fr
# SQL SETUP
SQL_USER=homohame
SQL_PASSWORD=
SQL_DATABASE=database
SQL_ROOT_PASSWORD=
# WP SETUP
WP_TITLE=Inception
WP_ADMIN=houssen
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=homohame@student.42.fr
WP_USER=user1
WP_USER_MAIL=user1@user.fr
```

### 3. Configure the domain name

Add the domain to `/etc/hosts` on your VM (and on your host if you want to access it from a browser outside the VM):

```bash
echo "127.0.0.1 homohame.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and Launching the Project

### Build and launch

```bash
make
```

This runs:

```bash
mkdir -p homohame/data/wordpress
mkdir -p homohame/data/mariadb
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
```

This runs:

```bash
docker compose -f srcs/docker-compose.yml down
```

### Full cleanup

```bash
make fclean
```

This runs:

```bash
docker compose -f srcs/docker-compose.yml down
docker system prune -a
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
   type: 'none'
   o: 'bind'
   device: '/home/homohame/data/wordpress'
 mariadb:
  driver: local
  driver_opts:
   type: 'none'
   o: 'bind'
   device: '/home/homohame/data/mariadb'

```

### Persistence behavior

- Stopping containers (`make down`) does **not** affect volume data.
- Removing images (`make fclean`) does **not** affect volume data.
- Data only disappears if you manually delete the directories at `/home/homohame/data/`.

---

## TLS Certificate

The NGINX container uses a self-signed TLS certificate generated with OpenSSL during image build:

```bash
openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=homohame.42.fr/UID=homohame"

```

This certificate is baked into the NGINX image. It is self-signed, so browsers will show a warning — this is expected for a local dev environment.

---
