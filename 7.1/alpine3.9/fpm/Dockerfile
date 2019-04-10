FROM php:7.1.27-fpm-alpine3.9

# arg
ARG VERSION='1.0.0'
ARG ROOTFS_DIR='./rootfs'
ARG COMMON_ROOTFS_DIR='./rootfs'

# container env
ENV MODE='prod' \
    MODE_PHP_XDEBUG='off' \
    WAIT_FOR='' \
    SECRET_ENV='' \
    APP_FOLDER='/var/www/html'

# tallyman
ENV TALLYMAN_NAME="default"

# php env
ENV CONF_PHP_INI_MAX_INPUT_TIME='60' \
    CONF_PHP_INI_MAX_EXECUTION_TIME='300' \
    CONF_PHP_INI_MEMORY_LIMIT='-1' \
    CONF_PHP_INI_FILE_UPLOADS='On' \
    CONF_PHP_INI_POST_MAX_SIZE='50M' \
    CONF_PHP_INI_UPLOAD_MAX_FILESIZE='50M' \
    CONF_PHP_INI_TIMEZONE='Europe/Oslo' \
    CONF_PHP_INI_ERROR_LOG='/dev/stderr' \
    CONF_PHP_INI_SESSION_SAVE_HANDLER='files' \
    CONF_PHP_INI_REALPATH_CACHE_SIZE='4096K' \
    CONF_PHP_INI_REALPATH_CACHE_TTL=600 \
    CONF_PHP_INI_MAIL_LOG='/var/log/php/mail.log' \
    CONF_PHP_INI_MAIL_ADD_X_HEADER='Off' \
    CONF_PHP_INI_OPCACHE_VALIDATE_TIMESTAMPS=1 \
    CONF_PHP_INI_OPCACHE_MAX_ACCELERATED_FILES=20000 \
    CONF_PHP_INI_OPCACHE_MEMORY_CONSUMPTION=256 \
    CONF_PHP_INI_SESSION_SAVE_PATH='' \
    CONF_PHP_INI_SENDMAIL_PATH=''

ENV CONF_PHP_FPM_LOG_LEVEL='notice' \
    CONF_PHP_FPM_ERROR_LOG='/dev/stderr' \
    CONF_PHP_FPM_PROCESS_CONTROL_TIMEOUT='60s' \
    # www pool
    CONF_PHP_FPM_WWW_LISTEN='/var/run/php.sock' \
    CONF_PHP_FPM_WWW_PM_MAX_CHILDREN='10' \
    CONF_PHP_FPM_WWW_START_SERVERS='3' \
    CONF_PHP_FPM_WWW_MIN_SPARE_SERVERS='2' \
    CONF_PHP_FPM_WWW_MAX_SPARE_SERVERS='4' \
    CONF_PHP_FPM_WWW_PROCESS_IDLE_TIMEOUT='10s' \
    CONF_PHP_FPM_WWW_MAX_REQUESTS='500' \
    CONF_PHP_FPM_WWW_ACCESS_LOG='/dev/stdout' \
    CONF_PHP_FPM_WWW_SLOW_LOG='/dev/stdout' \
    CONF_PHP_FPM_WWW_REQUEST_SLOW_LOG_TIMEOUT='5s' \
    CONF_PHP_FPM_WWW_REQUEST_TERMINATE_TIMEOUT='60s' \
    CONF_PHP_FPM_WWW_CLEAR_ENV='no'

# xdebug
ENV CONF_PHP_XDEBUG_IDEKEY='PHPSTORM' \
    CONF_PHP_XDEBUG_REMOTE_PORT='9000' \
    CONF_PHP_XDEBUG_PROFILER_ENABLE=0 \
    CONF_PHP_XDEBUG_PROFILER_OUTPUT_DIR='/var/log/xdebug-profiler'

# composer env
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME='/etc/composer' \
    COMPOSER_VERSION='1.8.4'

# ssmtp env
ENV SSMTP_ROOT='yourmail@mail.com' \
    SSMTP_MAILHUB='mailhog:1025' \
    SSMTP_HOSTNAME='yourserver.example.com' \
    SSMTP_FROM_LINE_OVERRIDE='YES'

# scripts env
ENV SCRIPTS_ROOT_DIR='/usr/scripts'
ENV SCRIPTS_BEFORE_SECRET_DIR="$SCRIPTS_ROOT_DIR/pre-runtime" \
    SCRIPTS_AFTER_WAIT_RUNTIME_DIR="$SCRIPTS_ROOT_DIR/after-wait-for-it" \
    SCRIPTS_BEFORE_WAIT_RUNTIME_DIR="$SCRIPTS_ROOT_DIR/before-wait-for-it"

