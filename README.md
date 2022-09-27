# Gophish
Gophish Install

############# Passos para instalar o gophing: #############

# Criar um usuario
sudo useradd -r gophish

# Criar as pastas
mkdir /var/log/gophish
mkdir /opt/gophish

# Dar permisão as pastas para o usuario gophish
sudo chown -R gophish:gophish /opt/gophish/ /var/log/gophish/

# Baixar o gophing e mandar arquivos para /opt/gophish
wget [https://github.com/gophish/gophish/releases/download/v0.12.0/gophish-v0.12.0-linux-64bit.zip](https://github.com/gophish/gophish/releases/download/v0.12.0/gophish-v0.12.0-linux-64bit.zip) -o /opt/gophish

# Criar arquivo /etc/systemd/system/gophish.service

```
nano /lib/systemd/system/gophish.service

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

```

# Criar arquivo /etc/gophish/gophish.sh

```
nano /etc/gophish/gophish.sh

	#!/bin/bash

	GOPHISH_LOG_FILE=gophish.log
	GOPHISH_ERR_FILE=gophish.err

	check_bin_path() {
	    if [[ -z "$GOPHISH_BIN_PATH" ]]; then
	        exit 1
	    fi
	}

	check_log_path() {
	    if [[ -z "$GOPHISH_LOG_PATH" ]]; then
	        exit 2
	    fi
	}

	create_new_log_err() {
	    GOPHISH_STAMP=`date +%Y%m%d%H%M%S-%N`
	    if [[ -e $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE ]]; then
	        mv $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE-$GOPHISH_STAMP
	    fi

	    if [[ -e $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE ]]; then
	        mv $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE-$GOPHISH_STAMP
	    fi

	    touch $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE
	    touch $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE
	}

	launch_gophish() {
	    cd $GOPHISH_BIN_PATH
	    ./gophish >> $GOPHISH_LOG_PATH$GOPHISH_LOG_FILE 2>> $GOPHISH_LOG_PATH$GOPHISH_ERR_FILE
	}

	check_bin_path
	check_log_path
	create_new_log_err
	launch_gophish

```

# Set o capabilities para port 80

```
sudo setcap cap_net_bind_service=+ep /opt/gophish/gophish

```

# Se necessario edita o arquivo config.json em listen_url para adcionar o ip

# reload para o daemon

```
sudo systemctl daemon-reload

```

# habilita o gophish para inicar com a maquina

```
sudo systemctl enable gophish

```

# start o gophish

```
sudo systemctl start gophish

```

DKMI
mail._domainkey IN      TXT     ( "v=DKIM1; h=sha256; k=rsa; "
"p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1hz/Nid1fsXQVK72K97WqeXLZ
jAby0VbWGqPRpicVn2+jOxnK4Xv/1DxsgWYXLacSIsu6a7C0fP+T99pzuC3eU/JpOAbx/USFSK03yGoNkG
4pEGTSJ+NsZhx5oXvV/Entxr9bvghqUhDAYe9k5Af31sMev+ymHG04hYWplXA7SpyKsFGNa6RL2pUKJnrv
GzVCE0rwf+Uj8W5ks"
"fBt/395zjM/XQuKoK2mxMcj9V+W3Qad6TdJMTD2FL85oV0c4GrPyP8aTRgb+QNflCILIpXa
9uBe9YcVfMn8Gffj38ZlnT8vk09HffjJYaK+0Z2ixxCNPemmJI+iwASbhj0U1bEFwIDAQAB" )  ; ----

- DKIM key mail for campanha.today

# Criar certificado SSL

```
certbot  certonly  -d campanha.today --manual --preferred-challenges dns
	cp /etc/letsencrypt/live/campanha.today/privkey.pem /opt/gophish/campanha.today.key
	cp /etc/letsencrypt/live/campanha.today/fullchain.pem /opt/gophish/campanha.today.crt

```

Instal postifix
[https://0xsp.com/offensive/gophish-on-digital-ocean-with-blacklist-range/](https://0xsp.com/offensive/gophish-on-digital-ocean-with-blacklist-range/)[https://h4cklife.org/posts/how-to-phish-using-a-jump-box-part-1/](https://h4cklife.org/posts/how-to-phish-using-a-jump-box-part-1/)[https://www.n00py.io/2017/09/phishing-with-gophish-and-letsencrypt/](https://www.n00py.io/2017/09/phishing-with-gophish-and-letsencrypt/)[https://github.com/bigb0sss/gogophish](https://github.com/bigb0sss/gogophish)[https://blog.agood.cloud/posts/2019/10/17/lets-go-phishing/](https://blog.agood.cloud/posts/2019/10/17/lets-go-phishing/)
