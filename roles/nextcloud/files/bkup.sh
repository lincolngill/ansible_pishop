#!/usr/bin/env bash 
# 
# bkup.sh - rclone backup of nextcloud files to onedrive
#
THISDIR=$(dirname $0)
THISDIR=$(cd "$THISDIR"; pwd)
THISPROG=$(basename $0)
LOGFILENAME="bkup.log"
LOGFILE="${THISDIR}/${LOGFILENAME}"
LOGLN="logs/bkup.$(date +%Y%m).log"
LOGPATH="${THISDIR}/${LOGLN}"
EXCFILE="${THISDIR}/bkup.exclude"

COPTS="--progress"
X="-x"
while getopts "b" OPT; do
	case $OPT in
		b)
			COPTS=""
			X="+x"
			;;
	esac
done

if  [ ! -f "$LOGPATH" ]; then
	touch "$LOGPATH"
	( cd "$THISDIR"; ln -s "$LOGLN" "$LOGFILENAME" )
fi

for PID in $(pgrep -f "$THISPROG"); do
	if [ $PID != $$ ]; then
		(echo "$(date) ERROR: $THISPROG is already running PID=$PID" | tee -a $LOGFILE)>&2
		exit 1
	fi
done
set $X
rclone sync /mnt/nc1 nc_bkup: $COPTS --exclude-from "$EXCFILE" --retries 1 --log-file "$LOGFILE" --log-level INFO
