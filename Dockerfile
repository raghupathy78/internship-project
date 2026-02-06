FROM php:8.2-fpm

# Install Nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Install MongoDB extension - required by composer.json
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on TCP port 9000
RUN sed -i 's/^listen = .*/listen = 9000/' /usr/local/etc/php-fpm.d/www.conf

# Create Nginx config
RUN mkdir -p /etc/nginx/sites-enabled && cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.php index.html;
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \\;
        include fastcgi_params;
    }
}
EOF
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Disable Nginx default server
RUN rm -f /etc/nginx/sites-enabled/default.conf 2>/dev/null || true

WORKDIR /var/www/html

COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Create startup script
RUN cat > /start.sh << 'EOF'
#!/bin/bash
set -e
php-fpm &
nginx -g "daemon off;"
EOF
RUN chmod +x /start.sh

CMD ["/start.sh"]
