FROM php:8.0-fpm-buster
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]

RUN apt-get update
RUN  apt-get install -y vim git mariadb-client libicu-dev libonig-dev libzip-dev unzip locales
RUN apt-get clean
RUN mkdir /var/run/php-fpm && \
  mkdir /var/log/php

# install PHP extenstionslocaledef -f UTF-8 -i en_US en_US.UTF-8
RUN docker-php-ext-install intl pdo_mysql mbstring zip bcmath

# composer
COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# composer 高速化
RUN composer config -g process-timeout 3600

COPY ./php-fpm.d/zzz-www.conf /usr/local/etc/php-fpm.d/zzz-www.conf
COPY php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www

RUN composer global require "laravel/installer"
