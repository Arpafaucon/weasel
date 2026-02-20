#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rode
# change below to fullOutput for debug
# @raycast.mode silent
# @raycast.packageName Arpad Scripts
#
# Optional parameters:
# @raycast.icon ✏️
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
# @raycast.argument1 { "type": "text", "placeholder": "where" }
# ]}

# Execute the binary with the provided argument
/Users/gregoire.roussel/dev/weasel/raycast-code/target/release/raycast-code "$1"
