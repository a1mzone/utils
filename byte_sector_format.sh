#!/bin/bash

# Function to format a device
format_device() {
    local device=$1
    echo "Formatting $device..."
    nohup sg_format --format --size=512 -Q $device > /dev/null 2>&1 &
}

# Loop through the devices starting at /dev/sdb
for device in /dev/sd{b..y}; do
    if [ -b $device ]; then
        format_device $device
    else
        echo "$device does not exist - skipping."
        #break
    fi
done

echo "Formatting processes have been started for all available devices."

