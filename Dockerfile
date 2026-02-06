FROM php:8.2-fpm

# Install MongoDB driver
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY . /var/www/html/

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:80"]
