FROM php:8.2-fpm

# Install Apache and other dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-fcgid \
    libssl-dev \
    pkg-config \
    && a2enmod fcgid \
    && a2enmod proxy \
 && a2enmod proxy_fcgi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install MongoDB driver
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Install PDO extensions
RUN docker-php-ext-install pdo pdo_mysql

# Configure Apache virtual host for PHP-FPM
RUN echo '<VirtualHost *:80>\n\
    ServerAdmin admin@localhost\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    <FilesMatch \.php$>\n\
        SetHandler \"proxy:unix:/run/php-fpm.sock|fcgi://localhost\"\n\
    </FilesMatch>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

COPY . /var/www/html/

RUN mkdir -p /run/php-fpm && chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["sh", "-c", "php-fpm --daemonize && apache2ctl -D FOREGROUND"]
