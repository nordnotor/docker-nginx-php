#!/bin/bash

set -euo pipefail

if [ ${MODE} = "dev" ]; then
    set -x
fi

function runScripts(){

    local dir=$1

    if [ ! -d ${dir} ]; then
       echo >&2 " => error: directory ${dir} does not exists.";
       exit 1;
    fi

    for script in `find ${dir} -type f -name "*.sh" | sort`; do :
       . ${script}
    done
}

# Change user PUID and PGID
usermod -u ${PUID} -s /bin/sh www-data 2> /dev/null && groupmod -g ${PGID} www-data 2> /dev/null || true

# Access
chown -R root:root ${SCRIPTS_ROOT_DIR} && chmod -R +x ${SCRIPTS_ROOT_DIR}

# Run core scripts...
runScripts ${SCRIPTS_CORE_RUNTIME_DIR}

# Replace env with secrets...
for secret in ${SECRET_ENV}; do
    . secret-env ${secret}
done

# Run scripts before waiting...
runScripts ${SCRIPTS_BEFORE_WAIT_RUNTIME_DIR}

# Waiting for services...
for host in ${WAIT_FOR}; do
    wait-for -t 0 ${host}
done

# Run scripts after waiting...
runScripts ${SCRIPTS_AFTER_WAIT_RUNTIME_DIR}

exec "$@"