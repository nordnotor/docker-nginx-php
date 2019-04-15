## What is this?

This repository contains the php docker images php and nginx in one container which extend official php image.

## What do you mean by "Official"?
Docker, Inc. sponsors a dedicated team that is responsible for reviewing and publishing all content in the Official Images. This team works in collaboration with upstream software maintainers, security experts, and the broader Docker community.
 
# What is PHP?

PHP is a server-side scripting language designed for web development, but which can also be used as a general-purpose programming language. PHP can be added to straight HTML or it can be used with a variety of templating engines and web frameworks. PHP code is usually processed by an interpreter, which is either implemented as a native module on the web-server or as a common gateway interface (CGI).

> [wikipedia.org/wiki/PHP](http://en.wikipedia.org/wiki/PHP)

![logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/php/logo.png)

# How to use this image

### Create a `Dockerfile` in your PHP project

```dockerfile
FROM php:7.2-cli
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
CMD [ "php", "./your-script.php" ]
```

Then, run the commands to build and run the Docker image:

```console
$ docker build -t my-php-app .
$ docker run -it --rm --name my-running-app my-php-app
```

### Run a single PHP script

For many simple, single file projects, you may find it inconvenient to write a complete `Dockerfile`. In such cases, you can run a PHP script by using the PHP Docker image directly:

```console
$ docker run -it --rm --name my-running-script -v "$PWD":/usr/src/myapp -w /usr/src/myapp php:7.2-cli php your-script.php
```



### Overview

```text
container
└── supervisor
    └── processes
        ├── cron
        │   └── logs -> syslog
        └── supervisor
            ├── logs -> stdout | stderr
            └── programs
                ├── nginx
                │   └── logs -> syslog
                ├── php
                │   └── logs -> syslog
                └── rsyslog
                    └── logs -> stdout | stderr
```
`Notice`: rsyslog can send logs not only to `stdout` | `stderr` see [modules](https://www.rsyslog.com/doc/v8-stable/configuration/modules/idx_output.html)

#### Rsyslog default process facility:
```text
local0 - nginx
local1 - php
local2 - cron
local3 - mail
```

### Mode

To enable mode for local development you need define `MODE` and `MODE_XDEBUG` in container env.

Example:
```bash
    MODE: "dev" - add groups :www-data to `APP_FOLDER` files and replase php.ini for development.
    MODE_XDEBUG: 'on' - enable xdebug before start container
```
`Notice:` By default this options are disabled. Also, any other values will be considered as prod mode.

### Cron

You can add cron jobs by `crontab` in `dockerfile`.
```dockerfile
USER www-data
RUN echo -e " \
 * * * * *  php $APP_FOLDER/bin/console run > /proc/1/fd/1 2>/proc/1/fd/2 \n \
\
" | crontab -
USER root
```

### Xdebug

Xdebug configs by default:
 - `idekey` is `PHPSTORM`
 - `remote_port` is `9000`

Enable
```bash
docker-php-ext-enable xdebug
supervisorctl restart php

```

Disable
```bash
docker-php-ext-enable xdebug
supervisorctl restart php
```

### Health check

Default configuration for health check is:
```dockerfile
HEALTHCHECK --interval=10s --timeout=10s --retries=10 --start-period=120s \
  CMD ["bash", "-c", "tallyman $TALLYMAN_NAME healthcheck"]
```

`/usr/bin/healthcheck`
```bash
curl -f localhost
```

You can rewrite default health check by adding line in docker file:
```dockerfile
RUN echo 'curl --fail -s localhost/health_check.php' > healthcheck
```


## How to install more PHP extensions

Many extensions are already compiled into the image, so it's worth checking the output of `php -m` or `php -i` before going through the effort of compiling more.

We provide the helper scripts `docker-php-ext-configure`, `docker-php-ext-install`, and `docker-php-ext-enable` to more easily install PHP extensions.

In order to keep the images smaller, PHP's source is kept in a compressed tar file. To facilitate linking of PHP's source with any extension, we also provide the helper script `docker-php-source` to easily extract the tar or delete the extracted source. Note: if you do use `docker-php-source` to extract the source, be sure to delete it in the same layer of the docker image.

```Dockerfile
FROM php:7.2-cli
RUN docker-php-source extract \
	# do important things \
	&& docker-php-source delete
```

### PHP Core Extensions

For example, if you want to have a PHP-FPM image with `iconv` and `gd` extensions, you can inherit the base image that you like, and write your own `Dockerfile` like this:

```dockerfile
FROM php:7.2-fpm
RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-install -j$(nproc) iconv \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd
```

Remember, you must install dependencies for your extensions manually. If an extension needs custom `configure` arguments, you can use the `docker-php-ext-configure` script like this example. There is no need to run `docker-php-source` manually in this case, since that is handled by the `configure` and `install` scripts.

See ["Dockerizing Compiled Software"](https://tianon.xyz/post/2017/12/26/dockerize-compiled-software.html) for a description of the technique Tianon uses for determining the necessary build-time dependencies for any bit of software (which applies directly to compiling PHP extensions).

### PECL extensions

Some extensions are not provided with the PHP source, but are instead available through [PECL](https://pecl.php.net/). To install a PECL extension, use `pecl install` to download and compile it, then use `docker-php-ext-enable` to enable it:

```dockerfile
FROM php:7.2-cli
RUN pecl install redis-4.0.1 \
	&& pecl install xdebug-2.6.0 \
	&& docker-php-ext-enable redis xdebug
```

```dockerfile
FROM php:5.6-cli
RUN apt-get update && apt-get install -y libmemcached-dev zlib1g-dev \
	&& pecl install memcached-2.2.0 \
	&& docker-php-ext-enable memcached
```

It is *strongly* recommended that users use an explicit version number in their `pecl install` invocations to ensure proper PHP version compatibility (PECL does not check the PHP version compatiblity when choosing a version of the extension to install, but does when trying to install it).

For example, `memcached-2.2.0` has no PHP version constraints (https://pecl.php.net/package/memcached/2.2.0), but `memcached-3.0.4` requires PHP 7.0.0 or newer (https://pecl.php.net/package/memcached/3.0.4). When doing `pecl install memcached` (no specific version) on PHP 5.6, PECL will try to install the latest release and fail.

Beyond the compatibility issue, it's also a good practice to ensure you know when your dependencies receive updates and can control those updates directly.

Unlike PHP core extensions, PECL extensions should be installed in series to fail properly if something went wrong. Otherwise errors are just skipped by PECL. For example, `pecl install memcached-2.2.0 && pecl install redis-2.2.8` instead of `pecl install memcached-2.2.0 redis-2.2.8`. However, `docker-php-ext-enable memcached redis` is fine to be all in one command.

### Other extensions

Some extensions are not provided via either Core or PECL; these can be installed too, although the process is less automated:

```dockerfile
FROM php:5.6-cli
RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
	&& mkdir -p xcache \
	&& tar -xf xcache.tar.gz -C xcache --strip-components=1 \
	&& rm xcache.tar.gz \
	&& ( \
		cd xcache \
		&& phpize \
		&& ./configure --enable-xcache \
		&& make -j "$(nproc)" \
		&& make install \
	) \
	&& rm -r xcache \
	&& docker-php-ext-enable xcache
```

The `docker-php-ext-*` scripts *can* accept an arbitrary path, but it must be absolute (to disambiguate from built-in extension names), so the above example could also be written as the following:

```dockerfile
FROM php:5.6-cli
RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
	&& mkdir -p /tmp/xcache \
	&& tar -xf xcache.tar.gz -C /tmp/xcache --strip-components=1 \
	&& rm xcache.tar.gz \
	&& docker-php-ext-configure /tmp/xcache --enable-xcache \
	&& docker-php-ext-install /tmp/xcache \
	&& rm -r /tmp/xcache
```

# Image Variants

## Schema: `php:<php-version>-<fpm|cli>-<os-version>-<image-version>`

## fpm

This variant contains PHP-FPM, which is a FastCGI implementation for PHP. See [the PHP-FPM website](https://php-fpm.org/) for more information about PHP-FPM.

In order to use this image variant, some kind of reverse proxy (such as NGINX, Apache, or other tool which speaks the FastCGI protocol) will be required.

Some potentially helpful resources:

-	[PHP-FPM.org](https://php-fpm.org/)
-	[simplified example by @md5](https://gist.github.com/md5/d9206eacb5a0ff5d6be0)
-	[very detailed article by Pascal Landau](https://www.pascallandau.com/blog/php-php-fpm-and-nginx-on-docker-in-windows-10/)
-	[Stack Overflow discussion](https://stackoverflow.com/q/29905953/433558)
-	[Apache httpd Wiki example](https://wiki.apache.org/httpd/PHPFPMWordpress)

## alpine

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).
