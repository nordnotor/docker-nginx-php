#!/bin/bash

# For dev mode
if [ ${MODE} = "dev" ]; then
    # Set IP host machine for xdebug
    sed -i "$ a\xdebug.remote_host=$(/sbin/ip route|awk '/default/ { print $3 }')" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    # enable xdebug for php
    phpmod enable xdebug
fi