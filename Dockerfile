FROM php:8.2-apache

# Install dependencies and MongoDB driver
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Disable all MPMs except mpm_prefork
RUN a2dismod mpm_event mpm_worker 2>/dev/null || true \
    && a2enmod mpm_prefork

COPY . /var/www/html/

EXPOSE 80
