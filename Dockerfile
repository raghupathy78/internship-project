FROM php:8.2-apache

# Completely disable conflicting MPMs by removing their config files
RUN rm /etc/apache2/mods-available/mpm_event.* /etc/apache2/mods-available/mpm_worker.* 2>/dev/null || true

# Clear all enabled modules and rebuild
RUN rm -rf /etc/apache2/mods-enabled/* && mkdir -p /etc/apache2/mods-enabled

# Enable only prefork MPM
RUN ln -s /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load && \
    ln -s /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

# Install dependencies and MongoDB driver
RUN apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/

EXPOSE 80
