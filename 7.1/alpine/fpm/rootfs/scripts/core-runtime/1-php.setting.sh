#!/bin/bash

# Edit PHP FPM CONF
echo "listen = $PHP_FPM_LISTEN" > /usr/local/etc/php-fpm.d/zz-docker.conf

# Edit PHP INI CONF
echo "memory_limit = $PHP_MEMORY_LIMIT" >> /usr/local/etc/php/conf.d/php.ini
echo "file_uploads = $PHP_FILE_UPLOADS" >> /usr/local/etc/php/conf.d/php.ini
echo "post_max_size = $PHP_POST_MAX_SIZE" >> /usr/local/etc/php/conf.d/php.ini
echo "max_input_time = $PHP_MAX_INPUT_TIME" >> /usr/local/etc/php/conf.d/php.ini
echo "max_execution_time = $PHP_MAX_EXECUTION_TIME" >> /usr/local/etc/php/conf.d/php.ini
echo "upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE" >> /usr/local/etc/php/conf.d/php.ini
echo "session.save_handler = $PHP_SESSION_SAVE_HANDLER" >> /usr/local/etc/php/conf.d/php.ini
echo "date.timezone = $PHP_DATE_TIME_ZONE" >> /usr/local/etc/php/php.ini

if [ -n ${PHP_SENDMAIL_PATH} ]; then
    echo "sendmail_path = \"${PHP_SENDMAIL_PATH}\"" >>  /usr/local/etc/php/conf.d/php.ini;
fi
if [ -n ${PHP_SESSION_SAVE_PATH} ]; then
    echo "session.save_path = \"$PHP_SESSION_SAVE_PATH\"" >> /usr/local/etc/php/conf.d/php.ini;
fi
