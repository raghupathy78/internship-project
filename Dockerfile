FROM php:8.2-apache

# Disable conflicting Apache MPMs and install extensions
RUN # ensure only prefork MPM is present: remove other MPM load files if any
    rm -f /etc/apache2/mods-enabled/mpm_event.load /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_worker.load /etc/apache2/mods-enabled/mpm_worker.conf || true \
    && a2dismod mpm_event mpm_worker || true \
    && a2enmod mpm_prefork || true \
    && echo "--- /etc/apache2/mods-enabled after MPM changes ---" \
    && ls -la /etc/apache2/mods-enabled || true \
    && echo "--- /etc/apache2/mods-enabled/*.load contents ---" \
    && (for f in /etc/apache2/mods-enabled/*.load; do echo "---- $f ----"; cat "$f"; done) || true \
    && apt-get update \
    && apt-get install -y --no-install-recommends libssl-dev pkg-config \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/

EXPOSE 80
