#!/bin/bash

# see man zscroll for documentation of the following parameters
zscroll --delay 0.1 \
        -l 10 \
        --scroll-padding "  " \
        --match-command "sh `dirname $0`/get_spotify_status.sh --status" \
        --match-text "Playing" "--scroll 1" \
        --match-text "Paused" "--scroll 0" \
        --update-check true "sh `dirname $0`/get_spotify_status.sh" &

wait
