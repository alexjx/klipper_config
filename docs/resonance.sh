#!/bin/bash
set -ex

for f in /tmp/resonances*.csv /tmp/calibration_data_*.csv; do
  if [ !-e $f ]; then
    continue
  fi
  ~/klipper/scripts/calibrate_shaper.py $f -o /tmp/shaper_calibrate_$(basename $f .csv | cut -b12-).png && \
  rm -fv $f
done
