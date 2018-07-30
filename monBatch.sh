#/bin/bash

HOST=`hostname`
SERVICE='itm.common.ITMBatchScheduler'
EMAIL='techcustomersupport@csid.com'
SUBJECT=""
BODY=""

email () {
TMPFILE=/itm/process/monitor.email
echo "To: $EMAIL" > $TMPFILE
echo "From: `whoami`@`hostname`" >> $TMPFILE
echo "Subject: $SUBJECT" >> $TMPFILE
echo "Importance:High" >> $TMPFILE
echo "$BODY" >> $TMPFILE

/usr/sbin/sendmail -t < ${TMPFILE}

}

batchLogfile="/itm/output-files/BATCHSTATUS"`date +"%m%d%Y"`".txt";

if ps ax | grep -v grep | grep $SERVICE > /dev/null
    then
    echo "$SERVICE service running, everything is fine"
    count=`ps ax | grep -v grep | grep $SERVICE | wc | awk '{print $1}'`
    if [ $count -gt 1 ]
        then
        SUBJECT="$HOST: SEVERE_EXCEPTION: $SERVICE multiple instances running";
        BODY="$HOST: SEVERE EXCEPTION: $SERVICE has multiple instances running";
        echo $BODY;
        email
    else
        echo "$HOST: $SERVICE only has single instance running.  Everything is fine";
    fi

    if [ ! -f $batchLogfile ]
        then
        SUBJECT="$HOST: SEVERE_EXCEPTION: $SERVICE : Log file missing";
        BODY="$HOST: SEVERE EXCEPTION: $SERVICE : $batchLogfile does not exist.";
        echo $BODY;
        email
    else
        prevCount=0;
        if [ -f /itm/process/scratch/batchSchedulerWC ]
            then
            if grep $batchLogfile /itm/process/scratch/batchSchedulerWC
                then
                prevCount=`cat /itm/process/scratch/batchSchedulerWC | awk -F: '{print $2}'`
            else
                awk 'BEGIN{}{}END{print FILENAME":"NR}' $batchLogfile > /itm/process/scratch/batchSchedulerWC
                exit;
            fi
        else
            awk 'BEGIN{}{}END{print FILENAME":"NR}' $batchLogfile > /itm/process/scratch/batchSchedulerWC
            exit;
        fi

        currentCount=`wc $batchLogfile | awk '{print $1}'`
        if [ $currentCount -eq $prevCount ]
            then
            SUBJECT="$HOST: SEVERE_EXCEPTION: $SERVICE : No log file modification.";
            BODY="$HOST: SEVERE EXCEPTION: $SERVICE : $batchLogfile previous count: $prevCount; current count: $currentCount";
            echo $BODY;
            email
        fi

        awk 'BEGIN{}{}END{print FILENAME":"NR}' $batchLogfile > /itm/process/scratch/batchSchedulerWC
    fi
else
    SUBJECT="$HOST: SEVERE_EXCEPTION: $SERVICE down";
    BODY="$HOST: SEVERE EXCEPTION: $SERVICE is not running";
    echo $BODY;
    email
fi
