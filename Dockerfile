FROM php:8.2-apache

# Disable conflicting Apache MPMs by renaming their load files
RUN mv /etc/apache2/mods-available/mpm_event.load /etc/apache2/mods-available/mpm_event.load.bak 2>/dev/null || true \
    && mv /etc/apache2/mods-available/mpm_worker.load /etc/apache2/mods-available/mpm_worker.load.bak 2>/dev/null || true

# Install dependencies and MongoDB driver
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable mpm_prefork explicitly
RUN a2enmod mpm_prefork 2>/dev/null || true

COPY . /var/www/html/

EXPOSE 80
