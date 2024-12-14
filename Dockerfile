FROM php:7.4-apache

RUN cd /tmp && \
  curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > ioncube_loaders_lin_x86-64.tar.gz && \
  tar -xf ioncube_loaders_lin_x86-64.tar.gz && \
  cp ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ && \
  rm -rf ioncube && \
  echo "zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00-ioncube.ini

COPY . /var/www/html/
WORKDIR /var/www/html/

ENV DB_HOST=localhost
ENV DB_USERNAME=root
ENV DB_DATABASE=mydatabase
ENV DB_PASSWORD=mypassword

RUN echo "<?php\n\
defined('BASEPATH') OR exit('No direct script access allowed');\n\
\$host = '${DB_HOST}';\n\
\$databaseuser = '${DB_USERNAME}';\n\
\$databasename = '${DB_DATABASE}';\n\
\$dbpassword = '${DB_PASSWORD}';\n\
define('DB_SERVER', \$host);\n\
define('DB_USERNAME', \$databaseuser);\n\
define('DB_PASSWORD', \$dbpassword);\n\
define('DB_DATABASE', \$databasename);\n\
?>" > /var/www/html/config.php
