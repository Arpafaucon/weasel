#!/usr/bin/env python3

# Raycast Script Command Template

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Code
# change below to fullOutput for debug
# @raycast.mode silent
# @raycast.packageName Arpad Scripts
#
# Optional parameters:
# @raycast.icon ⚙️
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
# @raycast.argument1 { "type": "text", "placeholder": "where" }
# ]}
#
# Documentation:
# @raycast.description Spawn a code terminal in a select subset of repos
# @raycast.author Arpad
# @raycast.authorURL An URL for one of your social medias

import sys

HOME = "/Users/gregoire.roussel"

DICT = {
    "lading": "dd/lading",
    "weasel": "dev/weasel",
    "smp": "dd/single-machine-performance",
    "notes": "notes",
}

inp = sys.argv[1]
matching = [val for key,val in DICT.items() if key.startswith(inp)]
if not len(matching) == 1:
    print(f"No match for {inp} found")
    sys.exit(1)
selected = matching[0]

print(f"{selected}")

import subprocess
subprocess.run(("code", selected))
# print(matching[0])
