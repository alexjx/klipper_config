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

| Filament         | Bowden | Direct |
| ---------------- | ------ | ------ |
| Pangzi Pink PLA  | -      | 0.0414 |
| Kexcelled PET-CF | 0.0000 | -      |
| eSUN PLA Matte   | 0.4336 | -      |
| eSUN PLA         | 0.4400 | -      |
| eSUN eSilk       | 0.5900 | -      |

# Notes

1. `duex.fan7` is broken
2. `driver x` is broken
3. `driver y` is broken
