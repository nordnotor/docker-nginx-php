#!/bin/bash

set -euo pipefail

if [ ${MODE} == "dev" ]; then
    set -x
fi

if [ ! `id -un` == "root" ]; then
    echo >&2 " => error: Please run container only by root user!" && retutn 1;
fi

function runScripts(){
    local _dir=$1

    if [ ! -d ${_dir} ]; then
       echo >&2 " => error: directory ${_dir} does not exists."; retutn 1;
    fi

    for script in `find ${_dir} -type f -name "*.sh" | sort`; do :
       . ${script}
    done
}

# Change user UID/GID and UID/GID in files.

OGID=`id -g www-data`
if [ ${PGID} -ne ${OGID} ]; then
    groupmod -g ${PGID} www-data | (find / -group ${OGID} -print 2> /dev/null; exit 0) | xargs chown -R :${PGID} || true
fi

OUID=`id -u www-data`
if [ ${PUID} -ne ${OUID} ]; then
     usermod -u ${PUID} www-data | (find / -user ${OUID} -print 2> /dev/null; exit 0) | xargs chown -R ${PGID} || true
fi

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