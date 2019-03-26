#!/bin/bash

NGINX_CONF_PATH="/etc/nginx/nginx.conf"
DEFAULT_HOST_CONF_PATH="/etc/nginx/conf.d/default.conf"

# root nginx conf
sed -i s/^\;*\ *client_max_body_size\ *[0-9a-zA-Z_:\/.]*/client_max_body_size\ ${CONF_PHP_INI_UPLOAD_MAX_FILESIZE}/ ${NGINX_CONF_PATH}
# host nginx conf
sed -i s/^\;*\ *"listen"\ *[0-9a-zA-Z_:\/.]*/"listen"\ ${NGINX_PORT}/ ${DEFAULT_HOST_CONF_PATH}
sed -i s/^\;*\ *"root"\ *[0-9a-zA-Z_:\/.]*/"root"\ ${NGINX_ROOT//\//\\/}/ ${DEFAULT_HOST_CONF_PATH}
sed -i s/^\;*\ *"server_name"\ *[0-9a-zA-Z_:\/.]*/"server_name"\ ${NGINX_HOST}/ ${DEFAULT_HOST_CONF_PATH}
sed -i s/^\;*\ *"set \$uncheck_robots"\ *[0-9a-zA-Z_:\/.]*/"set \$uncheck_robots"\ ${NGINX_UNCHECK_ROBOTS}/ ${DEFAULT_HOST_CONF_PATH}
