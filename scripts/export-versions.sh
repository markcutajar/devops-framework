#!/bin/bash

for file in versions/*; do
    if [ -f "$file" ]; then  # Ensure it's a file and not a directory
        content=$(cat "$file")
        filename=$(basename "$file")

        # Export the variable
        export "$filename=$content"
        echo "$filename $content"
    fi
done
