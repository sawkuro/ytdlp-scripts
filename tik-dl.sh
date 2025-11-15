#!/bin/bash

# Check if a username was given
if [ -z "$1" ]; then
    echo "Usage: $0 USERNAME"
    exit 1
fi

USERNAME=$1

# Make a directory named after the username
mkdir -p "$USERNAME"

# Change into that directory
cd "$USERNAME" || exit

# Run yt-dlp with the username formatted into the URL
yt-dlp --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" "https://www.tiktok.com/@$USERNAME"

