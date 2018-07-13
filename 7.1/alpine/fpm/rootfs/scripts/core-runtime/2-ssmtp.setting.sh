#!/bin/bash

# Set ssmtp conf
echo "root=${SSMTP_ROOT}" > /etc/ssmtp/ssmtp.conf
echo "mailhub=${SSMTP_MAILHUB}" >> /etc/ssmtp/ssmtp.conf
echo "hostname=${SSMTP_HOSTNAME}" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=${SSMTP_FROM_LINE_OVERRIDE}" >> /etc/ssmtp/ssmtp.conf