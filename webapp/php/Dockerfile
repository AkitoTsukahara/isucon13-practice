FROM php:8.2.11-fpm-bookworm

WORKDIR /tmp
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        default-mysql-client pdns-server pdns-backend-mysql \
        locales locales-all git unzip && \
    rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/powerdns/pdns.d/bind.conf

RUN docker-php-ext-install pdo_mysql

RUN locale-gen en_US.UTF-8
RUN useradd --uid=1001 --create-home isucon
USER isucon

WORKDIR /home/isucon/webapp/php
COPY --chown=isucon:isucon ./ /home/isucon/webapp/php/
RUN ./composer.phar install

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ utc
