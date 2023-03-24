#!/usr/bin/bash
#coded by @inacioot | jose.inaciot@outlook.com
#gophishAutomation - version 1.0

### Colors
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 5`;
magenta=`tput setaf 4`;
cyan=`tput setaf 6`;
bold=`tput bold`;
clear=`tput sgr0`;

banner() {
cat <<EOF
${blue}${bold}
  __ _
 | | (_)  | |
__ _____ __  | |___  ___ | |__
  / _\` | / _ \ | '_ \ | '_ \ | |/ __|| '_ \
 | (_| || (_) || |_) || | | || |\__ \| | | |
  \__, | \___/ | .__/ |_| |_||_||___/|_| |_|
__/ | | |
  |___/  |_|

${clear}
EOF
}


PRINT_USAGE(){
echo -e ""
echo -e "Configurar gophish (@Inacioot)"
echo -e ""
echo -e "Exemplo de uso:"
echo -e "EasyGophish.sh [-d target.com.br -ip youIP]"
echo -e ""
exit 0
}


#Verificando opcoes
while [ -n "$1" ]; do
    case $1 in
        -d|--domain)
            DM=$2
            shift ;;
        -t|--target)
            IP=$2
            shift ;;
        -h|--help)
            PRINT_USAGE
            shift ;;
        *)
        PRINT_USAGE
    esac
    shift
done

#verificando opcoes fazias
if [ -z "$DM" ] && [ -z "$IP" ]; then
echo -e "\nERROR - INFORME O DOMINIO."
PRINT_USAGE
fi

#Verificando crtl-c
trap ctrl_c INT
ctrl_c(){
 echo -e ""
 echo -e "KEYBOARD INTERRUPTION, EXITING EasyGophish..."
 exit 127
}

#Setando hostname
MAKDR(){
#Mudando hostname
hostnamectl set-hostname campanha

# Mudando etc/hosts
echo -e "127.0.0.1 $DM ">> /etc/hosts

#Criando o usario pastas
sudo useradd -r gophish
sudo mkdir /var/log/gophish
sudo mkdir /var/www/$DM
sudo mkdir /etc/opendkim
sudo mkdir /etc/opendkim/keys


sudo chown -R gophish:gophish /opt/gophish/ /var/log/gophish/

}

echo $DM
echo $IP

#Instalando pacotes
dependencyCheck(){
unzip=$(which unzip)

if [[ $unzip ]];
  then
 echo "${green}${bold}[+] Unzip already installed${clear}"
 else
 echo "${blue}${bold}[*] Installing unzip...${clear}"
 apt-get install unzip -y
fi

echo
sleep 4

### Checking/Installing go
gocheck=$(which go)

if [[ $gocheck ]];
  then
 echo "${green}${bold}[+] Golang already installed${clear}"
else
 echo "${blue}${bold}[*] Installing Golang...${clear}"
 apt install golang-go -y
fi

echo
sleep 4

### Checking/Installing git
gitcheck=$(which git)

if [[ $gitcheck ]];
  then
 echo "${green}${bold}[+] Git already installed${clear}"
else
 echo "${blue}${bold}[*] Installing Git...${clear}"
 apt-get install git -y
fi

echo
sleep 4

### Checking/Installing Apache2
a2check=$(which apache2)

if [[ $a2check ]];
  then
 echo "${green}${bold}[+] Apache2 already installed${clear}"
else
 echo "${blue}${bold}[*] Installing Apache...${clear}"
 apt install apache2 -y
fi

echo
sleep 4

### Checking/Installing postfix
postcheck=$(which postfix)

if [[ $postcheck ]];
  then
 echo "${green}${bold}[+] postfix already installed${clear}"
else
 echo "${blue}${bold}[*] Installing postfix...${clear}"
 apt install postfix -y
fi

echo
sleep 4

### Checking/Installing all dependencias
sudo apt-get install -y opendkim opendkim-tools sasl2-bin libsasl2-modules postsrsd certbot dovecot-core dovecot-{core,common,imapd,pop3d}
echo
sleep 8

}


#scan de subdomínio ativo
installGophish(){
if [ -d /opt/gophish/ ]; then
    echo -e "${blue}${bold}[*] Gophish Instalado."
 else
    echo -e "${blue}${bold}[*] Downloading Gophish...${clear}"
    rm -rf /opt/gophish
    git clone https://github.com/gophish/gophish.git /opt/gophish
    sleep 4
    echo
fi


#RECOMPILAR
cd /opt/gophish
find . -type f -exec sed -i.bak 's/X-Contact/X-Contact/g' {} +
sleep 4
find . -type f -exec sed -i.bak 's/X-Signature/X-Signature/g' {} +
sleep 4
sed -i 's/const ServerName = "gophish"/const ServerName = "IGNORE"/' config/config.go
sleep 4
sed -i 's/const RecipientParameter = "rid"/const RecipientParameter = "search"/g' models/campaign.go
sleep 4
go build -v
sleep 4

echo "${blue}${bold}[*] Alterando config.json...${clear}"

#Alterando arquivo gophish
sed -i "s/127.0.0.1:3333/"$IP":3333/g" /opt/gophish/config.json
sleep 1
sed -i 's/0.0.0.0:80/0.0.0.0:443/g' /opt/gophish/config.json
sleep 1
sed -i 's/false/true/g' /opt/gophish/config.json
echo
sleep 2

#criando servico gophish
echo "${blue}${bold}[*] Criando servico gophish...${clear}"
wget https://raw.githubusercontent.com/InacioTi/EasyGophish/main/service/gophish.service -P /etc/systemd/system/ >/dev/null 2>&1 &&
wget https://raw.githubusercontent.com/InacioTi/EasyGophish/main/service/gophish.sh -P /root/ >/dev/null 2>&1 &&
setcap cap_net_bind_service=+ep /opt/gophish/gophish &&
systemctl daemon-reload
systemctl start gophish &&
systemctl enable gophish

sleep 3


}

#Checando subdomínio
confPostfix(){
cat > /etc/postfix/main.cf <<EOF
smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no

append_dot_mydomain = no

readme_directory = no

compatibility_level = 3.6


# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_tls_security_level=may

smtp_tls_CApath=/etc/ssl/certs
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname =
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination =
relayhost =
mynetworks =
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all

mime_header_checks = regexp:/etc/postfix/header_checks
header_checks = regexp:/etc/postfix/header_checks

#SSL Stuff Postfix  encrypt the email upon sending
smtpd_tls_security_level = may
smtp_tls_security_level = may
smtp_tls_loglevel = 1
smtpd_tls_loglevel = 1
smtpd_sasl_security_options = noanonymous
disable_vrfy_command = yes
smtpd_delay_reject = yes

#DMKI
milter_default_action = accept
milter_protocol = 2
smtpd_milters = unix:/spamass/spamass.sock, inet:localhost:8891
non_smtpd_milters = unix:/spamass/spamass.sock, inet:localhost:8891
EOF

sed -i "s/myhostname =/myhostname = "$DM"/g" /etc/postfix/main.cf
sed -i "s/mydestination =/mydestination = "$DM", mail."$DM", localhost, localhost.localdomain/g" /etc/postfix/main.cf
sed -i "s/mynetworks =/mynetworks = "$IP", "$DM", 127\.0\.0\.0\/8 [::ffff:127\.0\.0\.0]\/104 [::1]\/128/g" /etc/postfix/main.cf

service postfix stop &&
service postfix start &&

sleep 4
}


#Iniciado scan de subdomínio (passivo, ativo, secundario, check)
letsEncrypt(){

### Verificando e limpando a porta 80
lsof -t -i tcp:80 | xargs kill

### Stopping Gophish
systemctl stop gophish

### Instalando certificado com certbot-auto
certbot=$(which certbot)

 if [[ $certbot ]];
    then
        echo "${green}${bold}[+] Certbot already installed${clear}"
    else
        echo "${blue}${bold}[*] Installing Certbot...${clear}"
        apt-get install certbot -y >/dev/null 2>&1
 fi
sleep 2

### Installing SSL Cert
echo "${blue}${bold}[*] Instalando certificado para o $DM...${clear}"

certbot certonly --standalone -d $DM

sleep 4

cp /etc/letsencrypt/live/$DM/fullchain.pem /opt/gophish/$DM.cert &&
cp /etc/letsencrypt/live/$DM/privkey.pem /opt/gophish/$DM.key &&
cp /etc/letsencrypt/live/$DM/fullchain.pem /etc/ssl/certs/fullchain.pem &&
cp /etc/letsencrypt/live/$DM/privkey.pem /etc/ssl/private/privkey.pem &&
sed -i "s/example.crt/"$DM".cert/g" /opt/gophish/config.json &&
sed -i "s/example.key/"$DM".key/g" /opt/gophish/config.json &&
chown -R gophish:gophish /opt/gophish/$DM.key /opt/gophish/$DM.cert
echo
echo "${green}${bold}[+] Verifique o certificado em: https://$DM${clear}"
echo

}

installDKMI(){

opendkim-genkey -b 1024 -t -s mail $DM
sleep 4

sudo cp mail.private /etc/postfix/dkim.key

cat < /etc/opendkim/TrustedHosts <<EOF
127.0.0.1
localhost
192.168.0.1/24
191.8.179.163

*.campanha.today
EOF
sleep 2

cat > /etc/opendkim/KeyTable <<EOF
mail._domainkey.campanha.today campanha.today:mail:/etc/opendkim/keys/campanha.today/mail.private
EOF
sleep 2

cat > /etc/opendkim/SigningTable <<EOF
*@campanha.today mail._domainkey.campanha.today
EOF
sleep 2

sudo systemctl restart opendkim.service
sudo systemctl restart postfix

echo "${green}${bold}[+] Verifique o arquivo mail.txt contendo o DKMI ${clear}"
}

#instalando apache2
installApache(){
wget https://raw.githubusercontent.com/InacioTi/EasyGophish/main/apache2/000-default.conf -P /etc/apache2/sites-available/ >/dev/null 2>&1
sed -i "s/example.today/"$DM"/g" /etc/apache2/sites-available/000-default.conf
sudo a2ensite 000-default.conf
sudo a2dissite 000-default-le-ssl.conf
sudo a2dissite default-ssl.conf

wget https://raw.githubusercontent.com/InacioTi/EasyGophish/main/apache2/ports.conf -P /etc/apache2/ >/dev/null 2>&1
echo "ServerSignature Off" >> /etc/apache2/apache2.conf
echo "ServerTokens Prod" >> /etc/apache2/apache2.conf
sleep 1

cat > /var/www/$DM/index.html <<EOF
<!DOCTYPE html>
<html>
    <head>
        <title>Site is down for maintenance</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style type="text/css">
            body { text-align: center; padding: 10%; font: 20px Helvetica, sans-serif; color: #333; }
            h1 { font-size: 50px; margin: 0; }
            article { display: block; text-align: left; max-width: 650px; margin: 0 auto; }
            a { color: #dc8100; text-decoration: none; }
            a:hover { color: #333; text-decoration: none; }
            @media only screen and (max-width : 480px) {
                h1 { font-size: 40px; }
            }
        </style>
    </head>
    <body>
        <article>
            <h1>Site is temporarily unavailable.</h1>
            <p>Scheduled maintenance is currently in progress. Please check back soon.</p>
            <p>We apologize for any inconvenience.</p>
            <p id="signature">&mdash; <a href="mailto:[Email]">[Name]</a></p>
        </article>
    </body>
</html>
EOF

sudo a2enmod proxy_http
sleep 1

sudo systemctl reload apache2
sleep 1

systemctl restart apache2

}


VAULT(){
 dependencyCheck 2> /dev/null
 installGophish
 confPostfix 2> /dev/null
 letsEncrypt 2> /dev/null
 installDKMI 2> /dev/null
 installApache 2> /dev/null
}


while true
do
 MAKDR
 VAULT
 exit 0
done
