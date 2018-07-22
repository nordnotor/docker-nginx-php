#!/bin/bash

# Set nginx conf
sed -i s/^\;*\ *client_max_body_size\ *[0-9a-zA-Z_:\/.]*/client_max_body_size\ ${PHP_UPLOAD_MAX_FILESIZE}/ /etc/nginx/nginx.conf
