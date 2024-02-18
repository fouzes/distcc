#!/bin/sh
set -e

source /etc/profile

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    exec distccd --daemon --no-detach --log-level notice --log-stderr --allow-private "$@"
fi

exec "$@"
