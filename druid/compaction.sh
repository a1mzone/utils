#!/bin/bash

# Check if a file argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_with_sources>"
    exit 1
fi

# File containing data source names
SOURCE_FILE="$1"

# Loop through each line in the file
while IFS= read -r source || [[ -n "$source" ]]; do
    echo "Processing dataSource: $source"
    
    # Perform the curl request and capture the HTTP status code
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        'http://192.168.0.38:8888/druid/coordinator/v1/config/compaction' \
        --compressed \
        -X POST \
        -H 'Content-Type: application/json' \
        -H 'Authorization: Basic ZHJ1aWRfc3lzdGVtOjZLM1A1c0tjM0ZtcjNl' \
        --data-raw "{\"dataSource\":\"${source}\",\"tuningConfig\":{\"partitionsSpec\":{\"type\":\"dynamic\"}}}")

    echo "HTTP Status Code: $HTTP_STATUS"
done < "$SOURCE_FILE"
