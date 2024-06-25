#!/usr/bin/env bash 
# 
# odbkup.sh - rclone backup of onedrive to /mnt/t7/onedrive_bkup
#
#set -e
THISDIR=$(dirname $0)
THISDIR=$(cd "$THISDIR"; pwd)
THISPROG=$(basename $0)
LOGFILENAME="odbkup.log"
LOGFILE="${THISDIR}/${LOGFILENAME}"
LOGLN="logs/odbkup.$(date +%Y%m%d).log"
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

# Send logfile email and exit if RC > 0
function fn_sendemail {
	RC=$1
	if [ $RC -eq 0 ]; then
		SUBJECT="${THISPROG} Completed on ${HOSTNAME} at $(date)"
	else
		SUBJECT="${THISPROG} Failed RC=${RC} on ${HOSTNAME} at $(date)"
	fi
	set $X
	mutt -s "$SUBJECT" lincolngill@gmail.com < "$LOGFILE"
	{ set +x; } 2>/dev/null
	if [ $RC -ne 0 ]; then
		exit $RC
	fi
}

# Create daily log file and sym link, if required.
if  [ ! -f "$LOGPATH" ]; then
	touch "$LOGPATH"
	( cd "${THISDIR}"; ln -sf "$LOGLN" "$LOGFILENAME" )
fi

# Exit if already running
for P in $(pgrep -f "$THISPROG"); do
	if [[ $P != $$ && $P != $PPID ]]; then
		(echo "$(date) ERROR: $THISPROG $PPID -> $$ is already running PID=$P" | tee -a $LOGFILE)>&2
		fn_sendemail 1
	fi
done

# Check the disk is mounted. Exit if not.
if [ ! -d /mnt/t7/onedrv_bkup ]; then
	(echo "$(date) ERROR: disk /mnt/t7 not mounted" | tee -a $LOGFILE)>&2
	fn_sendemail 1
fi

set $X
rclone sync onedrive: /mnt/t7/onedrv_bkup $COPTS --no-update-modtime --exclude-from "$EXCFILE" --retries 1 --log-file "$LOGFILE" --log-level INFO $DRYRUN
{ set +x; } 2>/dev/null
fn_sendemail $?

# Remove log file if nothing happened.
if tail -8 "$LOGFILE" | grep -q "There was nothing to transfer"; then
	set $X
	rm "$LOGPATH"
	{ set +x; } 2>/dev/null
fi
