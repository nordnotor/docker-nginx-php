#!/bin/bash

if [[ ${MODE} == 'dev' ]]; then
    # give permission for mount folder
    chown -R :www-data ${APP_FOLDER}
    # enable development php-ini configuration
    cp --force  ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini

    if [[ ${MODE_PHP_XDEBUG} == 'on' ]]; then
        # enable xdebug ext
        docker-php-ext-enable xdebug
        # set IP host machine for xdebug
        sed -i "$ a\xdebug.remote_host=$(/sbin/ip route|awk '/default/ { print $3 }')" ${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini
    fi
fi