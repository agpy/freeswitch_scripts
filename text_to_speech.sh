#!/bin/bash

MAINFOLDER=/path/to/mainfolder/
FILE_SRC=/path/to/mainfolder/file.ogg
FILE_DST=/path/to/mainfolder/file.wav
FILE_TXT=/path/to/mainfolder/file.txt
DIR_PATH=/path/to/mailserver/messages/new/*
TEXTFILES=/path/to/mainfolder/textfile*
SOUND_DIR=/path/to/freeswitch/sounds/en/us/callie/yoursounds/
LAST_TEXT_FILE=/path/to/mainfolder/last_text_file/lasttextfile.txt
API_KEY=your_yandexcloud_api_key
FOLDER_ID=your_yandexcloud_folder_id

for file in $DIR_PATH ; do
    if [ -f "$file" ]; then
      echo "$file exists."
      ripmime -i $file -d $MAINFOLDER --overwrite --no-multiple-filenames
      rm $file
    else
      echo "$file does not exists!"
    fi
done

if [ -f "$FILE_TXT" ]; then
    TEXT=`cat $FILE_TXT | tee $LAST_TEXT_FILE`
    echo "$FILE_TXT exists and processing."
curl -X POST \
     -H "Authorization: Api-Key ${API_KEY}" \
     -o $FILE_SRC \
     --data-urlencode "text=${TEXT}" \
     -d "lang=ru-RU&voice=filipp&folderId=${FOLDER_ID}" \
     "https://tts.api.cloud.yandex.net/speech/v1/tts:synthesize"
else
    echo "$FILE_TXT does not exist!"
fi
sleep 3

if [ -f "$FILE_SRC" ]; then
    echo "$FILE_SRC exist!"
    ffmpeg -i $FILE_SRC -codec:a pcm_alaw -ar 8000 $FILE_DST -y
else
    echo "$FILE_SRC does not exist!"
fi
sleep 3

if [ -f "$FILE_DST" ]; then
    echo "$FILE_DST exist!"
    cp $FILE_DST ""$SOUND_DIR""
else
    echo "$FILE_DST does not exist!"
fi
sleep 3

if [ -f "$FILE_SRC" ] && [ -f "$FILE_DST" ]; then
    echo "$FILE_SRC and $FILE_DST exist!"
    rm "$FILE_SRC" "$FILE_DST" "$FILE_TXT" ""$TEXTFILES""
else
    echo "FILES does not exist!"
fi
