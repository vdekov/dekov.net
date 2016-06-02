#! /usr/bin/env bash

sudo timedatectl set-timezone 'Europe/Sofia'

echo "Setting www root folder to the shared directory"
sudo rm -rf /var/www
sudo ln -fs /vagrant /var/www
# sudo rm -rf /var/www/node_modules
sudo chmod -R 644 /var/www

echo "Updating packages list"
# Add Nginx repository to download the latest version
wget -qO - http://nginx.org/keys/nginx_signing.key | sudo apt-key add - > /dev/null 2>&1
sudo echo -e "deb http://nginx.org/packages/mainline/ubuntu/ `lsb_release -cs` nginx\ndeb-src http://nginx.org/packages/mainline/ubuntu/ `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list > /dev/null 2>&1
# Add PHP7 repository to download the latest version
sudo add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
# Add MongoDB repository to download the latest version
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 > /dev/null 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list > /dev/null 2>&1
sudo apt-get -qq update
sudo apt-get -qq -y upgrade > /dev/null 2>&1

echo "Install Apache, Nginx, Git"
sudo apt-get -y install apache2 nginx git > /dev/null 2>&1
sudo service apache2 stop > /dev/null 2>&1

echo "Configure Apache environment"
sudo sed -i '/Listen 80/c Listen 8080' /etc/apache2/ports.conf
sudo rm -f /etc/apache2/sites-available/000-default.conf
sudo ln -fs /vagrant/configs/apache2.conf /etc/apache2/sites-available/000-default.conf
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf > /dev/null 2>&1
sudo a2enconf servername > /dev/null 2>&1
sudo a2enmod rewrite > /dev/null 2>&1

echo "Restarting Apache"
sudo service apache2 start > /dev/null 2>&1
sudo service apache2 reload > /dev/null 2>&1
sudo update-rc.d apache2 defaults > /dev/null 2>&1

echo "Configure Nginx environment"
sudo rm -f /etc/nginx/conf.d/default.conf
sudo ln -fs /vagrant/configs/dekov.net.conf /etc/nginx/conf.d/default.conf
sudo ln -fs /vagrant/configs/ssl /etc/nginx/ssl
# Enable the Nginx 'gzip' module
sudo sed -i '/#gzip  on;/c gzip on;gzip_proxied any;gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;gzip_vary on;gzip_min_length 256;' /etc/nginx/nginx.conf

echo "Restarting Nginx"
sudo service nginx restart > /dev/null 2>&1
sudo update-rc.d nginx defaults > /dev/null 2>&1

echo "Install NVM and NodeJS"
curl -s https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash > /dev/null 2>&1
echo "source /home/vagrant/.nvm/nvm.sh" >> /home/vagrant/.profile
source /home/vagrant/.profile
nvm install v6.2.0 > /dev/null 2>&1

echo "Install NPM Modules"
cd /var/www
npm install > /dev/null 2>&1
npm install pm2@latest -g > /dev/null 2>&1
npm install -g vtop > /dev/null 2>&1
npm install -g speed-test > /dev/null 2>&1

echo "Configure NodeJS environment"
sudo mkdir -p /var/log/node
sudo touch /var/log/node/node-error.log
sudo touch /var/log/node/console.log
sudo chmod a+w -R /var/log/node

echo "Install PHP7 and MySQL"
sudo apt-get -y install php7.0-cli php7.0-common libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-mysql php7.0-bz2 > /dev/null 2>&1
# sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
# sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server-5.6 > /dev/null 2>&1
sudo sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo service mysql restart > /dev/null 2>&1
sudo /usr/sbin/update-rc.d mysql defaults > /dev/null 2>&1 # launching on boot

echo "Install MongoDB"
sudo apt-get install -y mongodb-org > /dev/null 2>&1
sudo sed -i '/bindIp: 127.0.0.1/c #bindIp: 127.0.0.1' /etc/mongod.conf

echo "Add aliases into ~/.bashrc"
sudo cat >> ~/.bashrc <<EOF
# Set aliases
alias box_start='sudo /etc/init.d/nginx restart && sudo /etc/init.d/apache2 restart && pm2 start /var/www/app.js -i 0 && sudo service mongod restart'
alias vtop='vtop --theme brew'
alias node_logs='tail -f /var/log/node/*.log'
alias node_logs_empty='sudo truncate /var/log/node/*.log -s 0'
EOF
source ~/.bashrc

echo "Cleaning..."
sudo apt-get clean
sudo rm -rf /var/www/html