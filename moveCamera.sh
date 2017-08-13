#!/bin/bash

###################################################################
##                     USER DEFINED VALUES                       ##
###################################################################
USER="username" #Your camera administrator username
PWD="password" #Your administrato password
CAMIP="192.168.0.100" #Your camera IP Address
MIN_CUST_LOCATION=1 #Your first defined Custom location
MAX_CUST_LOCATION=3 #Your last defined Custom Location
HOME_LOCATION=0 #Put the number corresponding to your home location
BASE_PATH=/full/path/to/script/folder #Put full PATH
###################################################################
##                     END OF USER DEFINED VALUES                ##
###################################################################

URL="http://$CAMIP/pantiltcontrol.cgi"
LOGFILE="$BASE_PATH/log/moveCamera.log"
LAST_LOCATION_FILE="$BASE_PATH/cache/camLastPos"
LOCATION=0

log() {
        if [ "$1" == "-d" ]; then
                echo -n $(date +"%D %H:%M:%S") >> $LOGFILE
                echo -n " " >> $LOGFILE
                shift
        fi
        echo $@
        echo $@ >> $LOGFILE
}

#Check whether the Last Location file exist; if yes read last location, otherwise create
if [ -f $LAST_LOCATION_FILE ]; then
   log -d "File $LAST_LOCATION_FILE exists"
else
   log -d -n "File $LAST_LOCATION_FILE does not exist, I'm going to create it..."
   touch $LAST_LOCATION_FILE
   log -d "Done"
   echo $HOME_LOCATION > $LAST_LOCATION_FILE
   log -d "Set LAST_LOCATION to HOME_LOCATION"
fi

#Read LAST LOCATION 
log -d "Reading last location from Last Location file"
LAST_LOCATION=$(cat $LAST_LOCATION_FILE);
log -d "Last camera location is $LAST_LOCATION"


#check if last location value is lower than max cust location value
if [ $LAST_LOCATION -lt $MAX_CUST_LOCATION ]; then
	LOCATION=$((LAST_LOCATION+1));
else 
	LOCATION=$HOME_LOCATION;	
fi
log -d "New location to move camera to is $LOCATION";

#move camera and set new location to Last location file
log -d -n "Move camera to new location $LOCATION...";

HTTP_CODE=$(curl -m 5 --silent --write-out "%{http_code}\n" --user $USER:$PWD --user-agent "user" --data "PanTiltPresetPositionMove=$LOCATION" $URL);
if [ $HTTP_CODE == 204 ]; then 
	log -d "done";
	log -d -n "Store last location value ($LOCATION) into $LAST_LOCATION_FILE..."
	echo $LOCATION > $LAST_LOCATION_FILE
	log -d "done";
else 
	log -d "failed"
	log -d "Moving camera to location value ($LOCATION) failed"
fi
