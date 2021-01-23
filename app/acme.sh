#!/usr/bin/env bash

export CA_HOME="/etc/nginx/certs/_acme.sh-ca"
source /etc/acme.sh/home/acme.sh.env
exec /etc/acme.sh/home/acme.sh \
  --config-home '/etc/acme.sh/config' \
  --debug \
  "$@"
