FROM php:7.1-fpm-alpine3.7

MAINTAINER Vlad Tuznichenko <vlad.tuznichenko@gmail.com>

# Arg
ARG ROOTFS_DIR="./rootfs"

# Container env
ENV PUID=1000 \
    PGID=1000 \
    MODE="prod" \
    WAIT_FOR="" \
    SECRET_ENV=""

# Php env
ENV PHP_FILE_UPLOADS="on"  \
    PHP_MEMORY_LIMIT="2G" \
    PHP_POST_MAX_SIZE="50M" \
    PHP_UPLOAD_MAX_FILESIZE="50M" \
    PHP_MAX_INPUT_TIME=60 \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_DATE_TIME_ZONE="Europe/Kiev" \
    PHP_SESSION_SAVE_HANDLER="files" \
    PHP_SESSION_SAVE_PATH="" \
    PHP_SENDMAIL_PATH="" \
    PHP_FPM_LISTEN="/var/run/php.sock"

# Composer env
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/etc/composer \
    COMPOSER_VERSION=1.6.5

# Ssmtp env
ENV SSMTP_ROOT="yourmail@mail.com" \
    SSMTP_MAILHUB="mailhog:1025" \
    SSMTP_HOSTNAME="yourserver.example.com" \
    SSMTP_FROM_LINE_OVERRIDE="YES"

# Scripts env
ENV SCRIPTS_ROOT_DIR='/usr/scripts'
ENV SCRIPTS_CORE_RUNTIME_DIR="$SCRIPTS_ROOT_DIR/core-runtime" \
    SCRIPTS_AFTER_WAIT_RUNTIME_DIR="$SCRIPTS_ROOT_DIR/after-wait-for-it" \
    SCRIPTS_BEFORE_WAIT_RUNTIME_DIR="$SCRIPTS_ROOT_DIR/before-wait-for-it"

# Add repositories
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

# Install packages
RUN apk add --update --no-cache \
    libjpeg-turbo-dev \
    ca-certificates \
    imagemagick-dev \
    libmcrypt-dev \
    libjpeg-turbo \
    mysql-client \
    freetype-dev \
    libxslt-dev \
    imagemagick \
	openssl-dev \
    libpng-dev \
    subversion \
	supervisor \
    mercurial \
	findutils \
	libc-dev \
    freetype \
    autoconf \
    pcre-dev \
	curl-dev \
	pkgconf \
    openssh \
    openssl \
    icu-dev \
    libtool \
	shadow \
	dcron \
	rsync \
    nginx \
    unzip \
    patch \
    ssmtp \
    tini \
    curl \
	file \
	make \
	re2c \
	wget \
    git \
	g++ \
	gcc \
    tar \
    mc

# Install gd
RUN docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
  && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
  && docker-php-ext-install -j${NPROC} gd \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# Inslall and enable other extensions
RUN docker-php-source extract \
        && pecl install gd mcrypt xdebug redis imagick \
        && docker-php-ext-enable imagick redis xdebug \
        && docker-php-source delete \
        && docker-php-ext-install mcrypt zip mbstring intl xsl exif pdo_mysql soap simplexml opcache bcmath \
        && rm -rf /tmp/*

# Install composer
RUN apk add --no-cache --virtual .build-deps zlib-dev \
 && runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
 && apk add --virtual .composer-phpext-rundeps $runDeps && apk del .build-deps

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/b107d959a5924af895807021fcef4ffec5a76aa9/web/installer \
 && php -r " \
    \$signature = '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -rf /tmp/* /tmp/.htaccess

# Add user and groups
RUN addgroup -g 1001 composer && usermod --append --groups www-data,nginx nginx
RUN usermod --uid ${PUID} --shell /bin/sh --append --groups composer,nginx,www-data www-data && groupmod --gid ${PGID} www-data

# Add stderr|stdout for nginx logs
RUN ln -sf /proc/1/fd/2 /var/log/nginx/error.log
RUN ln -sf /proc/1/fd/1 /var/log/nginx/access.log

# Copy files
COPY ${ROOTFS_DIR}/scripts/command /usr/bin/command
COPY ${ROOTFS_DIR}/scripts/entrypoint.sh /usr/bin/entrypoint
COPY ${ROOTFS_DIR}/scripts/core-runtime $SCRIPTS_CORE_RUNTIME_DIR

COPY ${ROOTFS_DIR}/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ${ROOTFS_DIR}/nginx/sites-enabled /etc/nginx/conf.d

COPY ${ROOTFS_DIR}/cron-jobs /var/spool/cron/crontabs

COPY ${ROOTFS_DIR}/supervisor/programs /etc/supervisor.programs
COPY ${ROOTFS_DIR}/supervisor/supervisord.conf /etc/supervisord.conf

COPY ${ROOTFS_DIR}/php/php-fpm.d /usr/local/etc/php-fpm.d
COPY ${ROOTFS_DIR}/php/php.ini /usr/local/etc/php/php.ini
COPY ${ROOTFS_DIR}/php/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY ${ROOTFS_DIR}/html /var/www/html

# Create dirs
RUN mkdir -p $SCRIPTS_CORE_RUNTIME_DIR $SCRIPTS_AFTER_WAIT_RUNTIME_DIR $SCRIPTS_BEFORE_WAIT_RUNTIME_DIR
RUN mkdir -p /run/nginx /var/log/supervisor/ /etc/cron/periodic /etc/cron/crontabs /etc/cron/cronstamps /etc/supervisor.programs /etc/composer

# Add commands
RUN ln -s /usr/bin/command/phpmod.sh /usr/bin/phpmod
RUN ln -s /usr/bin/command/wait-for.sh /usr/bin/wait-for
RUN ln -s /usr/bin/command/secret-env.sh /usr/bin/secret-env

# Permission
RUN chmod -R 770 $COMPOSER_HOME
RUN chown -R root:composer $COMPOSER_HOME
RUN chmod -R 600 /var/spool/cron/crontabs/
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R +x /usr/bin/command /usr/bin/crontab /usr/bin/entrypoint

WORKDIR /var/www/html

EXPOSE 80 443 9000

ENTRYPOINT ["/usr/bin/entrypoint"]

CMD ["supervisord"]