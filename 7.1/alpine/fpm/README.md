
Image based on [Alpine Linux](https://hub.docker.com/_/alpine/).

### Build

You can easily build you docker image with some tunnings. Clone this repository and follow the instructions below.

```
docker build -t php-nginx:7.1-alpine-fpm .
```

### Run

```
docker run --rm --name app -p 80:80 php-nginx:7.1-alpine-fpm
```

And open localhost - [link](http://localhost/).

##### Directories
    /var/www/html - for web content
    /etc/nginx - for nginx configuration
    /usr/local/etc/php - for php configuration
    /var/spool/cron/crontabs - for crontabs configuration
    /etc/supervisor.programs -  for additional conf files for supervisor

##### Environment variables
    Name                            Default                       Description
    # Container settings    
    PUID                            1000
    PGID                            1000
    MODE                            "prod"                        prod|dev (xdebug is on)
    WAIT_FOR                        ""                            Waiting for other services. See: https://docs.docker.com/compose/startup-order/
    SECRET_ENV                      ""                            
    # Php settings  
    PHP_FILE_UPLOADS                "on"
    PHP_MEMORY_LIMIT                "2G"
    PHP_POST_MAX_SIZE               "50M"
    PHP_UPLOAD_MAX_FILESIZE         "50M"
    PHP_MAX_INPUT_TIME              60
    PHP_MAX_EXECUTION_TIME          300
    PHP_DATE_TIME_ZONE              "Europe/Kiev"
    PHP_SESSION_SAVE_HANDLER        "files"
    PHP_SESSION_SAVE_PATH           ""
    PHP_SENDMAIL_PATH               ""
    # Composer settings 
    GITHAB_ACCESS_KEY               ""
    # Event script path
    SCRIPTS_CORE_RUNTIME_DIR        "/usr/scripts/core-runtime"
    SCRIPTS_AFTER_WAIT_RUNTIME_DIR  "/usr/scripts/after-wait-for-it"
    SCRIPTS_BEFORE_WAIT_RUNTIME_DIR "/usr/scripts/before-wait-for-it"

##### Events
    The essence of events is the launch of scripts at a certain point in time. Container flow: 
    
    START -> CORE_EVENT -> REPLACE SECRETS -> BEFORE_WAIT_EVENT -> WAIT_FOR -> AFTER_WAIT_EVENT

    Event name           Env with path to scripts            Default path    
    CORE_EVENT           SCRIPTS_CORE_RUNTIME_DIR            "/usr/scripts/core-runtime"
    BEFORE_WAIT_EVENT    SCRIPTS_AFTER_WAIT_RUNTIME_DIR      "/usr/scripts/after-wait-for-it"
    AFTER_WAIT_EVENT     SCRIPTS_BEFORE_WAIT_RUNTIME_DIR     "/usr/scripts/before-wait-for-it"

    Notice: before running scripts we sort them. 

##### Logging

PHP and Nginx errors are forwarded to stderr and captured by supervisor. You can see them easily via [docker logs](https://docs.docker.com/engine/reference/commandline/logs/).