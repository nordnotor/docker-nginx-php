#! /bin/sh

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

if [ -n ${PHP_SENDMAIL_PATH} ]; then echo "sendmail_path = \"${PHP_SENDMAIL_PATH}\"" >>  /usr/local/etc/php/conf.d/php.ini; fi
if [ -n ${PHP_SESSION_SAVE_PATH} ]; then echo "session.save_path = \"$PHP_SESSION_SAVE_PATH\"" >> /usr/local/etc/php/conf.d/php.ini; fi

# Set ssmtp conf
echo "root=${SSMTP_ROOT}" > /etc/ssmtp/ssmtp.conf
echo "mailhub=${SSMTP_MAILHUB}" >> /etc/ssmtp/ssmtp.conf
echo "hostname=${SSMTP_HOSTNAME}" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=${SSMTP_FROM_LINE_OVERRIDE}" >> /etc/ssmtp/ssmtp.conf

# Set nginx conf
sed -i s/^\;*\ *server_name\ *[0-9a-zA-Z_:\/.]*/server_name\ ${NGINX_HOST}/ /etc/nginx/conf.d/default.conf
sed -i s/^\;*\ *listen\ *[0-9a-zA-Z_:\/.]*/listen\ ${NGINX_PORT}/ /etc/nginx/conf.d/default.conf

# For dev mode
if [ ${MODE} = "dev" ]; then
    # Set IP host machine
    sed -i "$ a\xdebug.remote_host=$(/sbin/ip route|awk '/default/ { print $3 }')" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

chown -R www-data:www-data /var/www/ && chmod -R 600 /var/spool/cron/crontabs/

exec "$@"