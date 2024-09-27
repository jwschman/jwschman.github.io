#!/bin/bash

if [ -z "$1" ]; then
	echo "Please provide a title for the post."
	exit 1
fi

YEAR="$(date +"%Y")"

if [ ! -d './content/posts/'$YEAR ]; then
    echo "Directory for $YEAR doesn't exist.  Creating now..."
    mkdir ./content/posts/$YEAR
fi

FILETITLE=$(echo $1 | tr " " "-")

DATE="$(date +"%m-%d")"

FULLDATE="$(date +"%Y-%m-%d")"

FILENAME=$DATE-$FILETITLE

FILEPATH=./content/posts/$YEAR/

cp blank_post.md $FILEPATH/$FILENAME.md

sed "s/title = \"\"/title = \"$1\"/" -i $FILEPATH/$FILENAME.md

sed "s/date = \"\"/date = \"$YEAR-$DATE\"/" -i ./content/posts/$YEAR/$FILENAME.md