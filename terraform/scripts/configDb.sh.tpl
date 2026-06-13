#!/bin/bash

sleep 100
set -e

sudo dnf update -y
sudo dnf install -y mariadb105-server

MYSQL_CNF="/etc/my.cnf.d/mariadb-server.cnf"

if [ ! -f "$MYSQL_CNF" ]; then
  MYSQL_CNF="/etc/my.cnf"
fi

sudo mkdir -p "$(dirname "$MYSQL_CNF")"

if ! sudo grep -q '^\[mysqld\]' "$MYSQL_CNF"; then
  echo '[mysqld]' | sudo tee -a "$MYSQL_CNF" >/dev/null
fi

if sudo grep -q '^bind-address' "$MYSQL_CNF"; then
  sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' "$MYSQL_CNF"
else
  echo 'bind-address = 0.0.0.0' | sudo tee -a "$MYSQL_CNF" >/dev/null
fi

if sudo grep -q '^mysqlx-bind-address' "$MYSQL_CNF"; then
  sudo sed -i 's/^mysqlx-bind-address\s*=.*/mysqlx-bind-address = 0.0.0.0/' "$MYSQL_CNF" || true
fi

sudo sed -i 's/^skip-networking/# skip-networking/' "$MYSQL_CNF" || true

sudo systemctl enable mariadb
sudo systemctl restart mariadb

until systemctl is-active --quiet mariadb; do
  sleep 2
done

sudo cat > /tmp/bootstrap.sql <<EOF
CREATE DATABASE IF NOT EXISTS \`${db_name}\`;
CREATE USER IF NOT EXISTS '${db_username}'@'%' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_username}'@'%';
FLUSH PRIVILEGES;
EOF

sudo cat > /tmp/schema.sql <<'EOF'
${initdb_sql}
EOF

sudo mysql < /tmp/bootstrap.sql
sudo mysql "${db_name}" < /tmp/schema.sql