# CAN toolboard configuration

The active printer profile uses one USB-CAN bridge and four Toolhead v3 boards.
The Duet2 remains responsible for motion, the bed, the coupler, and tool
detection. The DueX E5/E6 outputs drive the controller fan and case LED.
Extruders, hotend heaters, hotend fans, and part-cooling fans are assigned to
the CAN toolboards.

## Installed CAN UUIDs

The USB-CAN bridge UUID is `28f4296c4844`. The toolboards are installed in
physical ID order, with Toolboard 01 assigned to T0 through Toolboard 04
assigned to T3:

| MCU section | Toolboard ID | CAN UUID | Physical tool |
| --- | --- | --- | --- |
| `usb_bridge` | — | `28f4296c4844` | USB-CAN Bridge v2 |
| `tool0` | 01 | `3fc4f7b9fe99` | T0 Toolhead v3 |
| `tool1` | 02 | `a9c8770a4f5f` | T1 Toolhead v3 |
| `tool2` | 03 | `89622ad13c37` | T2 Toolhead v3 |
| `tool3` | 04 | `fb7d25bf3989` | T3 Toolhead v3 |

Discover one unassigned toolboard at a time so its physical tool number cannot
be confused with another board:

```bash
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
```

The CAN interface must use a bitrate of 1 Mbit/s. Configure the host with
`allow-hotplug` because the bridge temporarily removes `can0` when it resets or
enters its bootloader.

## Toolboard assignments

Every tool uses the same Toolhead v3 pin map:

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

All four Orbiter 2.0 extruders start with `rotation_distance: 4.637` and
`run_current: 0.72`. Confirm direction with a short, cold extruder move. Reverse
the relevant `dir_pin` polarity if required; do not rearrange configuration
names because KTCC depends on `extruder`, `extruder1` through `extruder3`.

The filament macros now use one direct-drive profile for all four tools. Their
default paths are documented in the main README. T0 and T1 pressure advance
values are intentionally reset to zero until those converted tools are tuned.

## First configuration checks

After installing the toolboards, restart Klipper with heaters cold and inspect
the log before commanding any outputs:

```bash
sudo systemctl restart klipper
journalctl -u klipper -n 100 --no-pager
ip -details -statistics link show can0
```

For each tool in turn:

1. Confirm its PT1000 reading is close to room temperature.
2. Run `DUMP_TMC STEPPER=extruderN` and confirm UART communication. For T0,
   use `STEPPER=extruder` without a number.
3. With heaters off and no filament loaded, use a short forced move to check
   direction without defeating the configured cold-extrusion limit globally:

   ```gcode
   FORCE_MOVE STEPPER=extruderN DISTANCE=2 VELOCITY=2 ACCEL=20
   ```

   Use `STEPPER=extruder` for T0. Reverse only that tool's `dir_pin` polarity if
   positive movement turns the Orbiter in the wrong direction.
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

   Again, omit `N` for T0.
6. Heat at a low target while attended, then run PID calibration for that
   extruder before normal printing.

The PID values retained in the branch are startup values from the previous
configuration. They are not a substitute for calibration after changing the
heater output and temperature-input electronics.
