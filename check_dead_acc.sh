#!/bin/bash

# --- CONFIG ---
ERROR_LOG="$HOME/archive/sync_errors.log"

if [ ! -f "$ERROR_LOG" ]; then
    echo "No error log found at $ERROR_LOG"
    echo "Run date_forward.sh first to generate the log."
    exit 1
fi

echo "Accounts that failed in last sync:"
echo "====================================="
echo ""

# Show accounts that were skipped or had errors
grep "\[SKIP\]\|\[ERROR\]" "$ERROR_LOG" | sort | uniq

echo ""
echo "---"
echo "Review these accounts and consider removing their folders if they're permanently gone."
echo "Failed accounts remain in your archive until manually removed."
