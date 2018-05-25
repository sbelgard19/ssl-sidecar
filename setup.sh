#!/bin/bash

# Usage:
#
# ssl_setup <domain/commonName> [--self]
#
# This script is used to generate key and CSR for use HTTPS in Nginx.
# 
# Example Environment 
#
# SELF_SIGN="true"
# DOMAIN="www.example.com"
# COUNTRY="US"
# STATE="Washington"
# LOCALITY="Seattle"
# ORGANIZATION="Microsoft"
# ORGANIZATIONAL_UNIT="Azure"


if [[ -z "${UPSTREAM_PORT}" ]]; then
    echo "UPSTREAM_PORT not set"
    exit 1
fi

export DOLLAR="$"

#Replace env variables with correct ones
envsubst < nginx.conf.template > /etc/nginx/nginx.conf

if [ "${SELF_SIGN}" != "true" ]; then
    echo "Not generating certificate"
    exit 0
fi
 
if [[ -z "${DOMAIN}" ]]; then
    echo "DOMAIN not set"
    exit 1
fi

if [[ -z "${COUNTRY}" ]]; then
    echo "COUNTRY not set"
    exit 1
fi

if [[ -z "${STATE}" ]]; then
    echo "STATE not set"
    exit 1
fi

if [[ -z "${LOCALITY}" ]]; then
    echo "LOCALITY not set"
    exit 1
fi

if [[ -z "${ORGANIZATION}" ]]; then
    echo "ORGANIZATION not set"
    exit 1
fi

if [[ -z "${ORGANIZATIONAL_UNIT}" ]]; then
    echo "ORGANIZATIONAL_UNIT not set"
    exit 1
fi


KEY_NAME="ssl"

KEY_PATH="/etc/nginx/ssl.key"
CRT_PATH="/etc/nginx/ssl.crt"
CSR_PATH="/ssl.csr"

openssl req -new -newkey rsa:2048 -nodes -keyout ${KEY_PATH} -out ${CSR_PATH} \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${DOMAIN}"

echo "Created ${KEY_PATH}"
echo "Created ${CSR_PATH}"

if [[ -n $SELF_SIGN ]]; then
  openssl x509 -req -days 365 -in ${CSR_PATH} -signkey ${KEY_PATH} -out ${CRT_PATH}
  echo "Created ${CRT_PATH} (self-signed)"
fi