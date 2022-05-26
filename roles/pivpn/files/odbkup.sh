#!/usr/bin/env bash 
# 
# odbkup.sh - rclone backup of onedrive to /mnt/t7/onedrive_bkup
#
set -e
THISDIR=$(dirname $0)
THISDIR=$(cd "$THISDIR"; pwd)
THISPROG=$(basename $0)
LOGFILENAME="odbkup.log"
LOGFILE="${THISDIR}/${LOGFILENAME}"
LOGLN="logs/odbkup.$(date +%Y%m).log"
LOGPATH="${THISDIR}/${LOGLN}"
EXCFILE="${THISDIR}/odbkup.exclude"

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
	( cd "${THISDIR}"; ln -s "$LOGLN" "$LOGFILENAME" )
fi

for P in $(pgrep -f "$THISPROG"); do
	if [[ $P != $$ && $P != $PPID ]]; then
		(echo "$(date) ERROR: $THISPROG $PPID -> $$ is already running PID=$P" | tee -a $LOGFILE)>&2
		exit 1
	fi
done

# Check the disk is mounted
if [ ! -d /mnt/t7/onedrv_bkup ]; then
	(echo "$(date) ERROR: disk /mnt/t7 not mounted" | tee -a $LOGFILE)>&2
	exit 1
fi

echo "rclone..."
set $X
rclone sync onedrive: /mnt/t7/onedrv_bkup $COPTS --exclude-from "$EXCFILE" --retries 1 --log-file "$LOGFILE" --log-level INFO $DRYRUN
