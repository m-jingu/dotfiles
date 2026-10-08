#!/bin/zsh
# Open files in Quick Look and bring its window to the front.
# qlmanage never activates itself, so its window would open behind the
# terminal. NSRunningApplication needs no Automation permission, unlike
# System Events.
qlmanage -p "$@" >/dev/null 2>&1 &
pid=$!
sleep 0.2
osascript -l JavaScript -e "
ObjC.import('AppKit');
var app = \$.NSRunningApplication.runningApplicationWithProcessIdentifier($pid);
if (!app.isNil()) app.activateWithOptions(\$.NSApplicationActivateIgnoringOtherApps);
" >/dev/null 2>&1
wait $pid
