# CAN toolboard configuration

The printer profile enables its USB-CAN bridge and T2 Toolhead v3 board; T3 is
currently disabled. The original Duet2 and DueX5 remain installed:
T0 and T1 still use them, while the old T2/T3 wiring has been removed. The
Duet2/DueX5 pair remains responsible for motion, the bed, the coupler, and tool
detection. Hardware selection is centralized in `toolboards/toolheads.cfg`;
only enabled CAN boards must be online.

## Installed CAN UUIDs

The USB-CAN bridge UUID is `28f4296c4844`. The recorded board mapping follows
physical ID order. T2 is active and T3 is prepared but disabled:

| MCU section | Toolboard ID | CAN UUID | Physical tool | Current state |
| --- | --- | --- | --- | --- |
| `usb_bridge` | — | `28f4296c4844` | USB-CAN Bridge v2 | enabled |
| `tool0` | 01 | `3fc4f7b9fe99` | future T0 Toolhead v3 | not used |
| `tool1` | 02 | `a9c8770a4f5f` | future T1 Toolhead v3 | not used |
| `tool2` | 03 | `89622ad13c37` | T2 Toolhead v3 | enabled |
| `tool3` | 04 | `fb7d25bf3989` | T3 Toolhead v3 | disconnected/disabled |

## Current and planned connections

| Tool | Connection board | Power/data | Motor | Heater | Sensor | Fans |
| --- | --- | --- | --- | --- | --- | --- |
| T2 active | Toolboard 03 | `J2`: 24 V, GND, CANH, CANL | `J4` | `J5` | PT1000 on `J9` | hotend `J6`; paired part fans `J7`/`J8` |
| T3 planned | Toolboard 04 | `J2`: 24 V, GND, CANH, CANL | `J4` | `J5` | PT1000 on `J9` | hotend `J6`; paired part fans `J7`/`J8` |

The former T2 DueX5 connections (`E2 MOTOR/HEAT/TEMP`, `FAN5/FAN6`) and T3
DueX5 connections (`E3 MOTOR/HEAT/TEMP`, `FAN7/FAN8`) are disconnected and
must remain unused.

After T3 is physically connected and its UUID is confirmed, enable its matching
hardware line in `toolboards/toolheads.cfg`:

```ini
[include tool3.cfg]
```

Then uncomment `[include tool3.cfg]` at the end of `tools/tools.cfg`. Keeping
the logical include there ensures KTCC's shared tool modules load first.

Discover one unassigned toolboard at a time so its physical tool number cannot
be confused with another board:

```bash
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

The CAN interface must use a bitrate of 1 Mbit/s. Configure the host with
`allow-hotplug` because the bridge temporarily removes `can0` when it resets or
enters its bootloader.

## Toolboard assignments

Every migrated tool uses the same Toolhead v3 pin map:

| Function | Pin |
| --- | --- |
| Extruder step / direction / enable | `PD0` / `PD1` / `PD2` |
| TMC2209 UART | `PA15` |
| Heater | `PA8` |
| PT1000 input | `PA0`, 2.2 kOhm pull-up |
| Hotend fan | `PA6` |
| Paired part-cooling fans | `PA7` and `PB0` |

The two part-cooling outputs are joined logically with Klipper `multi_pin`.
KTCC therefore continues to see one `part_fan_N` object per tool and commands
both physical fans at the same speed.

Each migrated Orbiter 2.0 extruder starts with `rotation_distance: 4.637` and
`run_current: 0.72`. Confirm direction with a short, cold extruder move. Reverse
the relevant `dir_pin` polarity if required; do not rearrange configuration
names because KTCC depends on `extruder`, `extruder1` through `extruder3`.

The filament macros keep per-tool path lengths: T0/T1 retain their original
long paths and T2/T3 use direct-drive defaults. Their values are documented in
the main README. Existing T0/T1 pressure-advance values remain unchanged.

## First configuration checks

After installing the toolboards, restart Klipper with heaters cold and inspect
the log before commanding any outputs:

```bash
sudo systemctl restart klipper
journalctl -u klipper -n 100 --no-pager
ip -details -statistics link show can0
```

For each newly connected CAN tool in turn:

1. Confirm its PT1000 reading is close to room temperature.
2. Run `DUMP_TMC STEPPER=extruderN` and confirm UART communication, using
   `extruder2` for T2 and `extruder3` for T3.
3. With heaters off and no filament loaded, use a short forced move to check
   direction without defeating the configured cold-extrusion limit globally:

   ```gcode
   FORCE_MOVE STEPPER=extruderN DISTANCE=2 VELOCITY=2 ACCEL=20
   ```

   Reverse only that tool's `dir_pin` polarity if positive movement turns the
   Orbiter in the wrong direction.
4. Test the paired part fans and confirm both physical fans track the same
   requested speed:

   ```gcode
   SET_FAN_SPEED FAN=part_fan_N SPEED=0.5
   SET_FAN_SPEED FAN=part_fan_N SPEED=0
   ```

5. Test the automatic hotend fan without heating. First confirm the displayed
   hotend temperature is above 5 C, then set a nonzero target below the current
   temperature. The heater remains off while the automatic fan starts:

   ```gcode
   SET_HEATER_TEMPERATURE HEATER=extruderN TARGET=5
   SET_HEATER_TEMPERATURE HEATER=extruderN TARGET=0
   ```

6. Heat at a low target while attended, then run PID calibration for that
   extruder before normal printing.

The PID values retained in the branch are startup values from the previous
configuration. They are not a substitute for calibration after changing the
heater output and temperature-input electronics.
