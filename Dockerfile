FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    libssl-dev \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-install pdo pdo_mysql

# Create application directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Configure PHP-FPM
RUN cat > /usr/local/etc/php-fpm.d/zzz-app.conf << 'PHPFPM'
[global]
daemonize = no

[www]
listen = 127.0.0.1:9000
pm = static
pm.max_children = 10
PHPFPM

# Configure Nginx
RUN rm -f /etc/nginx/sites-enabled/* /etc/nginx/conf.d/default.conf && \
    cat > /etc/nginx/conf.d/app.conf << 'NGINX'
upstream php_fpm {
  server 127.0.0.1:9000;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  
  server_name _;
  root /var/www/html;
  index index.php index.html index.htm;
  
  location ~ \.php$ {
    fastcgi_pass php_fpm;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \\;
    include fastcgi_params;
  }
  
  location / {
    try_files \ \/ /index.php?\;
  }
}
NGINX

EXPOSE 80

# Run both services
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
