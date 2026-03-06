FROM php:8.3-fpm-bookworm
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]

RUN apt-get update \
  && apt-get install -y vim git mariadb-client libicu-dev libonig-dev libzip-dev unzip locales \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/php-fpm /var/log/php /php/log \
  && chown -R www-data:www-data /php/log
RUN localedef -f UTF-8 -i en_US en_US.UTF-8

RUN docker-php-ext-install intl pdo_mysql mbstring zip bcmath

# nodejs (optional, for frontend build)
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer
ENV PATH=$PATH:/composer/vendor/bin
RUN composer config -g process-timeout 3600

COPY php-fpm.d/zzz-www.conf /usr/local/etc/php-fpm.d/zzz-www.conf
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www
