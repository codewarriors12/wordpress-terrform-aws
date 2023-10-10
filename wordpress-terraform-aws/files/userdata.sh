#!/bin/bash
sudo echo "127.0.0.1 `hostname`" >> /etc/hosts
sudo yum update -y
sudo yum install httpd php php-mysql -y
sudo wget -c http://wordpress.org/wordpress-5.1.1.tar.gz
sudo tar -xzvf wordpress-5.1.1.tar.gz
sleep 30
sudo mkdir -p /var/www/html/
sudo cp -R wordpress/* /var/www/html/
sudo chmod -R 777 /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo service httpd reload
sudo service httpd restart
sleep 30
sudo systemctl enable --now httpd
sudo systemctl status httpd
sudo chown -R apache:apache /var/www/html/
