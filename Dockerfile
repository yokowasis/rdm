FROM php:7.4-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install necessary extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxpm-dev \
    libwebp-dev \
    libbz2-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    libldap2-dev \
    libgmp-dev \
    libpspell-dev \
    libmagickwand-dev --no-install-recommends \
    && docker-php-ext-install \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    gettext \
    intl \
    ldap \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    shmop \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    zip \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install ionCube Loader
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
