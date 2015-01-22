#!/bin/sh

export TMP_DIRECTORY="sorted"
VIDEO_FNAME="output.mp4"
VIDEO_FPS=24
VIDEO_HEIGHT=2160
VIDEO_WIDTH=3840

echo "Removing existing $TMP_DIRECTORY"
rm -rf $TMP_DIRECTORY

echo "Creating $TMP_DIRECTORY"
mkdir $TMP_DIRECTORY

echo "Copying all ingr- files to $TMP_DIRECTORY"
ls ingr-*.png | gawk 'BEGIN{ a=1 }{ printf "ln -s ../%s ${TMP_DIRECTORY}/ingr_%04d.png\n", $0, a++ }' | sh

cd $TMP_DIRECTORY

avconv -r 1 -f image2 -i ingr_%04d.png -c:v libx264 -maxrate:v 200000k -minrate:v 160000k  -c:a n -s ${VIDEO_WIDTH}x${VIDEO_HEIGHT} -r $VIDEO_FPS $VIDEO_FNAME
