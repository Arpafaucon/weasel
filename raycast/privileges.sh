#!/bin/bash

# toggle-privileges.sh
# Silently toggles admin privileges using PrivilegesCLI from the Privileges app.
# No prompts, no output.

PRIV_CLI="/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI"

# Get current privilege status silently
STATUS="$("$PRIV_CLI" -s 2>&1)"

# Toggle based on current status
if echo "$STATUS" | grep -q "administrator"; then
    "$PRIV_CLI" -r #>/dev/null 2>&1
elif echo "$STATUS" | grep -q "standard"; then
    "$PRIV_CLI" -a #>/dev/null 2>&1
fi

# Exit quietly
exit 0
