import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import psycopg2

DSN = f"host={os.environ['DB_HOST']} dbname=shop user=shop password={os.environ['DB_PASSWORD']} connect_timeout=3"


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


ThreadingHTTPServer(("", 8080), Handler).serve_forever()
