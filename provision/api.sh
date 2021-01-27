#!/bin/bash

sudo apt update
sudo apt install software-properties-common curl net-tools -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash
sudo apt install git nodejs -y
git clone https://github.com/juan-bol/movie-analyst-api
cd movie-analyst-api/
sudo npm install

sudo apt install mariadb-client -y
mysql -h 192.168.100.13 -P 3306 --user="root" --password="holi" movie_db < ./data_model/table_creation_and_inserts.sql

sudo bash -c 'echo "holi" >> .secrets'
sudo node server.js &
