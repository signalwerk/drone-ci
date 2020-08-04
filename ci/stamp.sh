#!/bin/bash

# replace variables in a file
# $NOW → current timestamp
# $GIT-HASH → short
# $GIT-DATE → date of last git-commit

if [ "$1" == "" ]; then
		echo "Please provide a filename as first argument"
    exit 1
fi

GIT_HASH="${DRONE_COMMIT:-$(git rev-parse --short HEAD)}"

sed -i "s#\$NOW#$(date '+%Y-%m-%d %H:%M:%S')#" $1
sed -i "s#\$GIT-HASH#$GIT_HASH#" $1
sed -i "s#\$GIT-DATE#$(git log -1 --date=format:"%Y-%m-%d %H:%M:%S" --format="%ad")#" $1
