#!/usr/bin/env bash 
# 
# bkup.sh - rclone backup of nextcloud files to onedrive
#
set -e
THISDIR=$(dirname $0)
THISDIR=$(cd "$THISDIR"; pwd)
THISPROG=$(basename $0)
LOGFILENAME="ncbkup.log"
LOGFILE="/var/log/ncbkup/${LOGFILENAME}"
LOGLN="logs/ncbkup.$(date +%Y%m).log"
LOGPATH="/var/log/ncbkup/${LOGLN}"
EXCFILE="/etc/ncbkup.exclude"

COPTS="--progress"
X="-x"
DRYRUN=""
while getopts "bd" OPT; do
	case $OPT in
		b)
			COPTS=""
			X="+x"
			;;
		d)
			DRYRUN="--dry-run"
			;;
	esac
done

if  [ ! -f "$LOGPATH" ]; then
	touch "$LOGPATH"
	( cd /var/log/ncbkup; ln -s "$LOGLN" "$LOGFILENAME" )
fi

for P in $(pgrep -f "$THISPROG"); do
	if [[ $P != $$ && $P != $PPID ]]; then
		(echo "$(date) ERROR: $THISPROG $PPID -> $$ is already running PID=$P" | tee -a $LOGFILE)>&2
		exit 1
	fi
done

# Check the disk is mounted
if [ ! -d /mnt/nc1/links ]; then
	(echo "$(date) ERROR: disk /mnt/nc1 not mounted" | tee -a $LOGFILE)>&2
	exit 1
fi

echo "rclone..."
set $X
rclone sync /mnt/nc1 nc_bkup: $COPTS --config /home/pi/.config/rclone/rclone.conf --exclude-from "$EXCFILE" --retries 1 --log-file "$LOGFILE" --log-level INFO $DRYRUN
