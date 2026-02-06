FROM php:8.2-fpm

# Install Nginx and supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install MongoDB extension
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM
RUN mkdir -p /var/run/php-fpm && \
    echo "[global]" > /usr/local/etc/php-fpm.conf && \
    echo "daemonize = no" >> /usr/local/etc/php-fpm.conf && \
    echo "[www]" >> /usr/local/etc/php-fpm.conf && \
    echo "listen = 127.0.0.1:9000" >> /usr/local/etc/php-fpm.conf

# Configure Nginx
RUN rm /etc/nginx/sites-enabled/default && cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    root /var/www/html;
    
    location / {
        try_files \ \/ /index.php?\;
    }
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \\;
        include fastcgi_params;
    }
}
NGINX
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Configure Supervisor
RUN mkdir -p /etc/supervisor/conf.d && cat > /etc/supervisor/conf.d/services.conf << 'SUPERVISOR'
[program:php-fpm]
command=/usr/local/sbin/php-fpm
autostart=true
autorestart=true
stderr_logfile=/var/log/php-fpm.err.log
stdout_logfile=/var/log/php-fpm.out.log

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/nginx.err.log
stdout_logfile=/var/log/nginx.out.log
SUPERVISOR

WORKDIR /var/www/html
COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
