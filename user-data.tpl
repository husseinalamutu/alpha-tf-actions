#!/bin/bash
# sudo apt-get update
# sudo apt-get install nginx -y
# sudo systemctl start nginx
# sudo systemctl enable nginxg




#!/bin/bash
# yum update -y
# yum install -y httpd php php-mysqlnd mysql git
# systemctl start httpd
# systemctl enable httpd
# cd /var/www/html/
# git clone https://github.com/WordPress/WordPress.git
# mv WordPress/* .
# rm -rf WordPress
# chown apache:apache /var/www/html/ -R




#!bin/bash

#Install WordPress dependencies and start necessary service
echo "Installing the following php dependencies"
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo apt-get install mysql-server php libapache2-mod-php php-mysql -y

sudo systemctl start apache2
sudo systemctl enable apache2

sudo systemctl start mysql
sudo systemctl enable mysql


# SETUP MYSQL DATABASE
echo "This sets up the MySQL database and user for WordPress to use. It creates a new database" 
echo "called "wordpress" and a user called "worduser" with the necessary privileges to access that database."

sudo mysql -u root -e "CREATE DATABASE wordpress;"
sudo mysql -u root -e "CREATE USER 'worduser'@'localhost' IDENTIFIED BY 'teamalpha';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'worduser'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

sudo systemctl restart mysql

#Download WordPress
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz
sudo mv wordpress/ /var/www/html/
sudo chown www-data:www-data -R /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/

echo "The first command below is used to make a copy of the 000-default.conf file and create a new file named wordpress.conf in the"
echo "/etc/apache2/sites-available/ directory. While the second command, removes the default config file."
echo " And the third command restart apache server after all configuration have been made."

sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo rm -rf /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2

echo " Optionally, you can create a configuration for WordPress to help in processing any files"
echo " relating to WordPress and logging any errors that arise. For that, create a configuration"
echo " file and paste the below content, editing where necessary."

cat <<EOF | sudo tee /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>

ServerAdmin admin@teamalpha.com
DocumentRoot /var/www/html/wordpress
ServerName teamalpha.com
ServerAlias www.teamalpha.com

<Directory /var/www/html/wordpress/>
Options FollowSymLinks
AllowOverride All
Require all granted
</Directory>

ErrorLog /var/log/apache2/mywebsite_error.log
CustomLog /var/log/apache2/mywebsite_access.log combined

</VirtualHost>
EOF

echo "The first command below enables the Apache rewrite module, which is required for WordPress's URL rewriting feature."
echo "It modifies the Apache configuration to enable the module. while the second command enables the WordPress site" 
echo "configuration by creating a symbolic link from the configuration file (wordpress.conf) in the /etc/apache2/sites-available/" 
echo "directory to the /etc/apache2/sites-enabled/ directory.This allows Apache to use the WordPress configuration when serving the website."
echo "And the third command restart apache server to effect the changes"

sudo a2enmod rewrite
sudo a2ensite wordpress.conf
sudo systemctl restart apache2