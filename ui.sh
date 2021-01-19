#!/bin/bash

sudo apt update
sudo apt install git nodejs npm -y

# sudo apt install nginx -y
# sudo cp ./data/proxy /etc/nginx/sites-enabled/
# sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/backup 
# sudo mv /etc/nginx/sites-enabled/proxy /etc/nginx/sites-enabled/default
# sudo service nginx restart

git clone https://github.com/juan-ruiz/movie-analyst-ui.git
cd movie-analyst-ui/
npm install
node server.js &