FROM php:7.4-apache

RUN a2enmod rewrite

RUN docker-php-ext-install mysqli

RUN cd /tmp && \
  curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > ioncube_loaders_lin_x86-64.tar.gz && \
  tar -xf ioncube_loaders_lin_x86-64.tar.gz && \
  cp ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ && \
  rm -rf ioncube && \
  echo "zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00-ioncube.ini

COPY . /var/www/html/
WORKDIR /var/www/html/

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV DB_HOST=localhost
ENV DB_USERNAME=root
ENV DB_DATABASE=mydatabase
ENV DB_PASSWORD=mypassword

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
