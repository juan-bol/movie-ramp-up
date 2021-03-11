#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install ansible2 -y
sudo yum install git python2-pip python3-pip -y
git clone https://github.com/juan-bol/movie-ramp-up
pip install boto --user
pip3 install boto3 --user
