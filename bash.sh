#!/bin/bash

sudo apt update -y
sudo apt install apache2 -y
sudo su
echo "<h2>Welcome to Apache2 server provisioned by Terraform</h2>" > /var/www/html/index.html
systemctl enable apache2
systemctl start apache2  