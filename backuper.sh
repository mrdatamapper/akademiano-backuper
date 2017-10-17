#!/usr/bin/env bash

source ./lib/inifiles.sh

INI_FILE='/etc/akademiano/backuper/config.ini'

if [ ! -f "$INI_FILE" ]; then
    echo "Config file not found!"
fi

ini_eval postgres "$INI_FILE"

fail=0
if [ -z "$postgres_host" ]
then
    printf "Please provide a host\n"
    fail=1
fi

if [ -z "$postgres_user" ]
then
    printf "Please provide a user\n"
    fail=1
fi

if [ -z "$postgres_pass" ]
then
    printf "Please provide a password\n"
    fail=1
fi

if [ -z "$postgres_backupDir" ]
then
    printf "Please provide a backup directory\n"
    fail=1
fi

if [ "$fail" -eq 1 ]
then
    printf "Exiting, please re-run with requested options\n"
    exit 1
fi

bash pg_full_backup.sh -d "$postgres_backupDir" -h "$postgres_host" -u "$postgres_user" -W "$postgres_pass"


ini_eval duplicity "$INI_FILE"

fail=0
if [ -z "$duplicity_passphrase" ]
then
    printf "Please provide a passphrase\n"
    fail=1
fi

if [ -z "$duplicity_id" ]
then
    printf "Please provide a id\n"
    fail=1
fi
if [ -z "$duplicity_key" ]
then
    printf "Please provide a key\n"
    fail=1
fi
if [ -z "$duplicity_name" ]
then
    printf "Please provide a name\n"
    fail=1
fi

if [ "$fail" -eq 1 ]
then
    printf "Exiting, please re-run with requested options\n"
    exit 1
fi

if [ -z "$duplicity_cache" ]
then
    cache="/var/cache/duplicity"
fi

bash duplicity_b2.sh -p "$duplicity_passphrase" -d "$postgres_backupDir" -c "$duplicity_cache" -i "$duplicity_id" -k "$duplicity_key" -n "$duplicity_name"
