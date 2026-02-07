#!/bin/bash

# --- CONFIG ---
BASE_DIR="$HOME/archive/g"
COOKIE_PATH="$HOME/archive/cookies.txt"
LOOKBACK_DAYS=7  # How many days back to check for new videos
ERROR_LOG="$HOME/archive/sync_errors.log"

# Calculate dynamic start date
START_DATE=$(date -d "$LOOKBACK_DAYS days ago" +%Y%m%d)

# Clear previous error log and start fresh
echo "--- Sync Started: $(date) ---" > "$ERROR_LOG"
echo "Checking for videos from the last $LOOKBACK_DAYS days (since $START_DATE)..." | tee -a "$ERROR_LOG"
echo "" >> "$ERROR_LOG"

cd "$BASE_DIR" || exit

for DIR in */; do
    DIR=${DIR%/} 
    # Extract ID from [brackets]
    USER_ID=$(echo "$DIR" | grep -oP '\[\K[0-9]+(?=\]$)')
    
    if [ -z "$USER_ID" ]; then continue; fi

    echo ">>> Checking: $DIR"
    cd "$DIR" || continue

    # Use a unique temp file per user to avoid conflicts
    TEMP_LOG=$(mktemp)
    
    # Run yt-dlp and capture everything
    yt-dlp --cookies "$COOKIE_PATH" \
           --download-archive "downloaded.txt" \
           --dateafter "$START_DATE" \
           --break-on-reject \
           --lazy-playlist \
           --no-warnings \
           --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
           "https://www.tiktok.com/@$USER_ID" > "$TEMP_LOG" 2>&1
    
    EXIT_CODE=$?

    # Decision tree based on exit code + content
    case $EXIT_CODE in
        0)
            # Success - downloaded something or nothing new
            echo "[OK] $DIR"
            ;;
        101)
            # Date rejection triggered (this is expected with --break-on-reject)
            echo "[OK] $DIR (No new videos since $START_DATE)"
            ;;
        *)
            # Something failed - figure out what
            if grep -q "Unable to extract" "$TEMP_LOG"; then
                echo "[SKIP] $DIR - Account inaccessible (private/banned)" | tee -a "$ERROR_LOG"
            elif grep -q "not found\|doesn't exist" "$TEMP_LOG"; then
                echo "[SKIP] $DIR - Account deleted" | tee -a "$ERROR_LOG"
            else
                # Unknown error - log it with context
                echo "[ERROR] $DIR - Unknown failure (exit $EXIT_CODE)" | tee -a "$ERROR_LOG"
                echo "  Last error:" >> "$ERROR_LOG"
                grep "ERROR:" "$TEMP_LOG" | tail -1 >> "$ERROR_LOG"
            fi
            ;;
    esac

    rm -f "$TEMP_LOG"
    cd "$BASE_DIR"
    
    # Small delay to avoid rate limiting
    sleep 2
done

echo "----------------------------------------"
echo "Sync complete. Check $ERROR_LOG for issues."
