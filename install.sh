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
    sudo apt install ufw nginx
    sudo ufw allow 22/tcp
    sudo ufw enable
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo "[Step 5] Install firewall and nginx Complete"
    echo ""
	echo ""
}

install_elasticsearch(){
    echo "---install Elasticsearch---"
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb
    sudo dpkg -i elasticsearch-${ELASTICSEARCH_VERSION}-amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch.service
    sudo systemctl start elasticsearch.service
    sudo ufw allow from any to any port 9200
    sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic > password-elasticsearch.txt
    sudo chmod 777 password-elasticsearch.txt
    echo "[Step 6] Install Elasticsearch Complete"
    echo ""
	echo ""
}

install_kibana(){
    echo "---install Kibana---"
    wget https://artifacts.elastic.co/downloads/kibana/kibana-${ELASTICSEARCH_VERSION}-amd64.deb
    sudo dpkg -i kibana-${ELASTICSEARCH_VERSION}-amd64.deb
    sudo systemctl daemon-reload
    sudo systemctl enable kibana.service
    sudo systemctl start kibana.service
    sudo cp conf/kibana.yml /etc/kibana/kibana.yml
    sudo ufw allow from any to any port 5601
    # sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana > password-kibana.txt
    # sudo chmod 777 password-kibana.txt
    echo "[Step 7] Install Kibana Complete"
    echo ""
	echo ""
}

login_kibana(){
    echo "---Login Kibana---"
    read -p "Buka halaman localhost:5601 (Press Anything To Continued)"
    echo "Masukkan Token Registrasi Berikut Pada Enroll Token"
    sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
    read -p "Press Anything To Continued...."
    echo "Masukkan Kode Verifikasi Berikut"
    sudo /usr/share/kibana/bin/kibana-verification-code
    read -p "Press Anything To Continued...."
    echo "Login dengan menggunakan username elastic dan password elastic berikut:"
    tail -3 password-elasticsearch.txt
    read -p "Press Anything To Continued...."
    echo "[Step 8] Konfigurasi Kibana Complete"
    echo ""
	echo ""
    echo "[-] Selesai Menginstall Agent-Manager"
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
}

main




