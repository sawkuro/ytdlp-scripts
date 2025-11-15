#!/bin/bash

# --- Configuration Section ---

# Base folder where TikTok directories exist.
# Using '$HOME' (or '~') makes this work on any Linux/macOS system for the current user.
# The user running the script must create this directory first (e.g., 'TikTok_Downloads').
# Example: If the user is 'john', this will resolve to /home/john/TikTok_Downloads
BASE_DIR="$HOME/TikTok_Downloads"

# Maximum videos to download if an archive file already exists (for updates).
# Set this to a small number to get only the most recent videos (e.g., 10 or 20).
RECENT_LIMIT=10

# Default: Download all videos (up to this limit) if no archive is found (first run).
# This effectively downloads the "whole account" on the first run.
FULL_LIMIT=500

# --- Script Execution ---

# Create the base directory if it doesn't exist
mkdir -p "$BASE_DIR"

# Go to that folder first
cd "$BASE_DIR" || { echo "Base directory not found: $BASE_DIR. Please check the path."; exit 1; }

echo "Starting TikTok download process in: $BASE_DIR"
echo "----------------------------------------"

# Loop over all subdirectories in the base folder.
# The directories' names are expected to be the TikTok usernames.
for USERNAME in */; do
    USERNAME=${USERNAME%/} # Remove trailing slash
    
    # Skip if the item is not a directory or if it's the base directory itself (less common but safer)
    if [ ! -d "$USERNAME" ]; then
        continue
    fi
    
    echo "Processing **$USERNAME**..."
    
    # Enter the user's directory
    cd "$USERNAME" || { echo "Could not enter directory $USERNAME, skipping."; continue; }
    
    ARCHIVE_FILE="downloaded.txt"
    DOWNLOAD_LIMIT=$FULL_LIMIT

    # Check if the archive file exists AND has content (more than 0 bytes)
    if [ -s "$ARCHIVE_FILE" ]; then
        # Archive file exists and is not empty: Limit the download to the most recent videos.
        DOWNLOAD_LIMIT=$RECENT_LIMIT
        echo "Archive '$ARCHIVE_FILE' found. Limiting download to **$DOWNLOAD_LIMIT** most recent videos."
    else
        # Archive file does not exist or is empty: Download the full account (up to FULL_LIMIT).
        echo "No existing archive or archive is empty. Downloading up to **$DOWNLOAD_LIMIT** videos (full account)."
    fi

    # Execute yt-dlp with the determined limit
    yt-dlp --download-archive "$ARCHIVE_FILE" \
           --max-downloads "$DOWNLOAD_LIMIT" \
           --output "%(uploader)s - %(upload_date)s - %(title)s [%(id)s].%(ext)s" \
           "https://www.tiktok.com/@$USERNAME"

    # Go back to the parent folder ($BASE_DIR)
    cd "$BASE_DIR"
    echo "----------------------------------------"
done

echo "Download process complete."
