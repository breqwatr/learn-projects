#!/bin/bash
set -e
apt-get update
apt-get install -y python3-psycopg2
cat > /opt/app.py <<'PY'
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer
import psycopg2

DSN = "host=${db_host} dbname=shop user=shop password=${db_password} connect_timeout=3"

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body = b"ok\n"
        else:
            with psycopg2.connect(DSN) as conn, conn.cursor() as cur:
                cur.execute("CREATE TABLE IF NOT EXISTS visits (id serial PRIMARY KEY, at timestamptz DEFAULT now())")
                cur.execute("INSERT INTO visits DEFAULT VALUES")
                cur.execute("SELECT count(*) FROM visits")
                count = cur.fetchone()[0]
            body = f"app: {socket.gethostname()}, visits: {count}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(body)

HTTPServer(("", 8080), Handler).serve_forever()
PY
cat > /etc/systemd/system/app.service <<'UNIT'
[Unit]
Description=Shop app tier
After=network-online.target

[Service]
ExecStart=/usr/bin/python3 /opt/app.py
Restart=always

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now app
