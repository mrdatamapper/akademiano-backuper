#!/usr/bin/env bash

# logicalBackupAndRotate.sh
# Provides a logical backup with
# retention / rotation.

# Scott Mead
# scott.mead@openscg.com
# GPL V3 + Attribution

# $ crontab -l

#PG Dumps for all the DB's in cluster

#00 15 * * *  /db/scripts/logicalBackup.sh


### --- BEGIN SCRIPT ----
while [ -n "$1" ]
do
    case "$1" in
        -h | --host ) shift
                      PGHOST="$1"
                      shift
            ;;
        -d | --dir  ) shift
                      backupDir="$1"
                      shift
            ;;
        -p | --port ) shift
                      PGPORT="$1"
                      shift
            ;;
        -u | --user ) shift
                      PGUSER="$1"
                      shift
            ;;
        -W | --pass ) shift
                      PGPASSWORD="$1"
                      shift
            ;;
        * ) printf "Invalid option $1\n"
            exit 1
    esac
done

fail=0
if [ -z "$PGHOST" ]
then
    printf "Please provide a host with -h\n"
    fail=1
fi

if [ -z "$PGUSER" ]
then
    printf "Please provide a user with -u\n"
    fail=1
fi

if [ -z "$backupDir" ]
then
    printf "Please provide a backup directory with -d\n"
    fail=1
fi


if [ "$fail" -eq 1 ]
then
    printf "Exiting, please re-run with requested options\n"
    exit 1
fi


if [ -z "$PGPORT" ]
then
    PGPORT=5432
fi

if [ ! -f "$backupDir" ]; then
    mkdir -p "$backupDir"
fi

pushd $backupDir

export PGHOST
export PGPORT
export PGUSER
export PGPASSWORD

printf "Start: `date`" > $backupDir/backup.log

pg_dumpall -g > /$backupDir/globals.sql

dbs=`psql -t -c "select array_to_string(ARRAY(select datname from pg_database),' ')" | sed -e '/^$/d' | sed -e 's/^[  \t]//g'`

for db in $dbs
do
    printf "Performing backup of: $db\n"
    pg_dump -v -Fp -b -C $db > /$backupDir/$db.sql 2>> /$backupDir/backup.log
done

printf "Complete: `date`" >> $backupDir/backup.log

popd

printf "Complete!\n\n"

exit 0
