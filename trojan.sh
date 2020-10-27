#!/bin/bash
#@conectedmx_vip
#@conectedmx
#@creditos al creador
barra="\e[1;30m-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖-➖ \e[0m"
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

install_panel(){
if cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
	echo -e "$barra"
	red "Este script solo admite：Debian9+ / Ubuntu16.04+"
	echo -e "$barra"
	exit 1
else	
	apt-get update -y
    apt install -y curl
    echo -e "$barra"
	blue "Ingrese el nombre de dominio vinculado a este VPS "
	echo -e "$barra"
	echo -ne "\e[1;31mDOMINIO>:\e[1;33m "; read your_domain
	real_addr=`ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
	local_addr=`curl ipv4.icanhazip.com`
	green " "
	green " "
	echo -e "$barra"
	 blue "    La dirección de resolución de nombre de dominio detectada es $real_addr"
	 blue "             La IP de este VPS es $local_addr"
	echo -e "$barra"
	sleep 2s
if [ $real_addr == $local_addr ] ; then
	echo -e "$barra"
	blue "        Ahora comience a actualizar el sistema e instale los componentes necesarios"
	echo -e "$barra"
	sleep 2s
	apt update -y
		if cat /etc/issue | grep -Eqi "ubuntu"; then
			apt install -y software-properties-common
			yes | add-apt-repository ppa:ondrej/php
			apt update -y
			apt install -y expect nginx curl socat sudo git unzip wget  mariadb-server php7.2-fpm php7.2-mysql php7.2-cli php7.2-xml php7.2-json php7.2-mbstring php7.2-tokenizer php7.2-bcmath
		else
			apt -y install software-properties-common apt-transport-https lsb-release ca-certificates
			wget -O /etc/apt/trusted.gpg.d/php.gpg https://mirror.xtom.com.hk/sury/php/apt.gpg
			sh -c 'echo "deb https://mirror.xtom.com.hk/sury/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'   
			apt update -y
			apt install -y expect nginx curl socat sudo git unzip wget  mariadb-server php7.2-fpm php7.2-mysql php7.2-cli php7.2-xml php7.2-json php7.2-mbstring php7.2-tokenizer php7.2-bcmath
		fi
if test -s /etc/php/7.2/cli/php.ini; then
	echo -e "$barra"
	blue "           Comience a instalar el servicio troyano oficial"
	echo -e "$barra"
	sleep 2s
	yes | sudo bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
	trojan_passwd=$(cat /dev/urandom | head -1 | md5sum | head -c 8)
cat > /usr/local/etc/trojan/config.json <<-EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$trojan_passwd"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "/usr/local/etc/trojan/cert.crt",
        "key": "/usr/local/etc/trojan/private.key",
        "key_password": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 81
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": false,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": false,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": true,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "$trojan_passwd",
        "cafile": ""
    }
}
EOF
	systemctl enable nginx
	systemctl enable trojan
	echo -e "$barra"
	blue "     Comenzará la solicitud de los certificados"
	echo -e "$barra"
	sleep 2s
cat > /etc/nginx/nginx.conf <<-EOF
user  root;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    keepalive_timeout  120;
    client_max_body_size 20m;
    #gzip  on;
    server {
        listen       81;
        server_name  $your_domain;
        root /usr/share/nginx/html;
        index index.php index.html index.htm;
    }
}
EOF
	systemctl restart nginx
	curl https://get.acme.sh | sh
	~/.acme.sh/acme.sh --issue -d $your_domain --nginx
	~/.acme.sh/acme.sh --installcert -d $your_domain --key-file /usr/local/etc/trojan/private.key --fullchain-file /usr/local/etc/trojan/cert.crt
	~/.acme.sh/acme.sh --upgrade --auto-upgrade
	chmod -R 755 /usr/local/etc/trojan
	if test -s /usr/local/etc/trojan/cert.crt; then
		green " "
		green " "
		echo -e "$barra"
		 blue "      Solicitud de certificado exitosa"
		echo -e "$barra"
		sleep 2s
	else
		green " "
		green " "
		echo -e "$barra"
		  red "     Solicitud de certificado fallida "
		echo -e "$barra"
		exit 1
	fi
	green " "
	green " "
	echo -e "$barra"
	blue "     Comience a configurar la base de datos "
	echo -e "$barra"
	sleep 2s

/usr/bin/expect << EOF
spawn mysql_secure_installation
expect "contraseña para root" {send "$trojan_passwd\r"}
expect "contraseña root" {send "n\r"}
expect "Eliminar usuarios anónimos" {send "y\r"}
expect "No permitir el inicio de sesión root de forma remota" {send "y\r"}
expect "Eliminar la base de datos de prueba y acceder a ella" {send "y\r"}
expect "Recargar tablas de privilegios ahora" {send "y\r"}
spawn mysql -u root -p
expect "Introducir la contraseña" {send "$trojan_passwd\r"}
expect "none" {send "CREATE DATABASE trojan;\r"}
expect "none" {send "GRANT ALL PRIVILEGES ON trojan.* to trojan@'%' IDENTIFIED BY '$trojan_passwd';\r"}
expect "none" {send "quit\r"}
EOF

	green " "
	green " "
	echo -e "$barra"
	blue "   Comience a implementar servicios relacionados con el Panel, ¡espere pacientemente este proceso!"
	echo -e "$barra"
	sleep 2s
	cd /var/www
	curl -sS https://getcomposer.org/installer -o composer-setup.php
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer
	curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
	apt install -y nodejs
	git clone https://github.com/scriptsmx/trojan-panel.git
	cd trojan-panel
	composer install
	npm install
	rm -rf /var/www/trojan-panel/.env
	wget https://raw.githubusercontent.com/V2RaySSR/Trojan_Panel/master/.env
	php artisan key:generate
	sed -i "s/your_domain/$your_domain/;" /var/www/trojan-panel/.env
	sed -i "s/your_password/$trojan_passwd/;" /var/www/trojan-panel/.env
	green " "
	green " "
	echo -e "$barra"
	  red "  A continuación, se le pedirá que ingrese YES / NO, ingrese (y) o (yes) y presione Enter"
	echo -e "$barra"
    read -s -n1 -p "Lea el mensaje claramente y esté preparado para ingresar. Si está listo, presione cualquier tecla para continuar ... "
	php artisan migrate
	chown -R www-data:www-data /var/www/trojan-panel
	echo -e "$barra"
	blue "       Comience a configurar los parámetros de Nginx y Panel "
	echo -e "$barra"
	sleep 2s
	cd /etc/nginx/sites-available
	rm -rf /etc/nginx/sites-available/default
	wget -P /etc/nginx/sites-available https://raw.githubusercontent.com/V2RaySSR/Trojan_Panel/master/default
	sed -i "s/your_domain/$your_domain/;" /etc/nginx/sites-available/default
	sed -i "s/vps_ip/$local_addr/;" /etc/nginx/sites-available/default
	systemctl restart nginx
	cd /root
	rm -rf /etc/nginx/nginx.conf
	wget -P /etc/nginx https://raw.githubusercontent.com/V2RaySSR/Trojan_Panel/master/nginx.conf
	systemctl restart trojan nginx
cat > /usr/local/etc/trojan/Trojan.txt <<-EOF
==================================================
            Completado (lea atentamente los siguientes consejos)
==================================================

La contraseña de tu base de datos es：$trojan_passwd
La dirección de acceso del panel troyan es: https://$your_domain/config
El primer usuario registrado en acceder a este panel es el administrador del sistema.
Esta compilación del panel incluye la compilación del servidor troyan

==================================================
            La siguiente es la información de conexión del troyan.
==================================================

            Nombre de dominio: $your_domain
            Puerto: 443
            Contraseña: Nombre de usuario: Contraseña
            entonces seria: password

 La contraseña mencionada anteriormente es el nombre de usuario y la contraseña registrados por Trojan-Panel
        Tenga en cuenta que (nombre de usuario: contraseña) está en puntuación en inglés
		  
==================================================

EOF
	echo -e "$barra"
   yellow "            Completado (lea atentamente los siguientes consejos) "
	echo -e "$barra"
	 blue "la contraseña de tu base de datos es：$trojan_passwd"
	 blue "La dirección de acceso del panel troyano es: https://$your_domain/config"
	 blue "El primer usuario registrado en acceder a este panel es un administrador del sistema "
	 blue "Esta compilación del panel incluye la configuración del servidor troyano "
	echo -e "$barra"
   yellow "            La siguiente es la información de conexión del troyano "
	echo -e "$barra"
	 blue "             nombre de dominio：$your_domain"
	 blue "             puerto：443"
	 blue "             Contraseña: Nombre de usuario: Contraseña "
	 blue "			  seria : password "
   yellow "La contraseña mencionada anteriormente es el nombre de usuario y la contraseña registrados por Trojan-Panel "
	  red "             Tenga en cuenta (:) para la puntuación en inglés "
	echo -e "$barra"
   yellow "      La información anterior BAK en /usr/local/etc/trojan/ "
   yellow "Tutorial: https://v2rayssr.com/trojan-panel-aoto.html"
    echo -e "$barra"
	exit 0
	
else
	echo -e "$barra"
	red "  PHP7.2 y otras dependencias básicas no se instalan correctamente "
	echo -e "$barra"
	exit 1
fi
else
	echo -e "$barra"
	red "La dirección de resolución de nombre de dominio es inconsistente con esta dirección IP de VPS "
	red "Esta instalación falló, asegúrese de que la resolución del nombre de dominio sea normal "
	echo -e "$barra"
	exit 1
fi
fi
}

bbr_boost_sh(){
    apt install -y wget
    wget -N --no-check-certificate -q -O tcp.sh "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && bash tcp.sh
}
infor(){
	echo -e "$barra"
   yellow "Este script solo admite：Debian9+ / Ubuntu16.04+"
	 blue "Sitio web: www.v2rayssr.com (prohibido visitar en el país)"
	 blue "Canal de YouTube: Bozai Share "
	 blue "Esta secuencia de comandos tiene prohibido volver a imprimir en cualquier sitio web en China "
	echo -e "$barra"
   yellow "Introducción: instalación con un clic del panel de administración de troyanos multiusuario 2020-03-23 ​​"
   yellow "Tutorial: https://v2rayssr.com/trojan-panel-aoto.html"
	echo -e "$barra"
      red "Este script cubrirá Nginx y ocupará 81/443, ¡no lo use en un entorno de producción! ¡Recuerda! "
	echo -e "$barra"
	  red "      Para garantizar una instalación única exitosa, utilice la nueva instalación del sistema "
	  red "  Para múltiples instalaciones de Composer con la misma IP, se le pedirá que ingrese TOKEN. Mecanismo de protección de GitHub "
	echo -e "$barra"
   yellow "Si hay varios intentos de instalar este script, debe ingresar al Compositor de búsqueda de blogs TOKEN "
   echo -e "$barra"
   return
   }
start_menu(){
    clear
   yellow "            MENÚ INSTALACION"
   red "            TROJAN "
	echo -e "$barra"
     blue "(1) > INICIAR INSTALACION TROJAN "
     blue "(2) > INSTALAR BBRPlus4 ACELERACION"
	 red "(4) > INFORMACION DEL SCRIPT"
   yellow "(0) > SALIR DEL SCRIPT "
   echo -e "$barra"
    echo
    read -p "Por favor ingrese un número: " num
    case "$num" in
    	1)
		install_panel
		;;
		2)
		bbr_boost_sh
		;;
		3)
		infor
		;;
		0)
		exit
		;;
		*)
	clear
	echo "Por favor ingrese el número correcto "
	sleep 2s
	start_menu
	;;
    esac
}

start_menu
rm -rf trojan.sh >/dev/null 2>&1