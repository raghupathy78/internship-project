FROM php:8.2-fpm

# Install Apache and required PHP modules
RUN apt-get update && \
    apt-get install -y --no-install-recommends apache2 apache2-mod-fcgid && \
    apt-get install -y --no-install-recommends libssl-dev pkg-config && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-install pdo pdo_mysql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Disable conflicting MPMs if present and enable only prefork
RUN a2dismod mpm_event mpm_worker mpm_async 2>/dev/null || true && \
    a2enmod mpm_prefork 2>/dev/null || true && \
    a2enmod proxy && \
    a2enmod proxy_fcgi && \
    a2enmod setenvif

# Configure Apache to use PHP-FPM
RUN mkdir -p /etc/apache2/conf-available && \
    echo '<IfModule mod_version.c>' > /etc/apache2/conf-available/php-fpm.conf && \
    echo '  <IfVersion >= 2.4.26>' >> /etc/apache2/conf-available/php-fpm.conf && \
    echo '    <FilesMatch ".+\.php$">' >> /etc/apache2/conf-available/php-fpm.conf && \
    echo '      SetHandler "proxy:unix:/run/php/php-fpm.sock|fcgi://localhost/"' >> /etc/apache2/conf-available/php-fpm.conf && \
    echo '    </FilesMatch>' >> /etc/apache2/conf-available/php-fpm.conf && \
    echo '  </IfVersion>' >> /etc/apache2/conf-available/php-fpm.conf && \
    echo '</IfModule>' >> /etc/apache2/conf-available/php-fpm.conf && \
    a2enconf php-fpm

# Enable Apache modules for mod_php 
RUN a2enmod php8.2 2>/dev/null || true

COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Start both PHP-FPM and Apache
CMD ["sh", "-c", "php-fpm -D && apache2ctl -D FOREGROUND"]
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
