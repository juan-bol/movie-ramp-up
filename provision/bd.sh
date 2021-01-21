#!/bin/bash

sudo apt update
sudo apt install mariadb-server expect -y

sudo su

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

sed -i 's/bind-address/#bind-address/' /etc/mysql/mariadb.conf.d/50-server.cnf

ROOT_PASSWORD=holi
mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$ROOT_PASSWORD') WHERE User='root';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$ROOT_PASSWORD' WITH GRANT OPTION;"
mysql -u root -e "CREATE DATABASE movie_db;"
mysql -u root -e "FLUSH PRIVILEGES;"

service mysql restart
