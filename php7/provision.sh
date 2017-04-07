#!/usr/bin/env bash
 
export DEBIAN_FRONTEND=noninteractive
 
echo "--- Updating packages list ---"
sudo apt-get update
 
echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties
 
echo "--- Installing MySQL ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password highfive'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password highfive'
sudo apt-get -y install mysql-server
 
echo "--- Installing PHP ---"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository  ppa:ondrej/apache2
#sudo add-apt-repository -y ppa:ondrej/php5-oldstable
 
echo "--- Updating packages list ---"
sudo apt-get update
 
echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y apache2
sudo apt-get install -y php7.1 php7.1-curl php7.1-gd php7.1-mcrypt php7.1-mysql git-core php7.1-dev  php7.1-xml php7.1-mbstring
sudo apt-get install libapache2-mod-php7.1
 
echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php7.1-fpm 
 
 
#cat << EOF | sudo tee -a /etc/php7/mods-available/xdebug.ini
#xdebug.scream=1
#xdebug.cli_color=1
#xdebug.show_local_vars=1
#EOF
 
echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite
 
echo "--- Enabling SSL ---"
sudo a2enmod ssl
sudo a2ensite default-ssl
 
echo "--- Setting document root ---"
sudo rm -rf /var/www/html
sudo ln -fs /vagrant/public_html /var/www/html
sudo ln -fs /vagrant/protected /var/www/protected
 
sudo mkdir -p /data/protected
sudo ln -fs /vagrant/protected/.htpasswd /data/protected/.htpasswd
 
echo "--- What developer codes without errors turned on? Not you, master. ---"
 
sed -i "s/error_reporting = .*/error_reporting = E_ALL ^ E_DEPRECATED/"  /etc/php/7.1/apache2/php.ini 
 
sed -i "s/display_errors = .*/display_errors = On/"  /etc/php/7.1/apache2/php.ini 
 
sed -i "s/short_open_tag = Off/short_open_tag = On/"  /etc/php/7.1/apache2/php.ini 
 
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
 
 
#sed -i "s/var\/www/var\/www\/html/" /etc/apache2/sites-enabled/000-default.conf
#sed -i "s/var\/www/var\/www\/html/" /etc/apache2/sites-enabled/default-ssl.conf
 
 
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-enabled/000-default.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-enabled/default-ssl.conf
 
#sed -i "/DocumentRoot \/var\/www\/html/a \        RewriteEngine On" /etc/apache2/sites-available/000-default.conf
sed -i "/DocumentRoot \/var\/www\/html/a \        RewriteEngine On" /etc/apache2/sites-enabled/000-default.conf
 
 
#sed -i "/RewriteEngine On/a \        RewriteRule \^(.\*)$ https:\/\/%{HTTP_HOST}\$1 \[R=301,L\]" /etc/apache2/sites-available/000-default.conf
sed -i "/RewriteEngine On/a \        RewriteRule \^(.\*)$ https:\/\/%{HTTP_HOST}\$1 \[R=301,L\]" /etc/apache2/sites-enabled/default-ssl.conf
 
 
echo "--- Installing databases ---"
sudo /vagrant/vagrant/db.sh
 
echo "--- Restarting Apache ---"
sudo service apache2 restart
 
sudo mkdir -p /var/log/httpd
cd /var/log/httpd
touch error_log
sudo chmod -R 777 /var/log/httpd
 
echo "--- Installing composer ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
 
# Laravel stuff here, if you want
 
echo "--- Good to go, bro! ---"