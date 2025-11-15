#!/bin/bash

# --- Configuration Section ---

# Base folder where TikTok directories will be created and videos stored.
# Using '$HOME' ensures this works on any Linux/macOS system for the current user.
BASE_DIR="$HOME/TikTok_Downloads"

# Maximum videos to download if an archive file already exists (for updates).
RECENT_LIMIT=10

# Default: Download all videos (up to this limit) if no archive is found (first run).
FULL_LIMIT=500

# --- Function for Single User Download ---

# Function: process_tiktok_user
# Arguments: $1 = The TikTok username to process
process_tiktok_user() {
    local USERNAME=$1
    local ARCHIVE_FILE="downloaded.txt"
    local DOWNLOAD_LIMIT=$FULL_LIMIT

    echo "--- Processing User: **$USERNAME** ---"

    # Create the user's directory inside the BASE_DIR
    mkdir -p "$BASE_DIR/$USERNAME"
    
    # Change into that specific user's directory
    cd "$BASE_DIR/$USERNAME" || { echo "ERROR: Could not enter directory $BASE_DIR/$USERNAME"; return 1; }
    
    # Check if the archive file exists AND has content (is not empty)
    if [ -s "$ARCHIVE_FILE" ]; then
        # Archive file found: Limit the download to the most recent videos.
        DOWNLOAD_LIMIT=$RECENT_LIMIT
        echo "Archive '$ARCHIVE_FILE' found. Limiting download to **$DOWNLOAD_LIMIT** most recent videos (Update Mode)."
    else
        # Archive file does not exist or is empty: Download the full account.
        echo "No existing archive or archive is empty. Downloading up to **$DOWNLOAD_LIMIT** videos (Full Download Mode)."
    fi

    # Execute yt-dlp with the determined limit and archive file
    yt-dlp --download-archive "$ARCHIVE_FILE" \
           --max-downloads "$DOWNLOAD_LIMIT" \
           --output "%(uploader)s - %(upload_date)s - %(title)s [%(id)s].%(ext)s" \
           "https://www.tiktok.com/@$USERNAME"
    
    # Return to the previous directory (optional, but good practice)
    # Since this is the end of the script execution, we can skip an explicit 'cd' back.
}

# --- Main Script Execution ---

# 1. Check if a username was given as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 **<TIKTOK_USERNAME>**"
    echo "Example: $0 exampleuser"
    exit 1
fi

# 2. Call the function with the provided username
process_tiktok_user "$1"

echo "----------------------------------------"
echo "Download process complete for $1."
