#!/bin/bash
# Compare number of running nodes to number of installed nodes; restart daemon if different

# exit with error if not run as root/sudo
if [ "$(id -u)" != "0" ]
then echo -e "\n Please re-run as root or sudo.\n"
    exit 1
fi

# Set common variables
. /var/tmp/nodevalet/maintenance/vars.sh

# add logging to check if cron is working as planned
# echo -e "`date +%m.%d.%Y_%H:%M:%S` : Executing makerun.sh (every 5 minutes, cron) \n"  | tee -a "$LOGFILE"

if [ -e "$INSTALLDIR/temp/bootstrapping" ]
then echo -e " Skipping makerun.sh because bootstrap is in progress.\n"
    exit
fi

if [ -e "$INSTALLDIR/temp/shuttingdown" ]
then echo -e " Skipping makerun.sh because the server is shutting down.\n"
    exit
fi

if [ -e "$INSTALLDIR/temp/activating" ]
then echo -e " Skipping makerun.sh because the server is activating masternodes.\n"
    exit
fi

if [ -e "$INSTALLDIR/temp/updating" ]
then echo -e " $(date +%m.%d.%Y_%H:%M:%S) : Running makerun.sh" | tee -a "$LOGFILE"
    echo -e " It looks like I'm busy with something else; skipping make run.\n"  | tee -a "$LOGFILE"
    exit
fi

TOTAL=$(ps aux | grep -i "$MNODE_DAEMON" | wc -l)
CUR_DAEMON=$(expr "$TOTAL" - 1)
EXP_DAEMON=$(cat $INFODIR/vps.number.info)

if [ "$CUR_DAEMON" != "$EXP_DAEMON" ]
then echo -e " $(date +%m.%d.%Y_%H:%M:%S) : I expected $EXP_DAEMON daemons but found only $CUR_DAEMON. Restarting... \n" | tee -a "$LOGFILE"
    touch $INSTALLDIR/temp/activating
    bash /usr/local/bin/activate_masternodes_"$PROJECT"
    rm $INSTALLDIR/temp/activating
else echo -e "\n $(date +%m.%d.%Y_%H:%M:%S) : Found $CUR_DAEMON of $EXP_DAEMON expected daemons. All is well. \n"
fi
