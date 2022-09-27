#!/bin/bash

sudo apt update && sudo apt upgrade

#Criar um usuario
sudo useradd -r gophish

#Criar as pastas
mkdir /var/log/gophish
mkdir /opt/gophish

#Dar permisão as pastas para o usuario gophish
sudo chown -R gophish:gophish /opt/gophish/ /var/log/gophish/

#Baixar o gophing e mandar arquivos para /opt/gophish
cd /opt/gophish/ && wget https://github.com/gophish/gophish/releases/download/v0.12.0/gophish-v0.12.0-linux-64bit.zip

sudo apt install zip

unzip gophish-v0.12.0-linux-64bit.zip

cp -rf gophish-v0.12.0-linux-64bit/* . && rm -rf gophish-v0.12.0-linux-64bit/

sed -i 's!127.0.0.1!0.0.0.0!g' /opt/gophish/config.json

# Criar arquivo  /etc/systemd/system/gophish.service
touch /lib/systemd/system/gophish.service

cat > /lib/systemd/system/gophish.service <<EOF
		[Unit]
		Description=Gophish service
		After=network-online.target

		[Service]
		WorkingDirectory=/opt/gophish
		Environment='STDOUT=/var/log/gophish/gophish.log'
		Environment='STDERR=/var/log/gophish/gophish.log'
		PIDFile=/var/run/gophish
		ExecStart=/bin/sh -c "/opt/gophish/gophish >>${STDOUT} 2>>${STDERR}"
		User=gophish
		Group=gophish
		AmbientCapabilities=CAP_NET_BIND_SERVICE

		[Install]
		WantedBy=multi-user.target
		Alias=gophish.service
EOF

# Set o capabilities para port 80
sudo setcap cap_net_bind_service=+ep /opt/gophish/gophish

# reload para o daemon
sudo systemctl daemon-reload

# habilita o gophish para inicar com a maquina
sudo systemctl enable gophish

# start o gophish
sudo systemctl start gophish

# Criar certificado SSL
#certbot  certonly  -d campanha.today --manual --preferred-challenges dns
#cp /etc/letsencrypt/live/campanha.today/privkey.pem /opt/gophish/campanha.today.key
#cp /etc/letsencrypt/live/campanha.today/fullchain.pem /opt/gophish/campanha.today.crt
