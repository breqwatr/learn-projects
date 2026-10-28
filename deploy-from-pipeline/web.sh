#!/bin/bash
set -e
apt-get update
apt-get install -y nginx
cat > /var/www/html/index.html <<'PAGE'
${page}
PAGE
