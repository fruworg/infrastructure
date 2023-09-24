#!/bin/bash

#
# dump all
#

BACKUP_FOLDER="/var/backups/infrastructure"
MEGA_FOLDER="/mnt/mega/backups"
GDRIVE_FOLDER="/mnt/gdrive/backups"

clean_old_backups() {
  local CLEANED_FOLDER="$1"

  for BACKUP_FILE in $CLEANED_FOLDER/*.tar.zst.gpg; do

    BACKUP_DATE="$(echo $BACKUP_FILE | egrep -o [0-9]{2}-[0-9]{2}-[0-9]{4} | sed -e 's/-//g')"

    # if january the first
    if [ "${BACKUP_DATE:2:2}${BACKUP_DATE:0:2}" -eq "0101" ]; then
      continue
    fi

    # if older than year
    if [ "${BACKUP_DATE:4}" -lt "$DELETE_BY_YEAR" ]; then
      rm "$BACKUP_FILE"
      continue
    fi

    # if first day of month
    if [ "${BACKUP_DATE:0:2}" -eq "01" ]; then
      continue
    fi

    BACKUP_DATE_FORMATTED="${BACKUP_DATE:4}${BACKUP_DATE:2:2}${BACKUP_DATE:0:2}"

    # if older than week
    if [ "$BACKUP_DATE_FORMATTED" -lt "$DELETE_BY_DAYS" ]; then
      rm "$BACKUP_FILE"
    fi

  done
}

copy_new_backups() {
  local REMOTE_FOLDER="$1"
  cp -r "$BACKUP_FOLDER/$(date '+%d-%m-%Y.tar.zst.gpg')" "$REMOTE_FOLDER"
}

rm -rf "$BACKUP_FOLDER/tmp" && mkdir "$_"

mkdir "$BACKUP_FOLDER/tmp/sh/" && \
  cp -r /usr/local/bin/{backup.sh,caddy.sh,update.sh} \
  /etc/systemd/system/{backup,update}.{service,timer} "$_"

mkdir "$BACKUP_FOLDER/tmp/caddy/" && \
  cp -r /etc/caddy/Caddyfile "$_"

mkdir "$BACKUP_FOLDER/tmp/pg/" && \
  cp -r /etc/postgresql/15/main/{pg_hba.conf,postgresql.conf} "$_"

mkdir "$BACKUP_FOLDER/tmp/rclone/" && \
  cp -r /etc/systemd/system/rclone-{mega,gdrive}.service \
  /root/.config/rclone/rclone.conf "$_"

mkdir "$BACKUP_FOLDER/tmp/bashrc/" && cp ~/.bashrc "$_"
mkdir "$BACKUP_FOLDER/tmp/ufw/" && cp -r /etc/ufw/* "$_"

echo "configs have been successfully backuped"

mkdir "$BACKUP_FOLDER/tmp/opt/" && \
  cp -r /opt/* "$_"

echo "compose files have been successfully backuped"

sudo -i -u postgres pg_dumpall > "$BACKUP_FOLDER/tmp/pg/pg_dumpall.sql"

echo "postgres have been successfully backuped"

tar --zstd -cf "$BACKUP_FOLDER/$(date '+%d-%m-%Y.tar.zst')" \
	-C "$BACKUP_FOLDER/tmp" . 2> /dev/null

rm -rf "$BACKUP_FOLDER/tmp"

gpg --batch --yes -e -r im@fruw.org "$BACKUP_FOLDER/$(date '+%d-%m-%Y.tar.zst')"
rm "$BACKUP_FOLDER/$(date '+%d-%m-%Y.tar.zst')"

echo "backup have been successfully encrypted"

DELETE_BY_YEAR=$(date '+%Y' --date="-365 days")
DELETE_BY_DAYS=$(date '+%Y%m%d' --date="-6 days")

clean_old_backups "$BACKUP_FOLDER"
# clean_old_backups "$GDRIVE_FOLDER"
clean_old_backups "$MEGA_FOLDER"

echo "backups have been successfully cleaned"

# copy_new_backups "$GDRIVE_FOLDER"
copy_new_backups "$MEGA_FOLDER"

echo "backup have been successfully copied"
