#!/bin/sh
if [ $# -eq 0 ]; then
    SCRIPT_DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
    installer_log="${SCRIPT_DIR}/install.log"
    echo "$installer_log"
    "$0" "$installer_log" > /dev/null 2>&1 &
    exit 0
fi

installer_log="$1"
rm -f "$installer_log"
echo "Writing output to $installer_log"
i=0
while [ $i -le 100 ]; do
    echo "PROGRESS,$i" >> "$installer_log"
    sleep 0.05
    if [ $i -eq 20 ]; then
        echo "INFO,Doing this" >> "$installer_log"
    elif [ $i -eq 50 ]; then
        echo "INFO,Doing that" >>  "$installer_log"
    elif [ $i -eq 90 ]; then
        echo "INFO,Almost done" >>  "$installer_log"
    fi
    i=$(($i+1))
done
echo "Done"
