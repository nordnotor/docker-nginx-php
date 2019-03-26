#!/bin/bash

# php-fpm.conf
{ \
    echo "decorate_workers_output = no"; \
} >> /usr/local/etc/php-fpm.d/zzz-www-docker.conf
