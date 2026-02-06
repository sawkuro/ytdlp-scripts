#!/bin/bash

# --- CONFIG ---
# choose where all the accounts will be
BASE_DIR="$HOME/archive/g"
# cookies file
COOKIE_PATH="$HOME/archive/cookies.txt"
# start date if you want
START_DATE="20260105"
ERROR_LOG="$HOME/archive/sync_errors.log"

echo "--- Sync Started: $(date) ---" > "$ERROR_LOG"

cd "$BASE_DIR" || exit

for DIR in */; do
    DIR=${DIR%/} 
    # Extract ID from [brackets]
    USER_ID=$(echo "$DIR" | grep -oP '\[\K[0-9]+(?=\]$)')
    
    if [ -z "$USER_ID" ]; then continue; fi

    echo ">>> Checking: $DIR"
    cd "$DIR" || continue

    # Optimized Sync
    yt-dlp --cookies "$COOKIE_PATH" \
           --download-archive "downloaded.txt" \
           --dateafter "$START_DATE" \
           --break-on-reject \
           --lazy-playlist \
           --sleep-interval 5 \
           --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
           "https://www.tiktok.com/@$USER_ID"

    if [ $? -ne 0 ]; then
        echo "FAILED: $DIR" >> "$ERROR_LOG"
    fi

    cd "$BASE_DIR"
done

echo "Update finished. Errors logged to $ERROR_LOG"
