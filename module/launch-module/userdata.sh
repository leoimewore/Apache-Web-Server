#!/bin/bash
mkdir -p /usr/bin/leofolder
aws s3 cp s3://buck-files-s3/index.html /usr/bin/leofolder
sudo su -
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html



