#!/bin/bash
set -e

# Docker Engine and Compose from Docker's own apt repository
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir -p /srv/agent
cd /srv/agent
cat > compose.yaml <<'COMPOSE'
services:
  woodpecker-agent:
    image: woodpeckerci/woodpecker-agent:v3.19.0
    restart: unless-stopped
    environment:
      WOODPECKER_SERVER: ${server}
      WOODPECKER_AGENT_SECRET: ${agent_secret}
      WOODPECKER_MAX_WORKFLOWS: "2"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - agent-config:/etc/woodpecker

volumes:
  agent-config:
COMPOSE

# Pull the image, retrying if the registry is briefly unreachable
until docker compose pull; do sleep 10; done
docker compose up -d
