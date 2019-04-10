#!/bin/bash

NGINX_CONF_PATH="/etc/nginx/nginx.conf"

# root nginx conf
sed -i s/^\;*\ *client_max_body_size\ *[0-9a-zA-Z_:\/.]*/client_max_body_size\ ${CONF_PHP_INI_UPLOAD_MAX_FILESIZE}/ ${NGINX_CONF_PATH}