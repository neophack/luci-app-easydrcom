#!/bin/sh /etc/rc.common
#easydrcom daemon
#Author:presisco

DAEMONCOUNT=`ps | grep -c easydrcom-daemon`
DLOGPATH=$(uci get easydrcom.@easydrcom[0].dlogpath)
EZLOGPATH=$(uci get easydrcom.@easydrcom[0].ezlogpath)
DLOGMAXSIZE=$(uci get easydrcom.@easydrcom[0].dlogsize)
EZLOGMAXSIZE=$(uci get easydrcom.@easydrcom[0].ezlogsize)
INTERVAL=$(uci get easydrcom.@easydrcom[0].dinterval)
let "DLOGMAXSIZE*=1024"
let "EZLOGMAXSIZE*=1024"

if [ $DAEMONCOUNT -ge "4" ]
then
	exit 0
else
	DATE=`date`
	echo "easydrcom daemon started at $DATE">>$DLOGPATH
	echo "max easydrcom log size:$EZLOGMAXSIZE">>$DLOGPATH
	echo "max daemon log size:$DLOGMAXSIZE">>$DLOGPATH
	echo "check interval:$INTERVAL">>$DLOGPATH

	while true
	do
		sleep $INTERVAL
		
		EZLOGSIZE=`awk 'END{print NR}' $EZLOGPATH`
		if [ $EZLOGSIZE -gt $EZLOGMAXSIZE ]
		then
			echo "" > $EZLOGPATH
			DATE=`date`
			echo "cleared easydrcom logfile at $DATE">>$DLOGPATH
		fi
		
		DLOGSIZE=`awk 'END{print NR}' $DLOGPATH`
		if [ $DLOGSIZE -gt $DLOGMAXSIZE ]
		then
			echo "" > $DLOGPATH
		fi
		
		PCOUNT=`ps | grep -c "easydrcom -b -r"`
		DATE=`date`
		if [ $PCOUNT -lt "2" ]
		then
			echo "easydrcom restarted at $DATE">>$DLOGPATH
			/etc/init.d/easydrcom-conf start
		fi
	done
fi