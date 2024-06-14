#!/bin/bash

# This script is used in a dockerized environment for repeatedly converting all
# files (which should be images) that end up in a conversion directory determined
# by the named volume (i.e. /usr/local/app/uploads)

echo "Running in $PWD"
#rm * # Remove all previously existing (image) files in dir

process_img()
{
    img="$1"
    convert-img.sh -i "$img" -r -o "${img}.${count}.img"
    # Remove every extra created file
    for newimg in *"$img"*; do
        [[ ! "$newimg" =~ \.img$ ]] && rm "$newimg"
    done
    ((count++))
}

count=1
while true; do
    # Run the below for loop to check for every image in dir only if dir not empty
    if [[ "$(ls -l | grep -v 'total 0')" != "" ]]; then 
        for img in *; do
            [[ ! "$img" =~ \.img$ ]] && process_img "$img"
            ls
        done
    fi
    sleep 1
done
