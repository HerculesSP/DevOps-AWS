#!/bin/bash
set -e

sleep 100
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get install -y docker.io nginx

sudo systemctl enable docker
sudo systemctl restart docker

sudo systemctl enable nginx
sudo systemctl restart nginx

sudo mkdir -p /opt/stockflow

sudo tee /opt/stockflow/.env >/dev/null <<EOF
DB_HOST=${db_private_ip}
DB_NAME=${db_name}
DB_PASSWORD=${db_password}
DB_USERNAME=${db_username}
DB_PORT=${db_port}
EOF

sudo docker pull ${docker_image}

sudo docker rm -f ${container_name} || true

sudo docker run -d \
  --name ${container_name} \
  --restart always \
  --env-file /opt/stockflow/.env \
  --network host \
  ${docker_image}

sudo cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

nginx -t
systemctl restart nginx