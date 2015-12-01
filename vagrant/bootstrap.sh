#!/usr/bin/env bash

# add-apt-repository has a known bug and will fail
# recreate sources.list as it is used by cloudcontrol
echo 'deb http://archive.ubuntu.com/ubuntu/ precise main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ precise-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu precise-security main restricted universe multiverse' | tee /etc/apt/sources.list

# additional sources used by cloudcontrol
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 548C16BF
echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E5267A6C
echo 'deb http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu precise main
deb-src http://ppa.launchpad.net/ondrej/php5-oldstable/ubuntu precise main' | tee /etc/apt/sources.list.d/ondrej-php5-oldstable-precise.list

apt-get update

# Install Apache and PHP:
apt-get install -yq apache2
apt-get install -yq php5-common libapache2-mod-php5 php5-cli php5-dev php5-xdebug

# Project:
apt-get install -yq php5-xmlrpc php5-curl

# Deployment and Elasticsearch:
apt-get install -yq php5-xmlrpc python-pip python-dev
pip install -U cctrl

# Install modules and patch config files:
a2enmod rewrite headers
apt-get install -yq patch
patch /etc/apache2/envvars < /vagrant/vagrant/etc_apache2_envvars.patch
patch /etc/apache2/apache2.conf < /vagrant/vagrant/etc_apache2_apache2.conf.patch
patch /etc/apache2/sites-available/default < /vagrant/vagrant/etc_apache2_sites-available_default.patch
patch /etc/php5/apache2/php.ini < /vagrant/vagrant/etc_php_apache2_php.ini.patch
patch /etc/php5/cli/php.ini < /vagrant/vagrant/etc_php_cli_php.ini.patch
patch /etc/rc.local < /vagrant/vagrant/etc_rc.local.patch

# Link directory and restart Apache:
rm -rf /var/www
ln -fs /vagrant/pub /var/www
chown -R vagrant:vagrant /var/lock/apache*
/etc/init.d/apache2 restart

# add default bash history
cat bash_history > /home/vagrant/.bash_history
chown vagrant:vagrant /home/vagrant/.bash_history

# change to vagrant dir on login
echo "cd /vagrant/" >> /home/vagrant/.profile
