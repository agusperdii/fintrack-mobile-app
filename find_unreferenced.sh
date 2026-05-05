#!/bin/bash
PACKAGE_NAME="savaio"
FILES=$(find lib -name "*.dart" | grep -v "lib/main.dart")

for FILE in $FILES; do
    FILENAME=$(basename $FILE)
    
    # Search for the filename in all .dart files in lib and test, excluding the file itself
    USAGE=$(grep -r "$FILENAME" lib test --include="*.dart" | grep -v "$FILE:")
    
    if [ -z "$USAGE" ]; then
        echo "UNREFERENCED: $FILE"
    fi
done
