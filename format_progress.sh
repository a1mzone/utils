#!/bin/bash

# Function to format a device
progress_device() {
    local device=$1
    echo "Status $device:"
    sg_turs --progress $device
}

# Loop through the devices starting at /dev/sdb
for device in /dev/sd{b..y}; do
    if [ -b $device ]; then
        progress_device $device
    fi
done

echo "Looped through all devices."

