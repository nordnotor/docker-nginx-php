#!/bin/bash

## php.ini
ZZZ_PHP_INI_CONF_PATH=${ZZZ_PHP_INI_CONF_PATH:-${PHP_INI_DIR}/conf.d/zzz-docker.ini}
ZZZ_WWW_PHP_FPM_CONF_PATH=${ZZZ_WWW_PHP_FPM_CONF_PATH:-/usr/local/etc/php-fpm.d/zzz-www-docker.conf}

{ \
    echo -e "\n; Override default config"; \
    echo "expose_php = Off"; \
    echo "max_input_time = ${CONF_PHP_INI_MAX_INPUT_TIME}"; \
    echo "max_execution_time = ${CONF_PHP_INI_MAX_EXECUTION_TIME}"; \
    echo "memory_limit = ${CONF_PHP_INI_MEMORY_LIMIT}"; \
    echo "file_uploads = ${CONF_PHP_INI_FILE_UPLOADS}"; \
    echo "post_max_size = ${CONF_PHP_INI_POST_MAX_SIZE}"; \
    echo "upload_max_filesize = ${CONF_PHP_INI_UPLOAD_MAX_FILESIZE}"; \
    echo "date.timezone = ${CONF_PHP_INI_TIMEZONE}"; \
    echo "error_log = ${CONF_PHP_INI_ERROR_LOG}"; \
    echo "session.save_handler = ${CONF_PHP_INI_SESSION_SAVE_HANDLER}"; \
    echo "realpath_cache_ttl = ${CONF_PHP_INI_REALPATH_CACHE_TTL}"; \
    echo "realpath_cache_size = ${CONF_PHP_INI_REALPATH_CACHE_SIZE}"; \
    echo "mail.log = ${CONF_PHP_INI_MAIL_LOG}"; \
    echo "mail.add_x_header = ${CONF_PHP_INI_MAIL_ADD_X_HEADER}"; \
    echo "opcache.validate_timestamps = ${CONF_PHP_INI_OPCACHE_VALIDATE_TIMESTAMPS}"; \
    echo "opcache.max_accelerated_files = ${CONF_PHP_INI_OPCACHE_MAX_ACCELERATED_FILES}"; \
    echo "opcache.memory_consumption = ${CONF_PHP_INI_OPCACHE_MEMORY_CONSUMPTION}"; \
} > ${ZZZ_PHP_INI_CONF_PATH};

if [[ -n ${CONF_PHP_INI_SENDMAIL_PATH} ]]; then
    echo "sendmail_path = \"${CONF_PHP_INI_SENDMAIL_PATH}\"" >>  ${PHP_INI_CONF_PATH};
fi

if [[ -n ${CONF_PHP_INI_SESSION_SAVE_PATH} ]]; then
    echo "session.save_path = \"${CONF_PHP_INI_SESSION_SAVE_PATH}\"" >> ${PHP_INI_CONF_PATH};
fi

# php-fpm.conf
{ \
    echo -e "\n; Override default config"; \
    echo "[global]"; \
    echo "daemonize = no"; \
    echo "log_level = ${CONF_PHP_FPM_LOG_LEVEL}"; \
    echo "error_log = ${CONF_PHP_FPM_ERROR_LOG}"; \
    echo "process_control_timeout = ${CONF_PHP_FPM_PROCESS_CONTROL_TIMEOUT}"; \
    echo "[www]"; \
    echo "listen.mode = 0660"; \
    echo "listen.owner = www-data"; \
    echo "listen.group = www-data"; \
    echo "catch_workers_output = yes"; \
    echo "listen = ${CONF_PHP_FPM_WWW_LISTEN}"; \
    echo "pm.max_children = ${CONF_PHP_FPM_WWW_PM_MAX_CHILDREN}"; \
    echo "pm.start_servers = ${CONF_PHP_FPM_WWW_START_SERVERS}"; \
    echo "pm.min_spare_servers = ${CONF_PHP_FPM_WWW_MIN_SPARE_SERVERS}"; \
    echo "pm.max_spare_servers = ${CONF_PHP_FPM_WWW_MAX_SPARE_SERVERS}"; \
    echo "pm.process_idle_timeout = ${CONF_PHP_FPM_WWW_PROCESS_IDLE_TIMEOUT}"; \
    echo "pm.max_requests = ${CONF_PHP_FPM_WWW_MAX_REQUESTS}"; \
    echo "access.log = ${CONF_PHP_FPM_WWW_ACCESS_LOG}"; \
    echo "slowlog = ${CONF_PHP_FPM_WWW_SLOW_LOG}"; \
    echo "request_slowlog_timeout = ${CONF_PHP_FPM_WWW_REQUEST_SLOW_LOG_TIMEOUT}"; \
    echo "request_terminate_timeout = ${CONF_PHP_FPM_WWW_REQUEST_TERMINATE_TIMEOUT}"; \
    echo "clear_env = ${CONF_PHP_FPM_WWW_CLEAR_ENV}"; \
} > ${ZZZ_WWW_PHP_FPM_CONF_PATH}

