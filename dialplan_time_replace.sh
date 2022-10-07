#!/bin/bash

#A text file with a schedule when organisation is open
KOPEN_TXT=/path/to/mainfolder/kopen.txt
#A text file with a schedule when organisation is closed
KCLOSED_TXT=/path/to/mainfolder/kclosed.txt
#Temporary files
TEXTFILES=/path/to/mainfolder/textfile*
#Path to the folder with a new message 
DIR_PATH=/path/to/mailserver/messages/new/*
#Path to the dialplan with schedules 
FRSW_PATH=/etc/freeswitch/dialplan/yourdialplan.xml
#Path to the freeswitch log
FRSW_LOG=/var/log/freeswitch/freeswitch.log
TOKEN="your_telegram_bot_token"
ID="your_telegram_chat_id"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

for file in $DIR_PATH ; do
    if [ -f "$file" ]; then
      echo "$file exists!"
      ripmime -i $file -d /root/frsw/ --overwrite --no-multiple-filenames
      rm $file
    else
      echo "$file does not exist!"
    fi
done

if [ -f "$KOPEN_TXT" ]; then
    TEXT=`cat $KOPEN_TXT`
    sed -i "/extra_kassa_open/s/[0-9]\{4\}.*:[0-9]\{2\}/""$TEXT""/" $FRSW_PATH
    sleep 2
    fs_cli -x reloadxml
    LAST_RULE=`sed -nr 's/^.*"extra_kassa_open".*<condition date-time="([0-9]{4}.*:[0-9]{2}).*/\1/p' $FRSW_PATH | xargs`
    DATE_FRSW_REST=`tail -1 <(sed -nr 's/(^.*:[0-9]{2})\..*ENUM Reloaded/\1/p' $FRSW_LOG)`
        if [[ $TEXT == $LAST_RULE ]]; then
          echo "FILES EQ!!! $DATE_FRSW_REST"
          curl -X POST --silent --output /dev/null $URL -d chat_id=$ID -d text="FILES EQ! $LAST_RULE Restart: $DATE_FRSW_REST"
        else
          echo "FILES NEQ!!! $DATE_FRSW_REST"
          curl -X POST --silent --output /dev/null $URL -d chat_id=$ID -d text="FILES NEQ! $LAST_RULE Restart: $DATE_FRSW_REST"
        fi

elif [ -f "$KCLOSED_TXT" ]; then
    TEXT=`cat $KCLOSED_TXT`
    sed -i "/extra_kassa_closed/s/[0-9]\{4\}.*:[0-9]\{2\}/""$TEXT""/" $FRSW_PATH
    sleep 2
    fs_cli -x reloadxml
    LAST_RULE=`sed -nr 's/^.*"extra_kassa_closed".*<condition date-time="([0-9]{4}.*:[0-9]{2}).*/\1/p' $FRSW_PATH | xargs`
    DATE_FRSW_REST=`tail -1 <(sed -nr 's/(^.*:[0-9]{2})\..*ENUM Reloaded/\1/p' $FRSW_LOG)`
        if [[ $TEXT == $LAST_RULE ]]; then
          echo "FILES EQ!!! $DATE_FRSW_REST"
          curl -X POST --silent --output /dev/null $URL -d chat_id=$ID -d text="FILES EQ! $LAST_RULE Restart: $DATE_FRSW_REST"
        else
          echo "FILES NEQ!!! $DATE_FRSW_REST"
          curl -X POST --silent --output /dev/null $URL -d chat_id=$ID -d text="FILES NEQ! $LAST_RULE Restart: $DATE_FRSW_REST"
        fi
else
    echo "FILES does not exist!"
fi

sleep 1

#Remove all temporary files
if [ -f "$KCLOSED_TXT" ]; then
    echo "$KCLOSED_TXT exist!"
    rm "$KCLOSED_TXT" ""$TEXTFILES""
elif [ -f "$KOPEN_TXT" ]; then
    echo "$KOPEN_TXT exist!"
    rm "$KOPEN_TXT" ""$TEXTFILES""
else
    echo "FILES does not exist!"
fi
