#!/usr/bin/env bash
#
# Make gocv module
# Refer: https://gocv.io/getting-started/linux/
#
# Downloads the latest gocv module.
# Runs the make if not done already
#
# -u Only does the Module download/update step. Create $MAKESIGFILE to trigger ansible to run the full make steps in a second call.
# -b Creates and runs in a detached screen session, so you can reattach (screen -r make_gocv) and detach (ctrl-a ctrl-d), at will.
# Logs all output
# Logs the status of each task and only runs tasks that have not completed successfully already.
#
# Note: Script is created by ansible. Edit ansible file rather than this file.

GOCV_MOD="gocv.io/x/gocv"
GOMODCACHE=$(go env GOMODCACHE)
LOGFILE=~/gocv_make.log
STATUSLOG=~/gocv_make_tasks.log
MAKESIGFILE=~/gocv_make.flag

# Log a message
fn_log() {
	MSG="$1"
	LVL="${2:-INFO }"
	echo "$(date --iso-8601=seconds) $LVL $MSG"
}

# Log an error and terminate if RC!=0
fn_err() {
	MSG="$1"
	RC=${2:-0}
	fn_log "$MSG" "ERROR"
	if [ $RC -ne 0 ]; then
		exit $RC
	fi
}

# Record and log a task status
# The task status log is kept across multiple invocations.
# The status log is searched to determine if a task has already run or not.
fn_logstatus() {
	TASKNAME="$1"
	STATUS="$2"
	RC=${3:-0}
	MSG="$TASKNAME $STATUS"
	if [ $RC -ne 0 ]; then
		MSG="$MSG RC=$RC"
		echo "$(date --iso-8601=seconds) $MSG" >> $STATUSLOG
		fn_err "$MSG" $RC
	fi
	echo "$(date --iso-8601=seconds) $MSG" >> $STATUSLOG
	fn_log "$MSG"
}

# Run a task
# Skips tasks that already have a "COMPLETE" status in the task log file.
fn_dotask() {
	TASKNAME="$1"
	CMD="$2"
    # Check if task has already been done
	DONE=$(grep "$TASKNAME COMPLETE" $STATUSLOG)
	if [ -n "$DONE" ]; then
		fn_logstatus "$TASKNAME" "SKIPPED"
		return
	fi
	fn_logstatus "$TASKNAME" "STARTED"
    # eval the command string to support compound commands. E.g. "whoami; sleep 5"
	time (eval $CMD)
	RC=$?
	if [ $RC -eq 0 ]; then
		fn_logstatus "$TASKNAME" "COMPLETE"
	else
		fn_logstatus "$TASKNAME" "FAILED" $RC
	fi
}

# Get the module directory of the latest version
# Returns "" if no version
fn_getmoddir () {
	echo $(ls -d1 "${GOMODCACHE}/${GOCV_MOD}"* 2>/dev/null | sort -r | head -1)
}

# -b   Run in screen as a background task
# -u   Just download new module. Don't run make steps.
#      Signal file created so ansible can rerun the script and do the make steps if required.
BG=""
UPDATEONLY=""
while getopts "bu" ARG; do
	case $ARG in
		b) BG="Y" ;;
		u) UPDATEONLY="Y" ;;
	esac
done

# If -b then ReStart the Script in a dettached screen (with logging)
# "screen -r make_gocv" to reattach
# Can ctrl-a ctrl-d to detach and logout.
# Screen will terminate when script exits
# Log file will contain all output (including timing from time keyword).
if [[ -z "$STY" && -n "$BG" ]]; then
	if [ -n "$(screen -list | grep make_gocv)" ]; then
		echo "ERROR: Already running."
		exit 1
	fi
	fn_log "Starting screen" | tee $LOGFILE
	exec screen -d -m -L -Logfile $LOGFILE -S make_gocv /usr/bin/bash "$0"
	echo "Should never see this!"
	exit
fi

# Install or update module
CURMAKEDIR=$(fn_getmoddir)
if [ -z "$CURMAKEDIR" ]; then
	fn_log "Installing gocv.io/x/gocv module..."
else
	fn_log "Updating $CURMAKEDIR..."
fi
# Just download
go get -d -u "$GOCV_MOD"
MAKEDIR=$(fn_getmoddir)
BASENAME=$(basename "$MAKEDIR")
if [ "$MAKEDIR" != "$CURMAKEDIR" ]; then
	fn_log "New gocv version: $MAKEDIR"
	# Create signal file. New module needs the make steps
	echo "$BASENAME" > "$MAKESIGFILE" 
else
	fn_log "No upgrade available."
fi

# Just check for updates and create the $MAKESIGFILE if the make steps are required.
# Ansible will use "removes: $MAKESIGFILE" to skip make steps if already done.
if [ -n "$UPDATEONLY" ]; then
	exit 0
fi

# Run the make tasks
fn_logstatus "$BASENAME-Make" "STARTED"
cd "$MAKEDIR"
fn_dotask "$BASENAME-DEPS"     "make deps"
fn_dotask "$BASENAME-DOWNLOAD" "make download"
fn_dotask "$BASENAME-BUILD"    "make build"
fn_dotask "$BASENAME-INSTALL"  "make sudo_install"
fn_dotask "$BASENAME-VERSION"  "go run ./cmd/version/main.go"
fn_logstatus "$BASENAME-Make" "COMPLETE"
rm "$MAKESIGFILE"
