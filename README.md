*This project has been created as part of the 42 curriculum by homohame.*

# Inception — Docker Infrastructure

## Description

**Inception** is a system administration project that involves setting up a small but complete web infrastructure using Docker and Docker Compose, all running inside a Virtual Machine.

The goal is to build, from scratch, a multi-container architecture consisting of:

- **NGINX** — the sole entry point to the infrastructure, handling HTTPS traffic via TLSv1.2/TLSv1.3 on port 443
- **WordPress + php-fpm** — the web application, running without NGINX
- **MariaDB** — the relational database for WordPress

All Docker images are built using Dockerfiles based on a stable version of Debian. No pre-built images are pulled from DockerHub (except the base OS). Sensitive credentials are managed through Docker secrets and a `.env` file, never hardcoded.

### Design Choices

#### Virtual Machines vs Docker

| Virtual Machines | Docker |
|---|---|
| Full OS per instance, heavy resource usage | Shared kernel, lightweight containers |
| Slower to start (minutes) | Near-instant startup (seconds) |
| Strong isolation via hypervisor | Process-level isolation via namespaces |
| Better for running different OS families | Best for packaging and deploying applications |

We chose Docker because it gives us reproducible, lightweight environments that are easy to configure and orchestrate with Docker Compose.

#### Secrets vs Environment Variables

| Docker Secrets | Environment Variables (.env) |
|---|---|
| Stored as files in `/run/secrets/`, not visible in `docker inspect` | Visible in `docker inspect` output |
| Suitable for passwords, API keys, sensitive credentials | Suitable for non-sensitive config (domain name, usernames) |
| Mounted at runtime by Docker Swarm or Compose | Injected directly into container environment |

We use Docker secrets for passwords and credentials, and `.env` for configuration variables like domain names and usernames.

#### Docker Network vs Host Network

| Docker Network (bridge) | Host Network |
|---|---|
| Containers communicate through an isolated virtual network | Containers share the host's network stack directly |
| Port exposure is explicit and controlled | No network isolation |
| Required by the subject | Forbidden by the subject |

We use a custom Docker bridge network so containers can communicate with each other by service name, while remaining isolated from the host.

#### Docker Volumes vs Bind Mounts

| Docker Named Volumes | Bind Mounts |
|---|---|
| Managed by Docker, stored under `/var/lib/docker/volumes/` | Directly map a host path into the container |
| Portable, managed lifecycle | Tied to a specific host path |
| Required by the subject for persistent data | Forbidden for the two main volumes |

We use named volumes for the WordPress files and database, stored at `/home/homohame/data` on the host machine.

## Instructions

### Prerequisites

- A Virtual Machine running Linux (Debian/Alpine recommended)
- Docker and Docker Compose installed
- `make` available

### Setup

1. Clone the repository into your VM:

```bash
git clone <repo_url> inception
cd inception
```

2. Edit `srcs/.env` to set your domain and credentials:

```bash
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

3. Add your domain to `/etc/hosts` on the host machine:

```bash
echo "127.0.0.1 homohame.42.fr" | sudo tee -a /etc/hosts
```

4. Build and start everything:

```bash
make
```

### Stopping the project

```bash
make down
```

### Cleaning up

```bash
make fclean   # stops containers and removes images
```

## Resources

### Official Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL for TLS certificates](https://www.openssl.org/docs/)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [PID 1 and init processes in containers](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)

### AI Usage

AI tools (primarily Claude) were used during this project for the following tasks:

- **Documentation**: Drafting and structuring this README, USER_DOC.md, and DEV_DOC.md.
- **Understanding concepts**: Getting explanations on TLS configuration, php-fpm socket setup, and WordPress CLI automation.
- **Configuration templates**: Generating initial NGINX and MariaDB config drafts, which were reviewed and adapted by the team.
- **Debugging guidance**: Describing container startup issues and getting suggestions on daemon best practices (PID 1, signal handling).

All AI-generated content was reviewed and validated by the team before use. Nothing was blindly copy-pasted without understanding.
