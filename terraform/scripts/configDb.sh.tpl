#!/bin/bash

sleep 100
set -e

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get install -y mysql-server

sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

if ! sudo grep -q '^bind-address' /etc/mysql/mysql.conf.d/mysqld.cnf; then
  echo 'bind-address = 0.0.0.0' | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf >/dev/null
fi

sudo sed -i 's/^mysqlx-bind-address\s*=.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

sudo sed -i 's/^skip-networking/# skip-networking/' /etc/mysql/mysql.conf.d/mysqld.cnf || true

sudo systemctl enable mysql
sudo systemctl restart mysql

until systemctl is-active --quiet mysql; do
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