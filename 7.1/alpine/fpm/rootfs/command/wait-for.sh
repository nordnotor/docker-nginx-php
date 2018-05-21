#!/usr/bin/env bash

# Use this script to test if a given TCP host/port are available
#
# Examples:
#
# For example, let's test to see if we can access port 80 on www.google.com, and if it is available, echo the message google is up.
#
# $ ./wait-for-it.sh www.google.com:80 -- echo "google is up"
# wait-for-it.sh: waiting 15 seconds for www.google.com:80
# wait-for-it.sh: www.google.com:80 is available after 0 seconds
# google is up
#
#
# You can set your own timeout with the -t or --timeout= option. Setting the timeout value to 0 will disable the timeout:
#
# $ ./wait-for-it.sh -t 0 www.google.com:80 -- echo "google is up"
# wait-for-it.sh: waiting for www.google.com:80 without a timeout
# wait-for-it.sh: www.google.com:80 is available after 0 seconds
# google is up
#
#
# The subcommand will be executed regardless if the service is up or not. If you wish to execute the subcommand only if the service is up, add the --strict argument. In this example, we will test port 81 on www.google.com which will fail:
#
# $ ./wait-for-it.sh www.google.com:81 --timeout=1 --strict -- echo "google is up"
# wait-for-it.sh: waiting 1 seconds for www.google.com:81
# wait-for-it.sh: timeout occurred after waiting 1 seconds for www.google.com:81
# wait-for-it.sh: strict mode, refusing to execute subprocess
#
#
# If you don't want to execute a subcommand, leave off the -- argument. This way, you can test the exit condition of wait-for-it.sh in your own scripts, and determine how to proceed:
#
# $ ./wait-for-it.sh www.google.com:80
# wait-for-it.sh: waiting 15 seconds for www.google.com:80
# wait-for-it.sh: www.google.com:80 is available after 0 seconds
# $ echo $?
# 0
# $ ./wait-for-it.sh www.google.com:81
# wait-for-it.sh: waiting 15 seconds for www.google.com:81
# wait-for-it.sh: timeout occurred after waiting 15 seconds for www.google.com:81
# $ echo $?
# 124

cmdname=$(basename $0)

echoerr() { if [[ $QUIET -ne 1 ]]; then echo "$@" 1>&2; fi }

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname host:port [-s] [-t timeout] [-- command args]
    -h HOST | --host=HOST       Host or IP under test
    -p PORT | --port=PORT       TCP port under test
                                Alternatively, you specify the host and port as host:port
    -s | --strict               Only execute subcommand if the test succeeds
    -q | --quiet                Don't output any status messages
    -t TIMEOUT | --timeout=TIMEOUT
                                Timeout in seconds, zero for no timeout
    -- COMMAND ARGS             Execute command with args after the test finishes
USAGE
    exit 1
}

wait_for()
{
    if [[ $TIMEOUT -gt 0 ]]; then
        echoerr "$cmdname: waiting $TIMEOUT seconds for $HOST:$PORT"
    else
        echoerr "$cmdname: waiting for $HOST:$PORT without a timeout"
    fi
    start_ts=$(date +%s)
    while :
    do
        if [[ $ISBUSY -eq 1 ]]; then
            nc -z $HOST $PORT
            result=$?
        else
            (echo > /dev/tcp/$HOST/$PORT) >/dev/null 2>&1
            result=$?
        fi
        if [[ $result -eq 0 ]]; then
            end_ts=$(date +%s)
            echoerr "$cmdname: $HOST:$PORT is available after $((end_ts - start_ts)) seconds"
            break
        fi
        sleep 1
    done
    return $result
}

wait_for_wrapper()
{
    # In order to support SIGINT during timeout: http://unix.stackexchange.com/a/57692
    if [[ $QUIET -eq 1 ]]; then
        timeout $BUSYTIMEFLAG $TIMEOUT $0 --quiet --child --host=$HOST --port=$PORT --timeout=$TIMEOUT &
    else
        timeout $BUSYTIMEFLAG $TIMEOUT $0 --child --host=$HOST --port=$PORT --timeout=$TIMEOUT &
    fi
    PID=$!
    trap "kill -INT -$PID" INT
    wait $PID
    RESULT=$?
    if [[ $RESULT -ne 0 ]]; then
        echoerr "$cmdname: timeout occurred after waiting $TIMEOUT seconds for $HOST:$PORT"
    fi
    return $RESULT
}

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        *:* )
        hostport=(${1//:/ })
        HOST=${hostport[0]}
        PORT=${hostport[1]}
        shift 1
        ;;
        --child)
        CHILD=1
        shift 1
        ;;
        -q | --quiet)
        QUIET=1
        shift 1
        ;;
        -s | --strict)
        STRICT=1
        shift 1
        ;;
        -h)
        HOST="$2"
        if [[ $HOST == "" ]]; then break; fi
        shift 2
        ;;
        --host=*)
        HOST="${1#*=}"
        shift 1
        ;;
        -p)
        PORT="$2"
        if [[ $PORT == "" ]]; then break; fi
        shift 2
        ;;
        --port=*)
        PORT="${1#*=}"
        shift 1
        ;;
        -t)
        TIMEOUT="$2"
        if [[ $TIMEOUT == "" ]]; then break; fi
        shift 2
        ;;
        --timeout=*)
        TIMEOUT="${1#*=}"
        shift 1
        ;;
        --)
        shift
        CLI=("$@")
        break
        ;;
        --help)
        usage
        ;;
        *)
        echoerr "Unknown argument: $1"
        usage
        ;;
    esac
done

if [[ "$HOST" == "" || "$PORT" == "" ]]; then
    echoerr "Error: you need to provide a host and port to test."
    usage
fi

TIMEOUT=${TIMEOUT:-15}
STRICT=${STRICT:-0}
CHILD=${CHILD:-0}
QUIET=${QUIET:-0}

# check to see if timeout is from busybox?
# check to see if timeout is from busybox?
TIMEOUT_PATH=$(realpath $(which timeout))
if [[ $TIMEOUT_PATH =~ "busybox" ]]; then
        ISBUSY=1
        BUSYTIMEFLAG="-t"
else
        ISBUSY=0
        BUSYTIMEFLAG=""
fi

if [[ $CHILD -gt 0 ]]; then
    wait_for
    RESULT=$?
    exit $RESULT
else
    if [[ $TIMEOUT -gt 0 ]]; then
        wait_for_wrapper
        RESULT=$?
    else
        wait_for
        RESULT=$?
    fi
fi

if [[ $CLI != "" ]]; then
    if [[ $RESULT -ne 0 && $STRICT -eq 1 ]]; then
        echoerr "$cmdname: strict mode, refusing to execute subprocess"
        exit $RESULT
    fi
    exec "${CLI[@]}"
else
    exit $RESULT
fi