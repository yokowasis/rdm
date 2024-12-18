FROM php:7.4-apache

# Enable Apache mod_rewrite and SSL modules
RUN a2enmod rewrite ssl

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

# Generate self-signed SSL certificate
RUN mkdir -p /etc/apache2/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache-selfsigned.key \
    -out /etc/apache2/ssl/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost"

    
# Configure Apache for both HTTP and HTTPS
RUN echo "\
Listen 3000\n\
<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
</VirtualHost>\n\
<VirtualHost *:443>\n\
    DocumentRoot /var/www/html\n\
    SSLEngine on\n\
    SSLCertificateFile /etc/apache2/ssl/apache-selfsigned.crt\n\
    SSLCertificateKeyFile /etc/apache2/ssl/apache-selfsigned.key\n\
</VirtualHost>\n\
<VirtualHost *:3000>\n\
    DocumentRoot /var/www/html\n\
    SSLEngine on\n\
    SSLCertificateFile /etc/apache2/ssl/apache-selfsigned.crt\n\
    SSLCertificateKeyFile /etc/apache2/ssl/apache-selfsigned.key\n\
</VirtualHost>\n" > /etc/apache2/sites-available/default-ssl.conf && \
    a2ensite default-ssl.conf

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

# Expose HTTP (80) and HTTPS (443, 3000) ports
EXPOSE 80 443 3000

# Default command
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
