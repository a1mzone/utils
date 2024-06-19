#!/bin/bash

# Loop through devices
for device in {o..p}; do
    dev_path="/dev/sd${device}"

    # Check if the device exists
    if [ -e "$dev_path" ]; then
	    echo ""
	    echo "----------------------------------"
    	    echo "Formatting $dev_path"
	    echo "----------------------------------"

        # Use fdisk to create a new GPT disklabel and a new partition
        (
            echo g      # Create a new GPT partition table
            echo n      # Add a new partition
            echo 1      # Partition number 1
            echo        # Default - start at beginning of disk
            echo        # Default - extend partition to end of disk
            echo w      # Write changes
        ) | fdisk "$dev_path"

        # Wait for a moment to ensure the partition table is updated
        sleep 2

        # Format the new partition with ext4 filesystem
        mkfs.ext4 "${dev_path}1"

        echo "$dev_path has been partitioned and formatted."
    else
        echo "$dev_path does not exist. Skipping..."
    fi
done

echo "All specified devices have been processed."

