#!/bin/bash

usage()
{
    cat <<-END
    Turns on or off php extension.

    Usage:
      phpmod disable|enable extension-name

END
}

switch(){

    local command=$1
    local extension=$2
    local phpConfFolder=`php --ini | grep "Scan for additional .ini files in:" | cut -c 35- | xargs`

    if [ ! -f ${phpConfFolder}/docker-php-ext-${2}.ini ]; then
        echo  >&2 " => error: $2 extension does not installed." && exit 1;
    fi

    local isExtension=`grep -c "^;zend_extension=$2.so" ${phpConfFolder}/docker-php-ext-${2}.ini`

    if [ ! ${isExtension} -ge 1 ] && [ $1 == 'enable' ]; then
        echo " => $2 already $1.";
        exit 0;
    fi

    if [ ${isExtension} -ge 1 ]  && [ $1 == 'disable' ]; then
        echo " => $2 already $1.";
        exit 0;
    fi

    case $1 in
        --help)  usage; ;;
        enable)  sed -i "s/;zend_extension=$2.so/zend_extension=$2.so/" ${phpConfFolder}/docker-php-ext-${2}.ini ;;
        disable) sed -i "s/zend_extension=$2.so/;zend_extension=$2.so/" ${phpConfFolder}/docker-php-ext-${2}.ini ;;
    esac

    supervisorctl restart php > /dev/null

    echo -e " => php extension $2 has $1.";
}

function main {

    case $1 in
        --help)  usage; ;;
        enable)  switch $* ;;
        disable) switch $* ;;
        *) echo >&2 " => error: unknown command: $1"; exit 1 ;;
    esac
}

main $*;