FROM php:8.2-fpm-alpine

# Install Nginx (no MPM conflicts)
RUN apk add --no-cache nginx openssl openssl-dev pkgconfig

# Install mongodb extension
RUN apk add --no-cache autoconf gcc g++ make && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-install pdo pdo_mysql && \
    apk del autoconf gcc g++ make

# Configure Nginx to proxy PHP requests to FPM
RUN mkdir -p /etc/nginx/conf.d && \
    echo 'upstream php-fpm {' > /etc/nginx/conf.d/upstream.conf && \
    echo '    server unix:/run/php-fpm.sock;' >> /etc/nginx/conf.d/upstream.conf && \
    echo '}' >> /etc/nginx/conf.d/upstream.conf && \
    echo '' >> /etc/nginx/conf.d/upstream.conf && \
    echo 'server {' >> /etc/nginx/conf.d/default.conf && \
    echo '    listen 80 default_server;' >> /etc/nginx/conf.d/default.conf && \
    echo '    root /var/www/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    index index.php;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location ~ \.php$ {' >> /etc/nginx/conf.d/default.conf && \
    echo '        fastcgi_pass php-fpm;' >> /etc/nginx/conf.d/default.conf && \
    echo '        fastcgi_index index.php;' >> /etc/nginx/conf.d/default.conf && \
    echo '        include fastcgi.conf;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
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
