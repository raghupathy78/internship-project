FROM php:8.2-apache

# Remove other MPM module files completely and reconfigure Apache
RUN rm -f /etc/apache2/mods-available/mpm_event.* && \
    rm -f /etc/apache2/mods-available/mpm_worker.* && \
    rm -f /etc/apache2/mods-available/mpm_async.* && \
    rm -f /etc/apache2/mods-enabled/* && \
    ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load && \
    ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf && \
    grep -r "mpm_event\|mpm_worker\|mpm_async" /etc/apache2/conf-enabled/ /etc/apache2/conf-available/ && exit 1 || true

# Create a startup script to ensure only prefork is loaded
RUN echo '#!/bin/bash' > /usr/local/bin/start-apache.sh && \
    echo 'rm -f /etc/apache2/mods-enabled/mpm_*.load /etc/apache2/mods-enabled/mpm_*.conf' >> /usr/local/bin/start-apache.sh && \
    echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load' >> /usr/local/bin/start-apache.sh && \
    echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf' >> /usr/local/bin/start-apache.sh && \
    echo 'apache2-foreground' >> /usr/local/bin/start-apache.sh && \
    chmod +x /usr/local/bin/start-apache.sh

# Install required packages and PHP extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl-dev pkg-config && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-install pdo pdo_mysql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/

EXPOSE 80

CMD ["/usr/local/bin/start-apache.sh"]
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
