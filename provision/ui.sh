#!/bin/bash

sudo apt update
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash
sudo apt install git nodejs -y

# sudo apt install nginx -y
# sudo cp ./data/proxy /etc/nginx/sites-enabled/
# sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/backup 
# sudo mv /etc/nginx/sites-enabled/proxy /etc/nginx/sites-enabled/default
# sudo service nginx restart

git clone https://github.com/juan-bol/movie-analyst-ui.git
cd movie-analyst-ui/
npm install
node server.js &