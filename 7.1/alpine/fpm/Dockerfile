FROM php:7.1-fpm-alpine

# Arg
ARG PUID=1000
ARG PGID=1000

ARG ROOTFS_DIR="./rootfs"

# Container MODE - dev|prod
ENV MODE "prod"
# php ini
ENV PHP_DATE_TIME_ZONE "Europe/Kiev"
ENV PHP_MEMORY_LIMIT "2G"
ENV PHP_POST_MAX_SIZE "50M"
ENV PHP_MAX_INPUT_TIME 60
ENV PHP_MAX_EXECUTION_TIME 300
ENV PHP_UPLOAD_MAX_FILESIZE "50M"
ENV PHP_FILE_UPLOADS "on"
ENV PHP_SESSION_SAVE_HANDLER "files"
ENV PHP_SESSION_SAVE_PATH ""
ENV PHP_SENDMAIL_PATH ""

# php fpm
ENV PHP_FPM_LISTEN "/var/run/php.sock"

# SSMTP
ENV SSMTP_ROOT "yourmail@mail.com"
ENV SSMTP_MAILHUB "mailhog:1025"
ENV SSMTP_HOSTNAME "yourserver.example.com"
ENV SSMTP_FROM_LINE_OVERRIDE "YES"

# NGINX
ENV NGINX_HOST "localhost"
ENV NGINX_PORT "80"

# linux
#ARG LINUX_S6_OVERLAY_VERSION=v1.21.2.2

# Add repositories
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

# Install packages
RUN apk add --update --no-cache \
    icu-dev \
    libxslt-dev \
    libpng-dev \
    libmcrypt-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    freetype \
    freetype-dev \
    imagemagick-dev \
    imagemagick \
    libtool \
    git \
    mc \
    curl \
    unzip \
    mysql-client \
    ca-certificates \
    openssl \
    openssh \
    pcre-dev \
    autoconf \
	file \
	g++ \
	gcc \
	libc-dev \
	make \
	pkgconf \
	re2c \
	curl-dev \
	openssl-dev \
	dcron \
	wget \
	rsync \
	supervisor \
	shadow \
    nginx \
    ssmtp

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
        && docker-php-ext-install mcrypt zip mbstring intl xsl exif pdo_mysql soap simplexml opcache \
        && rm -rf /tmp/*

# Change user PUID and PGID
RUN usermod -u ${PUID} www-data && groupmod -g ${PGID} www-data

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# todo: install S6 and remove supervisor
#RUN curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar xfz - -C / && \

# Forward nginx request and errors logs to stdout|stderr
RUN ln -sf /proc/1/fd/1 /var/log/nginx/access.log && ln -sf /proc/1/fd/2 /var/log/nginx/error.log

# Copy files
COPY ${ROOTFS_DIR}/command /usr/bin/command

COPY ${ROOTFS_DIR}/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ${ROOTFS_DIR}/nginx/sites-enabled /etc/nginx/conf.d

COPY ${ROOTFS_DIR}/cron-jobs /var/spool/cron/crontabs
COPY ${ROOTFS_DIR}/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ${ROOTFS_DIR}/php/php-fpm.d /usr/local/etc/php-fpm.d
COPY ${ROOTFS_DIR}/php/php.ini /usr/local/etc/php/php.ini
COPY ${ROOTFS_DIR}/php/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY ${ROOTFS_DIR}/html /var/www/html

# Create dirs
RUN mkdir -p /run/nginx /var/log/supervisor/ /etc/cron/periodic /etc/cron/crontabs /etc/cron/cronstamps

# Access to cron and commands
RUN chmod +x /usr/bin/crontab && chmod -R 600 /var/spool/cron/crontabs/
RUN chown -R www-data:www-data /usr/bin/command && chmod -R +x /usr/bin/command/

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/usr/bin/command/entrypoint.sh"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=50 \
        CMD curl --fail -s http://${NGINX_HOST}:${NGINX_PORT} || exit 1

CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]