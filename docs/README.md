# Resonance Testing Commands

```
TEST_RESONANCES AXIS=X NAME=t0
TEST_RESONANCES AXIS=Y NAME=t0
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t0.csv -o /tmp/shaper_calibrate_t0_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t0.csv -o /tmp/shaper_calibrate_t0_y.png

TEST_RESONANCES AXIS=X NAME=t1
TEST_RESONANCES AXIS=Y NAME=t1
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t1.csv -o /tmp/shaper_calibrate_t1_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t1.csv -o /tmp/shaper_calibrate_t1_y.png

TEST_RESONANCES AXIS=X NAME=t2
TEST_RESONANCES AXIS=Y NAME=t2
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t2.csv -o /tmp/shaper_calibrate_t2_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t2.csv -o /tmp/shaper_calibrate_t2_y.png

TEST_RESONANCES AXIS=X NAME=t3
TEST_RESONANCES AXIS=Y NAME=t3
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t3.csv -o /tmp/shaper_calibrate_t3_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t3.csv -o /tmp/shaper_calibrate_t3_y.png

# batch processing
for f in /tmp/resonances*.csv; do
  ~/klipper/scripts/calibrate_shaper.py $f -o /tmp/shaper_calibrate_$(basename /tmp/resonances_x_t0_d.csv .csv | cut -b12-).png && \
  rm -fv $f
done

```

# Input Shaper

```
SET_INPUT_SHAPER SHAPER_FREQ_X=75.8 SHAPER_FREQ_Y=50.6 SHAPER_TYPE_X=mzv SHAPER_TYPE_Y=mzv
```

# Retraction Tunine

```
TUNING_TOWER COMMAND=SET_RETRACTION PARAMETER=RETRACT_LENGTH START=1.0 STEP_DELTA=0.4 STEP_HEIGHT=5
TUNING_TOWER COMMAND=SET_RETRACTION PARAMETER=RETRACT_LENGTH START=0.1 STEP_DELTA=0.2 STEP_HEIGHT=5
```

# Pressure Advance Testing Commands

## Bowden

```
TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.020
```

## Direct

```
TUNING_TOWER COMMAND=SET_PRESSURE_ADVANCE PARAMETER=ADVANCE START=0 FACTOR=.002
```

## Results

| Filament          | Bowden     | Bowden (Metal) | Direct      | Retraction    | Retraction (DDE) | Temp. | Flow   | Comments      |
| ----------------- | ---------- | -------------- | ----------- | ------------- | ---------------- | ----- | ------ | ------------- |
| Pangzi Pink PLA   | -          |                | 0.0414@0.04 |               |                  | 220   |        |               |
| Kexcelled PET-CF  | 0.0000     |                | -           |               |                  | 300   |        |               |
| eSUN PLA Matte    | 0.4336     |                | -           |               |                  | 230   |        |               |
| eSUN PLA          | 0.6300     |                | -           |               |                  | 220   |        |               |
| eSUN eSilk        | 0.7100     |                | -           |               |                  | 210   |        |               |
| eSUN eSilk Color  | 0.7100     | 0.21           | -           |               |                  | 210   |        |               |
| FusRock ABS-GF10  |            | 0.45           | -           |               |                  | 270   |        |               |
| FusRock PA12-CF   |            | 0.0            | -           |               |                  | 280   |        |               |
| Tinmorry PETG-ECO | 1.26       |                | -           | 2.2 / 60 /60  |                  | 230   |        |               |
| eSUN PETG         | 0.54@0.015 | 0.54@0.015     | 0.105@0.04  | 1.4 / 60 /60  | 0.3 / 60 / 60    | 240   | 0.9765 | Max flow 4.0  |
| ICEYUN PETG       | 0.66@0.02  |                | 0.098@0.04  | 1.8 / 60 /60  | 0.44 / 60 /60    | 240   | 0.966  | Max flow 6.0  |
| Yousu PC          |            | 0.44@0.04      |             | 2.0 / 60 / 60 |                  | 300   |        | Max flow 10.0 |

# Notes
