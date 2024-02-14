#!/bin/sh

getDefaultSink() {
    defaultSink=$(pactl info | awk -F : '/Default Sink:/{print $2}')
    description=$(pactl list sinks | sed -n "/${defaultSink}/,/Description/s/^\s*Description: \(.*\)/\1/p")
    echo "${description}"
}

getDefaultSource() {
    defaultSource=$(pactl info | awk -F : '/Default Source:/{print $2}')
    description=$(pactl list sources | sed -n "/${defaultSource}/,/Description/s/^\s*Description: \(.*\)/\1/p")
    echo "${description}"
}

VOLUME=$(pamixer --get-volume-human | tr -d '%')
SINK=$(getDefaultSink)
SOURCE=$(getDefaultSource)

case $1 in
    "--up")
        pamixer --increase 2
        ;;
    "--down")
        pamixer --decrease 2
        ;;
    "--mute")
        pamixer --toggle-mute
        ;;
    *)
        # Define the icons
        ICON_MUTED="󰝟"
        ICON_LOW=""      # Assuming volume < 33%
        ICON_MEDIUM="󰕾"   # Assuming volume between 33% and 66%
        ICON_HIGH=""     # Assuming volume > 66%


        # Determine the appropriate icon based on the volume and mute status
        if [ "$VOLUME" = "muted" ]; then
            # Construct and echo the final output
            echo "${ICON_MUTED}"
        elif [ $VOLUME -lt 33 ]; then
            # Construct and echo the final output
            echo "${ICON_LOW} ${VOLUME}%"
        elif [ $VOLUME -lt 66 ]; then
            # Construct and echo the final output
            echo "${ICON_MEDIUM} ${VOLUME}%"
        else
            echo "${ICON_HIGH} ${VOLUME}%"
        fi

        
esac