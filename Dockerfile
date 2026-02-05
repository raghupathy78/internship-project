FROM php:8.2-apache

# Install required system libs, MongoDB extension, and core PHP extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && a2dismod mpm_event mpm_worker || true \
    && a2enmod mpm_prefork || true \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/

EXPOSE 80
