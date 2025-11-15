#!/bin/bash

# Base folder where TikTok directories exist
BASE_DIR="/home/kc124/archive/g/"

# Go to that folder first
cd "$BASE_DIR" || { echo "Base directory not found: $BASE_DIR"; exit 1; }

# Maximum videos to download if an archive file already exists
# This should be a small number to get only the most recent videos, e.g., 10 or 20
RECENT_LIMIT=10

# Default: Download all videos (or a very high number) if no archive is found
# This effectively downloads the "whole account" on the first run.
# yt-dlp might have its own implicit limits, but this tells it not to stop early.
FULL_LIMIT=500

# Loop over all directories in the base folder
for USERNAME in */; do
    USERNAME=${USERNAME%/}  # remove trailing slash
    echo "Processing $USERNAME..."
    
    # Check if the directory is valid and enter it
    cd "$USERNAME" || { echo "Could not enter directory $USERNAME, skipping."; continue; }
    
    ARCHIVE_FILE="downloaded.txt"
    DOWNLOAD_LIMIT=$FULL_LIMIT

    # Check if the archive file exists AND has content (more than 0 bytes)
    if [ -s "$ARCHIVE_FILE" ]; then
        # Archive file exists and is not empty: Limit the download to the most recent videos.
        DOWNLOAD_LIMIT=$RECENT_LIMIT
        echo "Archive '$ARCHIVE_FILE' found. Limiting download to $DOWNLOAD_LIMIT most recent videos."
    else
        # Archive file does not exist or is empty: Download the full account (up to FULL_LIMIT).
        echo "No existing archive or archive is empty. Downloading up to $DOWNLOAD_LIMIT videos (full account)."
    fi

    # Execute yt-dlp with the determined limit
    yt-dlp --download-archive "$ARCHIVE_FILE" \
           --max-downloads "$DOWNLOAD_LIMIT" \
           --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" \
           "https://www.tiktok.com/@$USERNAME"

    # Go back to the parent folder
    cd "$BASE_DIR"
    echo "----------------------------------------"
done
