#!/bin/bash
set -e

# The data volume: format it the first time only, and mount it on every boot
while [ ! -b /dev/vdb ]; do sleep 2; done
blkid /dev/vdb || mkfs.ext4 -L platform-data /dev/vdb
mkdir -p /srv/data
echo 'LABEL=platform-data /srv/data ext4 defaults,nofail 0 2' >> /etc/fstab
mount /srv/data
mkdir -p /srv/data/postgres /srv/data/gitea /srv/data/caddy

# Docker Engine and Compose from Docker's own apt repository
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir -p /srv/platform
cd /srv/platform

# A database each for Gitea, Woodpecker and the pipeline's OpenTofu state,
# created if missing on every boot
cat > databases.sql <<'SQL'
SELECT 'CREATE ROLE gitea LOGIN' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'gitea')\gexec
SELECT 'CREATE ROLE woodpecker LOGIN' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'woodpecker')\gexec
SELECT 'CREATE ROLE tfstate LOGIN' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'tfstate')\gexec
ALTER ROLE gitea PASSWORD '${pg_gitea}';
ALTER ROLE woodpecker PASSWORD '${pg_woodpecker}';
ALTER ROLE tfstate PASSWORD '${pg_tfstate}';
SELECT 'CREATE DATABASE gitea OWNER gitea' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitea')\gexec
SELECT 'CREATE DATABASE woodpecker OWNER woodpecker' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'woodpecker')\gexec
SELECT 'CREATE DATABASE tfstate OWNER tfstate' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'tfstate')\gexec
SQL

cat > Caddyfile <<'CADDY'
git.${domain} {
	reverse_proxy gitea:3000
}

ci.${domain} {
	reverse_proxy woodpecker-server:8000
}
CADDY

cat > compose.yaml <<'COMPOSE'
services:
  postgres:
    image: postgres:18.4
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: ${pg_admin}
    volumes:
      - /srv/data/postgres:/var/lib/postgresql
    ports:
      - "${private_ip}:5432:5432"

  gitea:
    image: gitea/gitea:28.1.0
    restart: unless-stopped
    environment:
      USER_UID: "1000"
      USER_GID: "1000"
      GITEA__database__DB_TYPE: postgres
      GITEA__database__HOST: postgres:5432
      GITEA__database__NAME: gitea
      GITEA__database__USER: gitea
      GITEA__database__PASSWD: ${pg_gitea}
      GITEA__server__DOMAIN: git.${domain}
      GITEA__server__ROOT_URL: https://git.${domain}/
      GITEA__server__DISABLE_SSH: "true"
      GITEA__service__DISABLE_REGISTRATION: "true"
      GITEA__security__INSTALL_LOCK: "true"
      GITEA__webhook__ALLOWED_HOST_LIST: private
    volumes:
      - /srv/data/gitea:/data
    depends_on:
      - postgres
%{ if woodpecker_client != "" ~}

  woodpecker-server:
    image: woodpeckerci/woodpecker-server:v3.19.0
    restart: unless-stopped
    environment:
      WOODPECKER_HOST: https://ci.${domain}
      WOODPECKER_EXPERT_WEBHOOK_HOST: http://woodpecker-server:8000
      WOODPECKER_GITEA: "true"
      WOODPECKER_GITEA_URL: https://git.${domain}
      WOODPECKER_GITEA_CLIENT: ${woodpecker_client}
      WOODPECKER_GITEA_SECRET: ${woodpecker_secret}
      WOODPECKER_AGENT_SECRET: ${agent_secret}
      WOODPECKER_ADMIN: ${admin_username}
      WOODPECKER_DATABASE_DRIVER: postgres
      WOODPECKER_DATABASE_DATASOURCE: postgres://woodpecker:${pg_woodpecker}@postgres:5432/woodpecker?sslmode=disable
    depends_on:
      - postgres
    ports:
      - "${private_ip}:9000:9000"
%{ endif ~}

  caddy:
    image: caddy:2.11.7
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - /srv/data/caddy:/data
    networks:
      default:
        # So Woodpecker reaches Gitea, and Gitea reaches Woodpecker, on this host
        aliases:
          - git.${domain}
          - ci.${domain}
COMPOSE

# Pull the images, retrying if a registry is briefly unreachable
until docker compose pull; do sleep 10; done

docker compose up -d postgres
until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do sleep 2; done
docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U postgres < databases.sql
docker compose up -d

# The Gitea administrator, the first time only
until docker compose exec -T -u git gitea gitea admin user list > /dev/null 2>&1; do sleep 5; done
docker compose exec -T -u git gitea gitea admin user list | grep -qw '${admin_username}' || \
  docker compose exec -T -u git gitea gitea admin user create --admin \
    --username '${admin_username}' --email '${admin_email}' --password '${admin_password}' --must-change-password=false
