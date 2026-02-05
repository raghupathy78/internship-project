FROM php:8.2-fpm-alpine

# Install Apache and required PHP modules
RUN apk add --no-cache apache2 apache2-proxy && \
    apk add --no-cache openssl openssl-dev pkgconfig

# Install mongodb extension
RUN apk add --no-cache autoconf gcc g++ make && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-install pdo pdo_mysql && \
    apk del autoconf gcc g++ make

# Configure Apache with only mpm_prefork
RUN mkdir -p /etc/apache2/conf.d && \
    echo 'LoadModule mpm_prefork_module modules/mod_mpm_prefork.so' > /etc/apache2/conf.d/mpm.conf && \
    echo 'LoadModule authz_core_module modules/mod_authz_core.so' >> /etc/apache2/conf.d/mpm.conf && \
    echo 'LoadModule authz_user_module modules/mod_authz_user.so' >> /etc/apache2/conf.d/mpm.conf && \
    echo '<FilesMatch ".+\.php$">' >> /etc/apache2/conf.d/php-handler.conf && \
    echo '  SetHandler "proxy:unix:/run/php-fpm.sock|fcgi://localhost"' >> /etc/apache2/conf.d/php-handler.conf && \
    echo '</FilesMatch>' >> /etc/apache2/conf.d/php-handler.conf

COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Start PHP-FPM in background and Apache in foreground
CMD ["sh", "-c", "php-fpm -D && apachectl -D FOREGROUND"]
FROM php:8.2-apache

# Disable conflicting Apache MPMs and install extensions
RUN rm -rf /etc/apache2/mods-enabled/* || true \
    && ( [ -f /etc/apache2/mods-available/mpm_prefork.load ] && ln -s /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load ) || true \
    && ( [ -f /etc/apache2/mods-available/mpm_prefork.conf ] && ln -s /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf ) || true \
    && a2enmod mpm_prefork || true \
    && apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/

EXPOSE 80
