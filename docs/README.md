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

| Filament         | Bowden | Bowden (Metal) | Direct | Retraction | Temp. | Comments |
| ---------------- | ------ | -------------- | ------ | ---------- | ----- | -------- |
| Pangzi Pink PLA  | -      |                | 0.0414 |            | 220   |          |
| Kexcelled PET-CF | 0.0000 |                | -      |            | 300   |          |
| eSUN PLA Matte   | 0.4336 |                | -      |            | 230   |          |
| eSUN PLA         | 0.6300 |                | -      |            | 220   |          |
| eSUN eSilk       | 0.7100 |                | -      |            | 210   |          |
| eSUN eSilk Color | 0.7100 | 0.21           | -      |            | 210   |          |
| FusRock ABS-GF10 |        | 0.45           | -      |            | 270   |          |
| FusRock PA12-CF  |        | 0.0            | -      |            | 280   |          |

# Notes