ENV PHPEXT_DEPS \
    $PHPIZE_DEPS \
    libjpeg-turbo-dev \
    imagemagick-dev \
    libmcrypt-dev \
    freetype-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libpng-dev \
    zlib-dev \
    icu-dev

RUN apk add --no-cache --virtual .persistent-ext-deps \
    # imagick
    imagemagick \
    # gd
    libjpeg-turbo \
    freetype \
    libwebp \
    libpng \
    # mcrypt
    libmcrypt \
    # soap
    libxml2 \
    # xsl
    libxslt \
    libzip \
    # intl
    icu

# install packages
RUN apk add --no-cache \
	supervisor=3.3.4-r1 \
    ca-certificates \
    nginx=1.14.2-r0 \
    busybox-extras \
    mysql-client \
    subversion \
    mercurial \
	findutils \
    binutils \
    autoconf \
    openssl \
    openssh \
    libtool \
    patch \
    ssmtp \
    tini \
    curl \
	rsync \
	wget \
    git \
	nano \
	shadow \
	dcron \
    unzip \
    mc \
    tar \
    acl

# inslall and enable extensions
RUN apk add --no-cache --virtual .ext-deps $PHPEXT_DEPS \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-webp-dir \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install --jobs "$(nproc)" \
        gd \
        mcrypt \
        zip \
        xsl \
        exif \
        pdo_mysql \
        soap \
        simplexml \
        opcache \
        bcmath \
        intl \
    && pecl install \
        xdebug-2.7.0 \
        redis-4.3.0 \
        imagick-3.4.3 \
    && docker-php-ext-enable \
        redis \
        imagick \
    && apk del .ext-deps

# add user and groups
RUN addgroup composer && usermod --append --groups www-data,nginx nginx
RUN usermod --login www-data --shell /bin/sh--append --groups composer,nginx,www-data www-data && groupmod www-data

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --no-ansi \
        --filename=composer \
        --install-dir=/usr/bin \
        --version=$COMPOSER_VERSION \
    && chmod -R 770 $COMPOSER_HOME \
    && chown -R www-data:composer $COMPOSER_HOME

# define by default php.ini production configuration
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# define by default php.ini params which can do effect on docker build
RUN { \
    echo "memory_limit = ${CONF_PHP_INI_MEMORY_LIMIT}"; \
} > $PHP_INI_DIR/conf.d/zzz-docker.ini;

# copy files
COPY $COMMON_ROOTFS_DIR/scripts/pre-runtime $SCRIPTS_BEFORE_SECRET_DIR
COPY $COMMON_ROOTFS_DIR/scripts/command/* $COMMON_ROOTFS_DIR/scripts/docker-entrypoint /usr/bin/

COPY $COMMON_ROOTFS_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
COPY $COMMON_ROOTFS_DIR/nginx/sites-enabled /etc/nginx/conf.d

COPY $COMMON_ROOTFS_DIR/supervisor/programs /etc/supervisor.programs
COPY $COMMON_ROOTFS_DIR/supervisor/supervisord.conf /etc/supervisord.conf

COPY $COMMON_ROOTFS_DIR/php/conf.d/docker-php-ext-xdebug.ini $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini

# create index.php
RUN echo '<?php phpinfo();' > "$APP_FOLDER/index.php"

# create dirs
RUN mkdir -p \
    $COMPOSER_HOME \
    $SCRIPTS_BEFORE_SECRET_DIR  \
    $SCRIPTS_AFTER_WAIT_RUNTIME_DIR  \
    $SCRIPTS_BEFORE_WAIT_RUNTIME_DIR  \
    $CONF_PHP_XDEBUG_PROFILER_OUTPUT_DIR \
    /etc/cron/periodic \
    /etc/cron/crontabs \
    /etc/cron/cronstamps

# permissions
RUN chmod +x /usr/bin/crontab
RUN chown -R www-data:www-data /usr/include

# remove not needed files.
RUN rm /usr/local/etc/php-fpm.d/docker.conf
RUN rm /usr/local/etc/php-fpm.d/zz-docker.conf

EXPOSE 80 443

STOPSIGNAL SIGTERM

WORKDIR $APP_FOLDER

HEALTHCHECK --interval=10s --timeout=10s --retries=10 --start-period=120s \
  CMD ["bash", "-c", "tallyman $TALLYMAN_NAME healthcheck"]

CMD ["docker-entrypoint", "supervisord", "-c", "/etc/supervisord.conf"]