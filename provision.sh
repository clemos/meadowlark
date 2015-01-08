#!/usr/bin/env bash

cd /vagrant

echo "=== Adding 'cd /vagrant' to .profile"
cat >> /home/vagrant/.profile <<EOL

cd /vagrant
EOL

echo "=== Updating apt..."
apt-get update >/dev/null 2>&1

mkdir www
chown vagrant:vagrant www

echo "=== Installing Apache..."
apt-get install -y apache2

# Enable mod_rewrite, allow .htaccess and fix a virtualbox bug according to
# https://github.com/mitchellh/vagrant/issues/351#issuecomment-1339640
a2enmod rewrite
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/sites-enabled/000-default
echo EnableSendFile Off > /etc/apache2/conf.d/virtualbox-bugfix

# Link to www dir
rm -rf /var/www
ln -fs /vagrant/www /var/www

echo "=== Installing curl..."
apt-get install -y curl

echo "=== Installing PHP..."
apt-get install -y php5 php5-gd php5-mysql php5-curl php5-cli php5-sqlite php5-xdebug php-apc

cat > /etc/php5/conf.d/vagrant.ini <<EOL
display_errors = On
html_errors = On
EOL

echo "=== Installing PHP utilities (Composer)..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin

echo "=== Installing PHP utilities (phing)..."
wget -q -O /usr/local/bin/phing.phar http://www.phing.info/get/phing-latest.phar && chmod 755 /usr/local/bin/phing.phar

echo "=== Installing Mysql..."
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server mysql-client

echo "=== Creating Mysql DB (test)..."
mysql -u root -e "create database test"

echo "=== Restarting Apache..."
service apache2 restart

echo "=== LAMP setup completed."
echo "Change timezone: sudo dpkg-reconfigure tzdata"
echo "Change hostname: sudo pico /etc/hostname && sudo pico /etc/hosts"

echo "=== Installing Haxe..."
wget -q http://www.openfl.org/builds/haxe/haxe-3.1.3-linux-installer.tar.gz -O - | tar -xz
sh install-haxe.sh -y >/dev/null 2>&1
rm -f install-haxe.sh

echo "=== Installing mod_neko for Apache..."

cat > /etc/apache2/conf.d/neko <<EOL
LoadModule neko_module /usr/lib/neko/mod_neko2.ndll
AddHandler neko-handler .n
DirectoryIndex index.n
EOL

mkdir /vagrant/src

cat > /vagrant/src/Index.hx <<EOL
class Index {
    static function main() {
        trace("Hello World !");
    }
}
EOL

cat > /vagrant/src/build.hxml <<EOL
-neko ../www/index.n
-main Index
EOL

chown -R vagrant:vagrant src
su vagrant -c 'cd /vagrant/src && haxe build.hxml'

service apache2 restart

echo "=== Installing MongoDB..."
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
apt-get update
apt-get install -y mongodb-org

echo "=== Installing Node.js..."
apt-get install python-software-properties -y
add-apt-repository ppa:chris-lea/node.js -y
apt-get update
apt-get install nodejs -y
# npm config set spin=false

npm install -g browserify watchify

echo "=== Installing ruby..."
apt-get install -y curl
command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm

echo "--- Installing Jekyll and bootstrap docs..."
cd /vagrant
gem install jekyll
gem install rouge
npm install bootstrap
# Remove ads...
cat /dev/null > /vagrant/node_modules/bootstrap/docs/_includes/ads.html
cat /dev/null > /vagrant/node_modules/bootstrap/docs/_includes/social-buttons.html
cat >> /home/vagrant/.profile <<EOL
! nc -zw1 localhost 9001 && pushd /vagrant/node_modules/bootstrap && jekyll serve --detach && popd
EOL
