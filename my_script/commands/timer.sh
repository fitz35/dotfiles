#!/usr/bin/env bash
# Countdown of the polybar timer module : `my_script timer <add [seconds]|toggle|reset|display>`
# add : add (or remove, if negative) seconds to the countdown (1 by default, polybar scroll uses +5 / -5),
# toggle : start / pause, reset : back to BASE_TIME, display : print MM:SS, then blink END / !-! when finished.
# The state is kept in /tmp files, so it is lost at reboot.

BASE_TIME=60 # in seconds

TIMER_FILE="/tmp/polybar_timer" # This file will be used to check if the timer is running (and keep track of the start time)
ELAPSED_FILE="/tmp/polybar_timer_elapsed" # This file will be used to keep track of the elapsed time (pause doesn't reset the timer)
END_DISPLAYED_FILE="/tmp/polybar_timer_end_displayed" # This file will be used to keep track of whether "END" was last displayed

source "$MY_SCRIPT_DIR/lib.sh"

# create elapsed file if it doesn't exist
if [ ! -f "$ELAPSED_FILE" ]; then
    echo "$BASE_TIME" > "$ELAPSED_FILE"
fi

case "$1" in
    add)
        if [ -f "$ELAPSED_FILE" ]; then
            if [ "$#" -ge 2 ]; then
                second_argument="$2"
            else
                second_argument="1"
            fi
            previous_elapsed=$(cat "$ELAPSED_FILE")
            total_elapsed=$((previous_elapsed + second_argument))
            if [ "$total_elapsed" -lt 0 ]; then
                echo "0" > "$ELAPSED_FILE"
                echo -n "00:00"
            else
                echo "$total_elapsed" > "$ELAPSED_FILE"
                format_time $total_elapsed 
            fi
        else
            echo "A problem occured"
            exit 1
        fi

    ;;

    toggle)
        if [ -f "$TIMER_FILE" ]; then
            # If the timer is running, stop it and save the elapsed time
            start_time=$(cat "$TIMER_FILE")
            current_time=$(date +%s)
            elapsed=$((current_time - start_time))
            
            # If there's already saved elapsed time, add to it
            if [ -f "$ELAPSED_FILE" ]; then
                previous_elapsed=$(cat "$ELAPSED_FILE")
                total_elapsed=$(( previous_elapsed - elapsed))
                if [ "$total_elapsed" -lt 0 ]; then
                    echo "0" > "$ELAPSED_FILE"
                else
                    echo "$total_elapsed" > "$ELAPSED_FILE"
                fi
            else
                # this case is not possible (normally)
                echo "A problem occured"
                exit 1
            fi
            
            # Remove the timer file (i.e. stop the timer)
            rm -f "$TIMER_FILE"
        else
            # If the timer is not running, start it
            # (i.e. save the current time in the timer file)
            date +%s > "$TIMER_FILE"
        fi
        ;;
    reset)
        # Reset the timer by removing timer file
        # and set the elapsed file to a default value
        rm -f "$END_DISPLAYED_FILE"
        rm -f "$TIMER_FILE"
        echo "$BASE_TIME" > "$ELAPSED_FILE"
        ;;
    display)
        # Display the elapsed time
        if [ -f "$TIMER_FILE" ]; then
            # If the timer is running, calculate the elapsed time
            start_time=$(cat "$TIMER_FILE")
            current_time=$(date +%s)
            elapsed=$((current_time - start_time))
            
            # If there's saved elapsed time, add to it
            if [ -f "$ELAPSED_FILE" ]; then
                previous_elapsed=$(cat "$ELAPSED_FILE")
                total_elapsed=$((previous_elapsed - elapsed))
                if [ "$total_elapsed" -lt 0 ]; then
                    if [ -f "$END_DISPLAYED_FILE" ]; then
                        # Toggle between "END" and "---" and update the flag
                        if [ "$(cat "$END_DISPLAYED_FILE")" = "true" ]; then
                            echo "!-!"
                            echo "false" > "$END_DISPLAYED_FILE"
                        else
                            echo "END"
                            echo "true" > "$END_DISPLAYED_FILE"
                        fi
                    else
                        # Default to "END" and set the flag
                        echo "END"
                        echo "true" > "$END_DISPLAYED_FILE"
                    fi
                else
                    format_time $total_elapsed
                fi
                
            else
                # this case is not possible (normally)
                echo "A problem occured"
                exit 1
            fi
        elif [ -f "$ELAPSED_FILE" ]; then
            # If the timer is not running, but there's saved elapsed time,
            elapsed=$(cat "$ELAPSED_FILE")
            format_time $elapsed
        else
            # this case is not possible (normally)
            echo "A problem occured"
            exit 1
        fi
        ;;
esac