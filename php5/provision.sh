#!/usr/bin/env bash
 
export DEBIAN_FRONTEND=noninteractive
 
echo "--- Updating packages list ---"
sudo apt-get update
 
echo "--- Installing base packages ---"
sudo apt-get install -y vim curl python-software-properties
 
echo "--- Installing MySQL ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password david'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password david'
sudo apt-get -y install mysql-server
 
echo "--- Installing PHP ---"
# sudo add-apt-repository -y ppa:ondrej/php5
sudo add-apt-repository -y ppa:ondrej/php5-oldstable
 
echo "--- Updating packages list ---"
sudo apt-get update
 
echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql git-core php5-geoip php5-dev libgeoip-dev
 
echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug
 
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF
 
echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite
 
echo "--- Enabling SSL ---"
sudo a2enmod ssl
sudo a2ensite default-ssl
 
echo "--- Setting document root ---"
sudo rm -rf /var/www/html
sudo ln -fs /vagrant/public_html /var/www/html
  
echo "--- What developer codes without errors turned on? Not you, master. ---"
 
sed -i "s/error_reporting = .*/error_reporting = E_ALL ^ E_DEPRECATED/" /etc/php5/apache2/php.ini
 
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
 
sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
 
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
 
 
sed -i "s/var\/www/var\/www\/html/" /etc/apache2/sites-enabled/000-default
sed -i "s/var\/www/var\/www\/html/" /etc/apache2/sites-enabled/default-ssl
 
 
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-enabled/000-default
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-enabled/default-ssl
 
sed -i "/DocumentRoot \/var\/www\/html/a \        RewriteEngine On" /etc/apache2/sites-enabled/000-default
 
sed -i "/RewriteEngine On/a \        RewriteRule \^(.\*)$ https:\/\/%{HTTP_HOST}\$1 \[R=301,L\]" /etc/apache2/sites-enabled/default-ssl
 
 
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
