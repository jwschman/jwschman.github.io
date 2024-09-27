#!/bin/bash

# make sure that a post title was input
if [ -z "$1" ]; then
	echo "Please provide a title for the post."
	exit 1
fi

# make sure that there is a folder for the current year.  If there isn't--make one.
YEAR="$(date +"%Y")"
if [ ! -d './content/posts/'$YEAR ]; then
    echo "Directory for $YEAR doesn't exist.  Creating now..."
    mkdir ./content/posts/$YEAR
fi

# build the variables to be used
HYPHENATED_TITLE=$(echo $1 | tr " " "-" | tr '[:upper:]' '[:lower:]')
DATE="$(date +"%m-%d")"
DIRECTORY_NAME=$DATE-$HYPHENATED_TITLE
FILE_PATH=./content/posts/$YEAR/$DIRECTORY_NAME

# make the directory for the new post
# I use directories so that any page assets can be colocated
mkdir $FILE_PATH

# copy the blank post to the new directory and rename it index.md
cp blank_post.md $FILE_PATH/index.md

# set the title and date in the front matter of the new index.md
sed "s/title = \"\"/title = \"$1\"/" -i $FILE_PATH/index.md
sed "s/date = \"\"/date = \"$YEAR-$DATE\"/" -i $FILE_PATH/index.md