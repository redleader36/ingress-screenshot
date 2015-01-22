#!/bin/sh

# Firefox settings
FF_PROFILE="example"
FF_PROFILE_DIR="et9az2vp.example"
FF_WAIT=42
FF_URL="http://www.ingress.com/intel?ll=49.884386,10.89515&z=14"

# Interval between screenshots
SCREENSHOT_INTERVAL=60

# Dimensions of screenshot (cropped)
SCREENSHOT_WIDTH=3840
SCREENSHOT_HEIGHT=2160

# Crop offset for screenshot
SCREENSHOT_OFFSET_LEFT=220
SCREENSHOT_OFFSET_TOP=220

# Virtual X Server Settings
XVFB_RES_WIDTH=`expr $SCREENSHOT_WIDTH + 2 \* $SCREENSHOT_OFFSET_LEFT`
XVFB_RES_HEIGHT=`expr $SCREENSHOT_HEIGHT + 2 \* $SCREENSHOT_OFFSET_TOP`
XVFB_DISPLAY=23

#Setting for timestamp
TIMESTAMP=true

while getopts ":t" opt; do
    case $opt in
        t)
            TIMESTAMP=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

echo "Staring XVFB on $XVFB_DISPLAY"
Xvfb :${XVFB_DISPLAY} -screen 0 ${XVFB_RES_WIDTH}x${XVFB_RES_HEIGHT}x24 -noreset -nolisten tcp 2> /dev/null &
XVFB_PID=$!

add_timestamp () {
	img_name=$1
	XTEXT=`expr $SCREENSHOT_WIDTH - 50`
	YTEXT=`expr $SCREENSHOT_HEIGHT + 175`
	STRINGTEXT="text $XTEXT,$YTEXT '"
	PRETTY_DATE=`date +"%d-%m-%Y %H:%M:%S"`
	STRINGTEXT="$STRINGTEXT$PRETTY_DATE'"
	convert -pointsize 20 -fill yellow -draw "$STRINGTEXT" $img_name $img_name
}

while true
do
    # Remove parent lock to prevent error message "firefox has been shutdown unexpectly..."
    rm ~/.mozilla/firefox/${FF_PROFILE_DIR}/.parentlock

    # Flush cache to prevent "Reload page" message (this happens anyway, but not that often)
    echo "Flushing cache "
    rm -r ~/.cache/mozilla/firefox/${FF_PROFILE_DIR}/*

    echo "Running firefox -P $FF_PROFILE on $XVFB_DISPLAY "
    DISPLAY=:${XVFB_DISPLAY} firefox -P $FF_PROFILE -width $XVFB_RES_WIDTH -height $XVFB_RES_HEIGHT "$FF_URL" > /dev/null &
    FF_PID=$!

    echo "firefox running o PID $FF_PID"

    echo "Waiting $FF_WAIT seconds before screenshot"
    sleep $FF_WAIT;

    echo "Taking screenshot. Please smile!"
    HAM_DATE1=`date +"%Y-%m-%d"`
    HAM_DATE2=`date +"%H-%M-%S"`
    if [ ! -d "$HAM_DATE1" ]; then
        mkdir $HAM_DATE1
    fi
    HAM_DATE=$HAM_DATE1/$HAM_DATE2
    DISPLAY=:${XVFB_DISPLAY} import -window root -crop ${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}+${SCREENSHOT_OFFSET_LEFT}+${SCREENSHOT_OFFSET_TOP} "$HAM_DATE1/$FF_PROFILE-$HAM_DATE2.png"
    if $TIMESTAMP; then
        add_timestamp $HAM_DATE1/$FF_PROFILE-$HAM_DATE2.png
    fi


    echo "Killing firefox on PID $FF_PID"
    kill $FF_PID

    echo "Waiting $SCREENSHOT_INTERVAL for next screenshot"
    sleep $SCREENSHOT_INTERVAL

done

echo "Killing XVFB on $XVFB_PID"
kill $XVFB_PID
