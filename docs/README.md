# Resonance Testing Commands

Use [ShakeTune](https://github.com/Frix-x/klippain-shaketune) for optimal results.

# Retraction Tuning Commands

```
TUNING_TOWER COMMAND=SET_RETRACTION PARAMETER=RETRACT_LENGTH START=0.5 STEP_DELTA=0.3 STEP_HEIGHT=5
TUNING_TOWER COMMAND=SET_RETRACTION PARAMETER=RETRACT_LENGTH START=0.1 STEP_DELTA=0.2 STEP_HEIGHT=5
```

## Results

| Filament          | Bowden    | Bowden (Metal) | Direct      | Retraction    | Retraction (DDE) | Temp. | Flow   | Comments      |
| ----------------- | --------- | -------------- | ----------- | ------------- | ---------------- | ----- | ------ | ------------- |
| eSUN eSilk        | 0.7100    |                | -           |               |                  | 210   |        |               |
| eSUN eSilk Color  | 0.7100    | 0.21           | -           |               |                  | 210   |        |               |
| eSUN PETG         | 0.68@0.02 | 0.68@0.02      | 0.105@0.04  | 1.2 / 60 / 60 | 0.4 / 60 / 60    | 240   | 0.9765 | Max flow 6.0  |
| eSUN PLA          | 0.6300    |                | 0.036@0.04  |               |                  | 210   |        |               |
| eSUN PLA Matte    |           |                | 0.03@0.04   |               |                  | 220   |        |               |
| eSUN TPE          |           |                | 0.065@0.04  |               | 2.3 / 60 / 60    | 230   |        | Max flow 4.0  |
| eSUN TPU-95A      |           |                | 0.105@0.04  |               | 2 / 50 / 50      | 230   |        | Max flow 4.0  |
| FusRock ABS-GF10  |           | 0.45           | -           |               |                  | 270   |        |               |
| FusRock PA12-CF   |           | 0.0            | -           |               |                  | 280   |        |               |
| ICEYUN PETG       | 0.66@0.02 |                | 0.084@0.04  | 1.8 / 60 / 60 | 0.44 / 60 /60    | 240   | 0.966  | Max flow 6.0  |
| Kexcelled PET-CF  | 0.0000    |                | -           |               |                  | 300   |        |               |
| Pangzi Pink PLA   | -         |                | 0.0414@0.04 |               |                  | 220   |        |               |
| Pangzi Coffe PLA  | -         |                | 0.046@0.04  |               |                  | 200   |        | Max flow      |
| Tinmorry PETG-ECO | 0.78      |                | -           | 2.2 / 60 / 60 |                  | 240   |        | Max flow 15.0 |
| Zhuopu PETG       |           |                | 0.07@0.04   | 0.4 / 60 / 60 |                  | 245   |        | Max flow 14.0 |
| Yousu PC          |           | 0.44@0.04      |             | 1.6 / 60 / 60 |                  | 300   | 0.97   | Max flow 10.0 |

# Notes
