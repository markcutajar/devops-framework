#!/bin/bash

# Check for the required input parameters
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [ENV_FILE] [NEW_VALUE]"
    exit 1
fi

# The file to update (first parameter)
ENV_FILE="$1"

# The key to update
KEY="VERSION"

# The new value (second parameter)
NEW_VALUE="$2"

# Check if the key exists in the file
if grep -q "^$KEY=" "$ENV_FILE"; then
    # Key exists, update it
    sed -i "s/^$KEY=.*/$KEY=$NEW_VALUE/" "$ENV_FILE"
else
    # Key doesn't exist, add it
    echo "$KEY=$NEW_VALUE" >> "$ENV_FILE"
fi

echo "Updated $KEY in $ENV_FILE to $NEW_VALUE"
