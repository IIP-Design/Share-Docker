#!/bin/bash
set -e

find . -name .git -prune -o -print0 | xargs -0 chown www-data:www-data

exec "$@"
