#!/usr/bin/osascript

# Raycast Script Command Template
#
# Duplicate this file and remove ".template" from the filename to get started.
# See full documentation here: https://github.com/raycast/script-commands
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Spawn ghost
# @raycast.mode silent
# @raycast.packageName Arpad Scripts
#
# Optional parameters:
# @raycast.icon 👻
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
# Documentation:
# @raycast.description Spawn terminal here
# @raycast.author Arpad
# @raycast.authorURL An URL for one of your social medias

on run argv

tell application "Ghostty"
    if it is running then
        tell application "System Events" to tell process "Ghostty"
            click menu item "New Window" of menu "File" of menu bar 1
        end tell
    else
        activate
    end if
end tell

-- Wait a moment for the window to be created
delay 0.2

-- Maximize the frontmost Ghostty window
tell application "System Events"
    tell process "Ghostty"
        try
            set frontWindow to front window
            -- Get the visible frame of the main screen (excluding menu bar and dock)
            tell application "Finder"
                set screenBounds to bounds of window of desktop
            end tell
            set position of frontWindow to {0, 0}
            set size of frontWindow to {item 3 of screenBounds, item 4 of screenBounds}
        end try
    end tell
end tell

log "spawned"

end run
