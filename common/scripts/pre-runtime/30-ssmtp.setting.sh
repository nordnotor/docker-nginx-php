#!/bin/bash

# ssmtp conf
{ \
    echo "root=${SSMTP_ROOT}"; \
    echo "mailhub=${SSMTP_MAILHUB}"; \
    echo "hostname=${SSMTP_HOSTNAME}"; \
    echo "FromLineOverride=${SSMTP_FROM_LINE_OVERRIDE}"; \
} > /etc/ssmtp/ssmtp.conf