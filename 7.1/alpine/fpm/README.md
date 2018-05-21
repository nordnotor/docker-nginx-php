
Image based on [Alpine Linux](https://hub.docker.com/_/alpine/).

### Build

You can easily build you docker image with some tunnings. Clone this repository and follow the instructions below.

```
docker build -t php-nginx:7.1-alpine-fpm ./7.1/alpine/fpm/
```

### Run

```
docker run --rm --name app -p 80:80 php-nginx:7.1-alpine-fpm
```

And open localhost - [link](http://localhost/).

##### Arguments
    PUID - user id
    PGID - user group id

##### Directories
    /var/www/html - web content
    /etc/nginx/ - nginx configuration folder
    /usr/local/etc/php/ - php configuration folder
    /var/spool/cron/crontabs/ - crontabs configuration folder

##### Environment variables
    Name                        Default
    MODE                        "prod"
    PHP_DATE_TIME_ZONE          "Europe/Kiev"
    PHP_MEMORY_LIMIT            "2G"
    PHP_POST_MAX_SIZE           "50M"
    PHP_MAX_INPUT_TIME          60
    PHP_MAX_EXECUTION_TIME      300
    PHP_UPLOAD_MAX_FILESIZE     "50M"
    PHP_FILE_UPLOADS            "on"
    PHP_SESSION_SAVE_HANDLER    "files"
    PHP_SESSION_SAVE_PATH       ""
    PHP_SENDMAIL_PATH           ""
    PHP_FPM_LISTEN              "/var/run/php.sock"
    NGINX_HOST                  "localhost"
    NGINX_PORT                  "80"
    
##### Logging

PHP and Nginx errors are forwarded to stderr and captured by supervisor. You can see them easily via [docker logs](https://docs.docker.com/engine/reference/commandline/logs/).