FROM php:8.2-apache

# Disable conflicting Apache MPMs and install extensions
RUN a2dismod mpm_event mpm_worker || true \
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
