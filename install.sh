#!/bin/bash
# Script By Cyber Threat Hunting Team
# Direktorat Operasi Keamanan Siber
# Badan Siber dan Sandi Negara
# Tahun 2022
# Special Thanks to Team: maNDayUGIikHSanNaLonAldAvIDSUBkHAnREndRAalSItAdAFi

check_root() {
	echo "---Mengecek Sistem Root---"
	if [[ $EUID -ne 0 ]]; 
    then
	   echo "[Error Step 1] Jalankan Script dengan Root (sudo su)"
	   exit 1
	else
       echo "[Step 1] Checking Root Access Complete"
    fi
	echo ""
	echo ""
}

check_openport(){
    sudo apt install nmap
}

check_os(){
    echo "---Mengecek Operating System---"
    # Installing ELK Stack
    if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
        then
            echo " It's a Debian based system"
            echo "[Step 2] Checking OS Complete"
            echo ""
            echo ""
    else
        echo "This script doesn't support ELK installation on this OS."
        exit 1
    fi
}

check_update() {
    echo "---Mengecek Update dan Variabel---"
	sudo apt update
    mkdir assets
	export $(cat .env | xargs)
    echo "[Step 3] Checking Update and Variable Complete"
    echo ""
	echo ""
}

check_java() {
    echo "---Mengecek Versi Java---"
    java -version
    if [ $? -ne 0 ]
        then
            # Installing Java 8 if it's not installed
            sudo apt-get install openjdk-8-jre-headless -y
        # Checking if java installed is less than version 7. If yes, installing Java 7. As logstash & Elasticsearch require Java 7 or later.
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo apt-get install openjdk-8-jre-headless -y
    fi
    echo "[Step 4] Checking Java Version Complete"
    echo ""
	echo ""
}

install_fw_nginx() {
    echo "---install firewall and nginx---"
    sudo apt install ufw nginx -y
    sudo ufw allow 22/tcp
    yes | sudo ufw enable
    sudo systemctl enable nginx
    sudo systemctl start nginx
    sudo apt-get install php8.1-fpm -y
    sudo cp conf/default /etc/nginx/sites-available/default
    sudo systemctl restart nginx
    sudo ufw allow from any to any port 80
    sudo chmod -R 777 /var/www/html
    echo "[Step 5] Install firewall and nginx Complete"
    echo ""
	echo ""
}

install_elasticsearch(){
    echo "---install Elasticsearch---"
    wget -O assets/elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb
    yes | sudo dpkg -i assets/elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch.service
    sudo systemctl start elasticsearch.service
    sudo ufw allow from any to any port 9200
    yes | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic | tail -1 > password-elasticsearch.txt
    sudo chmod 777 password-elasticsearch.txt
    echo ""
    echo "[Step 6] Install Elasticsearch Complete"
    echo ""
	echo ""
}

install_kibana(){
    echo "---install Kibana---"
    wget -O assets/kibana-${ELASTICSEARCH_VERSION}-amd64.deb https://artifacts.elastic.co/downloads/kibana/kibana-${ELASTICSEARCH_VERSION}-amd64.deb
    yes | sudo dpkg -i assets/kibana-${ELASTICSEARCH_VERSION}-amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable kibana.service
    sudo systemctl start kibana.service
    sudo cp conf/kibana.yml /etc/kibana/kibana.yml
    sudo ufw allow from any to any port 5601
    #Fleet Port
    sudo ufw allow from any to any port 8220
    echo "[Step 7] Install Kibana Complete"
    echo ""
	echo ""
}

login_kibana(){
    echo "---Login Kibana---"
    read -p "Buka halaman http://$(hostname -I):5601 (Press Anything To Continued)"
    echo "Masukkan Token Registrasi Berikut Pada Enroll Token"
    sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
    read -p "Press Anything To Continued...."
    echo "Masukkan Kode Verifikasi Berikut"
    sudo /usr/share/kibana/bin/kibana-verification-code
    read -p "Press Anything To Continued...."
    #Add Encryption Key To Kibana
    echo "Restart Kibana (Please Wait)"
    sudo /usr/share/kibana/bin/kibana-encryption-keys generate | tail -4 >> /etc/kibana/kibana.yml
    echo "[Step 8] Konfigurasi Kibana and Elastic Agent Complete"
    echo ""
	echo ""
}

install_fleet(){
    echo "---Install Fleet Server---"
    yes | sudo apt-get install jq
    wget -O assets/elastic-agent-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz
    tar xzvf assets/elastic-agent-${ELASTICSEARCH_VERSION}-linux-x86_64.tar.gz -C assets
    yes | sudo ./assets/elastic-agent-${ELASTICSEARCH_VERSION}-linux-x86_64/elastic-agent install --fleet-server-es=https://localhost:9200 --fleet-server-service-token=$(curl -k -u "elastic:$(tail -1 password-elasticsearch.txt | cut -d " " -f 3)" -s -X POST http://localhost:5601/api/fleet/service-tokens --header 'kbn-xsrf: true' | jq -r .value) --fleet-server-policy=ca-security-endpoint --fleet-server-es-ca-trusted-fingerprint=$(sudo openssl x509 -fingerprint -sha256 -noout -in /etc/elasticsearch/certs/http_ca.crt | awk -F"=" {' print $2 '} | sed s/://g)
    sudo cat conf/xpack >> /etc/kibana/kibana.yml
    sudo systemctl restart kibana.service
    echo "[Step 9] Install Fleet Server Complete"
    echo ""
	echo ""
}

setting_download_page(){
    echo "---Setting Agent Endpoint Download Page---"
    read -p "Buka halaman http://$(hostname -I):5601 (Mohon tunggu hingga halaman terbuka)"
    echo "Login dengan menggunakan username elastic dan password elastic berikut:"
    tail -3 password-elasticsearch.txt
    read -p "Press Anything To Continued...."
    read -p "Masukkan Alamat IP (tanpa https:// dan tanpa port) : " IP_ADDRESS_ES
    read -p "Buka halaman http://$(hostname -I):5601/app/fleet/enrollment-tokens (Press Anything To Continued)"
    read -p "Copy Secret Enrollments Token dari Agent Policy CA Security Endpoint (Press Anything To Continued)"
    read -p "Masukkan Secret Enrollments Token : " ENROLLMENT_TOKEN
    sed -i "s/IP_ADDRESS/$IP_ADDRESS_ES/g" conf/download
    sed -i "s/TOKEN_INPUT/$ENROLLMENT_TOKEN/g" conf/download
    cp conf/download /var/www/html/download.php
    echo "Berhasil membuat download page agent endpoint kunjungi http://$IP_ADDRESS_ES/download"
    echo "[Step 10] Agent Endpoint Download Page Complete"
}

main(){
    check_root
    check_os
    check_update
    check_java
    install_fw_nginx
    install_elasticsearch
    install_kibana
    login_kibana
    install_fleet
    setting_download_page
    echo ""
	echo ""
    echo "[-] Selesai Menginstall Agent-Manager dan Endpoint Security"
}

main




