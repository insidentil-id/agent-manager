## Pre-install
sudo apt get update<br>
sudo apt install git

## Clone Repository
git clone https://github.com/insidentil-id/agent-manager<br>
sudo chmod 777 -R agent-manager<br>
cd agent-manager<br>
chmod u+x install.sh<br>

## Change env File
Ubah semua komponen pada env file, sesuaikan dengan aset yang dimiliki<br>
nano .env

## Running installer dan tunggu hingga selesai
sudo su<br>
./install.sh