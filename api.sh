#!/bin/bash

sudo apt update
sudo apt install git nodejs npm -y
git clone https://github.com/juan-bol/movie-analyst-api
cd movie-analyst-api/
npm install
node server.js &