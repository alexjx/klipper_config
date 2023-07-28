#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ ! -d ~/printer_data/config ]; then
    echo "klipper is not installed"
    exit 1
fi

INSTALL=(
    duet2
    macros
    settings
    tools
    printer_base.cfg
)

cd ~/printer_data/config
for i in "${INSTALL[@]}"; do
    if [ -f "$SCRIPT_DIR/$i" ]; then
        ln -sfv "$SCRIPT_DIR/$i" $i
    fi
done

if [ -e ~/printer_data/config/printer.cfg ]; then
    echo "backing up printer.cfg"
    mv -f ~/printer_data/config/printer.cfg ~/printer_data/config/printer.cfg.bak
fi

cat > ~/printer_data/config/printer.cfg << _EOF
[include printer_base.cfg]
_EOF

echo "Configurations installed."
