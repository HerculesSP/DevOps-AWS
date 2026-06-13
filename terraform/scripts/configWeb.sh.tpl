#!/bin/bash

sleep 100
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<'EOF'
${html_content}
EOF

chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html

systemctl enable nginx
systemctl restart nginx