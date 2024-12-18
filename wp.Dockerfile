FROM wordpress:php7.4-apache

RUN a2enmod headers

# Install ionCube Loader
RUN cd /tmp && \
  curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > ioncube_loaders_lin_x86-64.tar.gz && \
  tar -xf ioncube_loaders_lin_x86-64.tar.gz && \
  cp ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ && \
  rm -rf ioncube && \
  echo "zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00-ioncube.ini

# Configure PHP settings for timeout and max input vars
RUN echo "max_execution_time = 300\n" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_input_vars = 10000\n" >> /usr/local/etc/php/conf.d/custom.ini

# delete /var/www/html/*
RUN rm -rf /var/www/html/*

# Copy application files
COPY . /var/www/html/
WORKDIR /var/www/html/

# Set up entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variables
ENV DB_HOST=localhost
ENV DB_USERNAME=root
ENV DB_DATABASE=mydatabase
ENV DB_PASSWORD=mypassword

# Default command
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
