#!/bin/bash

NEWY=$(ls -Art /tmp/resonances_y_*.csv | tail -n 1)
DATE=$(date +'%Y-%m-%d-%H%M%S')
DIR="/home/xinj/printer_data/config/input_shaper"

if [ -z "$1" ]; then
    NAME=""
else
    NAME="_$1"
fi

if [ ! -d ${DIR} ]; then
    mkdir ${DIR}
fi

~/klipper/scripts/calibrate_shaper.py $NEWY -o ${DIR}/resonances${NAME}_y_${DATE}.png
