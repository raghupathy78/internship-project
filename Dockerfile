FROM php:8.2-apache

# Aggressively disable all MPMs except mpm_prefork
RUN rm -f /etc/apache2/mods-enabled/*.load /etc/apache2/mods-enabled/*.conf && \
    rm -f /etc/apache2/mods-available/mpm_event.* && \
    rm -f /etc/apache2/mods-available/mpm_worker.* && \
    rm -f /etc/apache2/mods-available/mpm_async.* && \
    ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load && \
    ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

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
