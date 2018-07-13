#!/bin/bash

usage()
{
    cat <<-END
    Get secret from file.

    Usage:
      secret_env ENV_NAME

      Will allow for "$ENV_NAME_FILE" to fill in the value of "$ENV_NAME" from a file, especially for Docker's secrets feature.

END
}

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

main() {

    case $1 in
        --help) usage; ;;
        *) file_env $* ;;
    esac
}

main $*;