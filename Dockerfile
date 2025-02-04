FROM php:7.4-apache

# Enable Apache mod_rewrite and SSL modules
RUN a2enmod rewrite ssl headers

# Install necessary dependencies and PHP extensions, including GD
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
    libmagickwand-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    --no-install-recommends \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
    pcntl \
    ffi \
    pspell \
    gd \
    bcmath \
    bz2 \
    calendar \
    exif \
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
    curl \
    mbstring \
    xml \
    simplexml \
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

# Configure PHP settings for timeout and max input vars
RUN echo "max_execution_time = 300\n" >> /usr/local/etc/php/conf.d/custom.ini && \
    echo "max_input_vars = 10000\n" >> /usr/local/etc/php/conf.d/custom.ini

# Copy application files
COPY src /var/www/html/
WORKDIR /var/www/html/

# Set ownership of application files
RUN chown -R www-data:www-data /var/www/html

# Set up entrypoint
COPY src/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variables
ENV DB_HOST=localhost
ENV DB_USERNAME=root
ENV DB_DATABASE=mydatabase
ENV DB_PASSWORD=mypassword

# Expose HTTP (80) and HTTPS (443, 3000) ports
EXPOSE 80

# Default command
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
