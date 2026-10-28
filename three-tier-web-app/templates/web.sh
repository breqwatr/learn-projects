#!/bin/bash
set -e
apt-get update
apt-get install -y nginx
cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    location /health {
        return 200 "ok\n";
    }
    location / {
        proxy_pass http://${app_address}:8080;
        add_header X-Served-By $hostname;
    }
}
NGINX
systemctl reload nginx
