#!/bin/bash

sudo apt update
sudo apt install software-properties-common curl -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash
sudo apt install git nodejs -y
git clone https://github.com/juan-bol/movie-analyst-api
cd movie-analyst-api/
sudo npm install
sudo npm install mariadb
node server.js &