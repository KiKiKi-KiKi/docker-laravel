FROM php:7.4-fpm
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]

RUN apt-get update
RUN  apt-get install -y vim git libicu-dev libonig-dev libzip-dev unzip
RUN apt-get clean
RUN mkdir /var/run/php-fpm && \
  mkdir /var/log/php

# composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# install PHP extenstionslocaledef -f UTF-8 -i en_US en_US.UTF-8
RUN docker-php-ext-install intl pdo_mysql mbstring zip bcmath

# composer 高速化
RUN composer config -g process-timeout 3600 && \
  composer config -g repos.packagist composer https://packagist.jp && \
  composer global require hirak/prestissimo

COPY ./php-fpm.d/zzz-www.conf /usr/local/etc/php-fpm.d/zzz-www.conf
COPY php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www

RUN composer global require "laravel/installer"
