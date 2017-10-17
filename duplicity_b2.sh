#!/usr/bin/env bash

INCLUDE_LIST='/etc/akademiano/backuper/include.list'
EXCLUDE_LIST='/etc/akademiano/backuper/exclude.list'

### --- BEGIN SCRIPT ----
while [ -n "$1" ]
do
    case "$1" in
        -p | --passphrase ) shift
                      passphrase="$1"
                      shift
            ;;
        -d | --dir  ) shift
                      preparedDir="$1"
                      shift
            ;;
        -c | --cache  ) shift
                      cache="$1"
                      shift
            ;;
        -i | --id  ) shift
                      id="$1"
                      shift
            ;;
        -k | --key  ) shift
                      key="$1"
                      shift
            ;;
        -n | --name  ) shift
                      name="$1"
                      shift
            ;;
        * ) printf "Invalid option $1\n"
            exit 1
    esac
done

fail=0
if [ -z "$passphrase" ]
then
    printf "Please provide a passphrase with -p\n"
    fail=1
fi

if [ -z "$id" ]
then
    printf "Please provide a id with -d\n"
    fail=1
fi
if [ -z "$key" ]
then
    printf "Please provide a key with -k\n"
    fail=1
fi
if [ -z "$name" ]
then
    printf "Please provide a name with -n\n"
    fail=1
fi

if [ -z "$preparedDir" ]
then
    printf "Please provide a preparedDir with -d\n"
    fail=1
fi

if [ "$fail" -eq 1 ]
then
    printf "Exiting, please re-run with requested options\n"
    exit 1
fi

if [ -z "$cache" ]
then
    cache="/var/cache/duplicity"
fi

if [ -f "$INCLUDE_LIST" ]; then
    INCLUDE_OPT=" --include-filelist $INCLUDE_LIST "
else
    INCLUDE_OPT=" "
fi

if [ -f "$EXCLUDE_LIST" ]; then
    EXCLUDE_OPT=" --exclude-filelist $EXCLUDE_LIST "
else
    EXCLUDE_OPT=" "
fi


PASSPHRASE="$passphrase" duplicity  \
--allow-source-mismatch  \
--volsize=1000 \
--asynchronous-upload \
--timeout 180  -v8  \
--full-if-older-than 7D \
--extra-clean \
--archive-dir "$cache"  \
--include "$preparedDir" \
$INCLUDE_OPT \
--exclude '**' \
$EXCLUDE_OPT \
/ \
b2://"$id":"$key"@"$name"

exit 0;
