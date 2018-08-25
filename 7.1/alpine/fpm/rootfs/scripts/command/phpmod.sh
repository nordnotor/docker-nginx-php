#!/bin/bash

usage() {
    cat <<-END
    Turns on or off php extension.

    Usage:
      phpmod disable|enable extension-name

END
}

switch() {

    local _command=$1 _extension=$2 _phpConfFolder=`php --ini | grep "Scan for additional .ini files in:" | cut -c 35- | xargs`

    if [ ! -f ${_phpConfFolder}/docker-php-ext-${_extension}.ini ]; then
        echo  >&2 " => error: ${_extension} extension does not installed." && exit 1;
    fi

    local isExtension=`grep -c "^;zend_extension=${_extension}.so" ${_phpConfFolder}/docker-php-ext-${_extension}.ini`

    if [ ! ${isExtension} -ge 1 ] && [ $1 == 'enable' ]; then
        echo " => ${_extension} already ${_command}.";
        exit 0;
    fi

    if [ ${isExtension} -ge 1 ]  && [ $1 == 'disable' ]; then
        echo " => ${_extension} already ${_command} .";
        exit 0;
    fi

    case ${_command} in
        enable)  sed -i "s/;zend_extension=${_extension}.so/zend_extension=${_extension}.so/" ${_phpConfFolder}/docker-php-ext-${_extension}.ini ;;
        disable) sed -i "s/zend_extension=${_extension}.so/;zend_extension=${_extension}.so/" ${_phpConfFolder}/docker-php-ext-${_extension}.ini ;;
    esac

    supervisorctl restart php > /dev/null

    echo -e " => php extension ${_extension} has ${_command}.";
}

function main {
    case $1 in
        -h | --help)  usage; ;;
        enable | disable)  switch $* ;;
        *) echo >&2 " => error: unknown command: $1"; exit 1 ;;
    esac
}

main $*;