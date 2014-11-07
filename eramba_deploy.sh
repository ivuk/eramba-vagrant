#!/bin/bash

DATABASE_PASS="ididnotreadtheinstructions"
ERAMBA_DB_USER="ididnotread"
ERAMBA_DB_PASS="ididnotreadtheinstructions"
ERAMBA_DB="ididnotreadtheinstructions"
TIMEZONE="Europe/Amsterdam"

yum install -q -y httpd php mysql-server unzip php-pdo php-mysql

cd /var/www/html/ && unzip -qq /vagrant/eramba_v2.zip

service mysqld start

# Initial MySQL setup, like running mysql_secure_installation
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Add eramba DB settings
mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE $ERAMBA_DB"
mysql -u root -p"$DATABASE_PASS" -e "CREATE USER $ERAMBA_DB_USER@'localhost' IDENTIFIED BY '$ERAMBA_DB_PASS'"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON $ERAMBA_DB.* TO $ERAMBA_DB_USER@'localhost'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Import the Eramba DB data; note that the DB dump contains only tables, DB needs to be created already
mysql -u $ERAMBA_DB_USER -p"$ERAMBA_DB_PASS" "$ERAMBA_DB" < /var/www/html/eramba_v2/app/Config/db_schema/default_mysql_schema_211.sql

# Update the database.php config file so Eramba has the new DB settings
sed -i "s/'host' => '',/'host' => 'localhost',/g" /var/www/html/eramba_v2/app/Config/database.php
sed -i "s/'login' => '',/'login' => '$ERAMBA_DB_USER',/g" /var/www/html/eramba_v2/app/Config/database.php
sed -i "s/'password' => '',/'password' => '$ERAMBA_DB_PASS',/g" /var/www/html/eramba_v2/app/Config/database.php
sed -i "s/'database' => '',/'database' => '$ERAMBA_DB',/g" /var/www/html/eramba_v2/app/Config/database.php

# Fix permissions according to Eramba install guide
chgrp -R apache /var/www/html/eramba_v2/app/tmp/
chmod -R g+w /var/www/html/eramba_v2/app/tmp/

chgrp -R apache /var/www/html/eramba_v2/app/webroot/files/
chmod -R g+w /var/www/html/eramba_v2/app/webroot/files/

# Set the PHP timezone
sed -i "s@;date.timezone =@date.timezone = \"$TIMEZONE\"@g" /etc/php.ini

# Hack up the virtual host
cat << _EOF_ > /etc/httpd/conf.d/eramba-http.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/eramba_v2
    <Directory /var/www/html/eramba_v2>
        AllowOverride All
    </Directory>
</VirtualHost>
_EOF_

# Start Apache HTTPD
service httpd restart
