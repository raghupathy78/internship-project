FROM php:8.2-fpm

# Install Nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Install MongoDB extension
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure Nginx for PHP-FPM
RUN mkdir -p /etc/nginx/sites-enabled && \
    echo 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /var/www/html;\n\
    index index.php index.html;\n\
    location ~ \\.php$ {\n\
        fastcgi_pass 127.0.0.1:9000;\n\
        fastcgi_index index.php;\n\
        fastcgi_param SCRIPT_FILENAME \\;\n\
        include fastcgi_params;\n\
    }\n\
}' > /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY . /var/www/html/

EXPOSE 80

CMD ["sh", "-c", "php-fpm && nginx -g \"daemon off;\""]
