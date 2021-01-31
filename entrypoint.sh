#!/bin/sh

if [ -n "${MKNOD}" ]; then
    mknod ${MKNOD}
fi

exec /usr/local/bin/octoprint "$@"
