#!/bin/bash
process_directory() {
    local dir=$1
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            echo "$file"
        elif [ -d "$file" ]; then
            process_directory "$file"
        fi
    done
}
# Test with current directory
process_directory .
