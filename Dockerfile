FROM php:8.2-fpm

# Install Nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install MongoDB extension
RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl-dev pkg-config && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-install pdo pdo_mysql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Disable default Nginx config
RUN rm -f /etc/nginx/sites-enabled/default

# Create working Nginx config
RUN cat > /etc/nginx/conf.d/app.conf << 'EOF'
upstream php {
    server 127.0.0.1:9000;
}

server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.php index.html;

    client_max_body_size 20M;

    location ~ \.php$ {
        fastcgi_pass php;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \\;
        include fastcgi_params;
    }
    
    location / {
        try_files \ \/ /index.php?\;
    }
}
EOF

WORKDIR /var/www/html
COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Start services
CMD ["bash", "-c", "php-fpm --daemonize && nginx -g 'daemon off;'"]
