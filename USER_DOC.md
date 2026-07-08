# User Documentation — Inception

This guide explains how to use and manage the Inception infrastructure as an end user or administrator.

---

## What Services Are Provided

The stack runs three services inside Docker containers, all communicating through a private Docker network:

| Service | Description | Port |
|---|---|---|
| **NGINX** | Web server and sole entry point. Handles HTTPS traffic and proxies requests to WordPress. | 443 (HTTPS) |
| **WordPress + php-fpm** | The WordPress application with PHP processing. Not directly accessible from outside. | Internal (9000) |
| **MariaDB** | The relational database storing all WordPress data. Not directly accessible from outside. | Internal (3306) |

The only way to access the infrastructure from a browser is through **port 443 (HTTPS)** via NGINX. All other ports are internal.

---

## Starting and Stopping the Project

### Start

From the root of the repository (on your VM):

```bash
make
```

This will build all Docker images and start the containers. On first run, it may take a few minutes to build.

To verify that the containers are running:

```bash
docker compose -f srcs/docker-compose.yml ps
```

You should see `nginx`, `wordpress`, and `mariadb` all with status `Up`.

### Stop (keep data)

```bash
make down
```

This stops and removes the containers, but your volumes (database and WordPress files) are preserved.

### Full cleanup (remove everything)

```bash
make fclean
```

This stops containers, removes images, and clears built artifacts. **Your volume data on the host is not deleted by this command** — it stays at `/home/homohame/data`.

---

## Accessing the Website and Administration Panel

### Website

Open your browser and navigate to:

```
https://homohame.42.fr
```

> Your browser will show a security warning because the TLS certificate is self-signed. This is expected — click "Advanced" and proceed.

You will land on the WordPress website.

### WordPress Administration Panel

```
https://homohame.42.fr/wp-admin
```

Log in with the administrator credentials stored in `.env`. The admin username does **not** contain "admin" or "administrator" (as required by the project).

---


## Locating and Managing Credentials

All configuration and sensitive credentials are stored in a single `.env` file located in the `srcs/` directory. This file is **gitignored** and must never be committed to the repository.

**`.env` Content Overview:**
*	**General:** Domain name (`homohame.42.fr`)
*	**MariaDB:** Database name, root password, standard user, and user password
*	**WordPress:** Admin username/password, and regular user credentials

To change a password or a configuration variable, update the `srcs/.env` file and restart the stack:

```bash
make down
make

---

## Checking That Services Are Running Correctly

### Quick status check

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three services (`nginx`, `wordpress`, `mariadb`) should show `Up`.

### View logs for a specific service

```bash
# NGINX logs
docker compose -f srcs/docker-compose.yml logs nginx

# WordPress logs
docker compose -f srcs/docker-compose.yml logs wordpress

# MariaDB logs
docker compose -f srcs/docker-compose.yml logs mariadb
```

### Test HTTPS access

```bash
curl -k https://homohame.42.fr
```

You should see HTML output from WordPress. The `-k` flag ignores the self-signed certificate warning.

### Check the database is responding

```bash
docker compose -f srcs/docker-compose.yml exec mariadb mysqladmin -u root -p status
```

Enter the root password from `secrets/db_root_password.txt` when prompted.

---

## Persistent Data

WordPress files and the database are stored on the host machine at:

```
inception/homohame/data/wordpress/    ← WordPress website files
inception/homohame/data/mariadb/      ← MariaDB database files
```

These directories are mapped into the containers via Docker named volumes. They persist even when containers are stopped or removed.
