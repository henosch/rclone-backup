#!/bin/bash

PIHOLE_CONFIG_DIR=/etc/pihole
GRAVITYDB_FILE=${PIHOLE_CONFIG_DIR}/gravity.db
GRAVITYDB_MIN_FILE=${PIHOLE_CONFIG_DIR}/gravity.min.db

if [ -d "/etc/pihole" ] && [ -d "/opt/pihole" ] && [ -f "${GRAVITYDB_FILE}" ]; then
        command -v sqlite3 >/dev/null 2>&1 || { echo "Please install 'sqlite3' package!"; exit 1; }
        command -v md5sum >/dev/null 2>&1 || { echo "Please install 'md5sum' package!"; exit 1; }

        PREVIOUS_CHECKSUM=
        if [ -f "${GRAVITYDB_FILE}.md5" ]; then
                PREVIOUS_CHECKSUM=`cat "${GRAVITYDB_FILE}.md5"`
        fi

        CURRENT_CHECKSUM=`md5sum ${GRAVITYDB_FILE} | awk '{ print $1 }'`

        if [ "${CURRENT_CHECKSUM}" != "${PREVIOUS_CHECKSUM}" ] || [ ! -f "${GRAVITYDB_MIN_FILE}" ]; then
                echo "Compressing gravity database..."

                # Create new empty database
                rm -f ${GRAVITYDB_MIN_FILE}
                sqlite3 ${GRAVITYDB_MIN_FILE} "VACUUM;"

                # Copy schema
                sqlite3 ${GRAVITYDB_FILE} ".schema" | sed "/sqlite_sequence/d" | sqlite3 ${GRAVITYDB_MIN_FILE}

                if [ $? -eq 0 ]; then
                        # Copy data from specific tables
                        {
                        sqlite3 ${GRAVITYDB_FILE} <<EOT
.mode insert info
SELECT * FROM 'info';
.mode insert 'group'
SELECT * FROM 'group';
.mode insert 'client'
SELECT * FROM 'client';
.mode insert 'client_by_group'
SELECT * FROM 'client_by_group' WHERE 'client_by_group'.'group_id' > 0;
.mode insert 'adlist'
SELECT * FROM 'adlist';
.mode insert 'adlist_by_group'
SELECT * FROM 'adlist_by_group' WHERE 'adlist_by_group'.'group_id' > 0;
.mode insert 'domainlist'
SELECT * FROM 'domainlist';
.mode insert 'domainlist_by_group'
SELECT * FROM 'domainlist_by_group' WHERE 'domainlist_by_group'.'group_id' > 0;
.mode insert 'domain_audit'
SELECT * FROM 'domain_audit';
EOT
                        } | sqlite3 ${GRAVITYDB_MIN_FILE}

                        if [ ! $? -eq 0 ]; then
                                echo "Failed to copy database data!"
                                exit 1
                        fi
                else
                        echo "Failed to copy database schema!"
                        exit 1
                fi

                echo ${CURRENT_CHECKSUM} > "${GRAVITYDB_FILE}.md5"
        else
                echo "No need to compress gravity database!"
        fi
fi
