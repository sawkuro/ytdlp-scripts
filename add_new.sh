#!/bin/bash

# --- CONFIG ---
BASE_DIR="$HOME/archive/g"
COOKIE_PATH="$HOME/archive/cookies.txt"

# Check if a username was provided
if [ -z "$1" ]; then
    echo "Usage: ./add_new.sh <username>"
    echo "Example: ./add_new.sh adinapp1"
    exit 1
fi

USERNAME=$(echo "$1" | sed 's/@//g') # Remove @ if the user included it

echo ">>> Fetching ID for @$USERNAME..."

# 1. Get the permanent ID
USER_ID=$(yt-dlp --cookies "$COOKIE_PATH" --print "%(uploader_id)s" --playlist-items 1 "https://www.tiktok.com/@$USERNAME" 2>/dev/null | head -n 1)

if [[ -n "$USER_ID" && "$USER_ID" =~ ^[0-9]+$ ]]; then
    echo ">>> Success! ID found: $USER_ID"
    
    # 2. Create the Hybrid Folder
    TARGET_DIR="$BASE_DIR/$USERNAME [$USER_ID]"
    mkdir -p "$TARGET_DIR"
    
    echo ">>> Created folder: $TARGET_DIR"
    cd "$TARGET_DIR" || exit

    # 3. Initial Download (Full Archive)
    echo ">>> Downloading full archive for @$USERNAME..."
    yt-dlp --cookies "$COOKIE_PATH" \
           --download-archive "downloaded.txt" \
           --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
           "https://www.tiktok.com/@$USER_ID"

    echo ">>> Done! @$USERNAME is now part of your archive."
else
    echo ">>> ERROR: Could not find ID for '$USERNAME'. Check if the name is correct or if the account is banned."
    exit 1
fi
