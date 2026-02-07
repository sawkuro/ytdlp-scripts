#!/bin/bash

# --- CONFIG ---
BASE_DIR="$HOME/archive/g"
COOKIE_PATH="$HOME/archive/farmer.txt"
INPUT_LIST="new_users.txt"  # Create this file with one username per line

# Check if input list exists
if [ ! -f "$INPUT_LIST" ]; then
    echo "Error: $INPUT_LIST not found. Create it with one username per line."
    exit 1
fi

mkdir -p "$BASE_DIR"

while IFS= read -r USERNAME || [ -n "$USERNAME" ]; do
    # Clean username
    USERNAME=$(echo "$USERNAME" | sed 's/@//g' | xargs)
    [ -z "$USERNAME" ] && continue

    echo "----------------------------------------"
    echo "Processing: @$USERNAME"

    # 1. Fetch ID
    USER_ID=$(yt-dlp --cookies "$COOKIE_PATH" --print "%(uploader_id)s" --playlist-items 1 "https://www.tiktok.com/@$USERNAME" 2>/dev/null | head -n 1)

    if [[ -n "$USER_ID" && "$USER_ID" =~ ^[0-9]+$ ]]; then
        TARGET_DIR="$BASE_DIR/$USERNAME [$USER_ID]"
        mkdir -p "$TARGET_DIR"
        
        echo "Creating: $USERNAME [$USER_ID]"
        cd "$TARGET_DIR" || continue

        # 2. Initial Download (Full Archive)
        yt-dlp --cookies "$COOKIE_PATH" \
               --download-archive "downloaded.txt" \
               --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
               "https://www.tiktok.com/@$USER_ID"
        
        cd "$BASE_DIR"
        
        # Small delay to avoid rate limiting
        sleep 2
    else
        echo "FAILED: Could not find ID for $USERNAME"
    fi
done < "$INPUT_LIST"

echo "Bulk add complete!"
