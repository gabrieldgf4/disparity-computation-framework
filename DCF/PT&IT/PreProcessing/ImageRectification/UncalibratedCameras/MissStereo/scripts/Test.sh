#!/bin/bash

# Exit in case of error
set -e

ERROR_MSG="The variable MISS_STEREO_PATH is not set. \
Please set it to the 'bin' folder of your build location before trying again." 

[ "$MISS_STEREO_PATH" != "" ] || { echo $ERROR_MSG; false; }

# Necessary utilities
DIRNAME=/usr/bin/dirname

mkdir TestMissStereo
cd TestMissStereo
IMG_FOLDER=`$DIRNAME $0`/../data/CarcassonneSmall
IMG1="$IMG_FOLDER/im1.png"
IMG2="$IMG_FOLDER/im2.png"

echo "The images I will be using are $IMG1 and $IMG2"

`$DIRNAME $0`/MissStereo.sh "$IMG1" "$IMG2"
