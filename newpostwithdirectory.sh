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

HYPHENATED_TITLE=$(echo $1 | tr " " "-")

DATE="$(date +"%m-%d")"

DIRECTORY_NAME=$DATE-$HYPHENATED_TITLE

FILE_PATH=./content/posts/$YEAR/$DIRECTORY_NAME

mkdir $FILE_PATH

cp blank_post.md $FILE_PATH/index.md

sed "s/title = \"\"/title = \"$1\"/" -i $FILE_PATH/index.md

sed "s/date = \"\"/date = \"$YEAR-$DATE\"/" -i $FILE_PATH/index.md