# Toolhead v3 pin mapping

This document describes the Toolhead v3 board used by migrated tools. T2 is
active first; the same layout is prepared for the other tools. It is the local
reference for the pins in `tool0.cfg` through `tool3.cfg`. The mapping was
checked against the Toolhead v3 hardware design; archived v1/v2 boards are not
compatible references.

The names `PA0`, `PA6`, and similar are STM32 signal names, not wiring points
for external loads. Connect heaters, fans, the motor, and the temperature
sensor to their labeled board connectors or solder pads.

## Per-tool MCU prefix

Every physical board has the same local pins. Klipper distinguishes the four
boards by placing the MCU name before the pin:

| Tool | MCU prefix example | Extruder object | Part-fan object |
| --- | --- | --- | --- |
| T0 | `tool0:PA8` | `extruder` | `part_fan_0` |
| T1 | `tool1:PA8` | `extruder1` | `part_fan_1` |
| T2 | `tool2:PA8` | `extruder2` | `part_fan_2` |
| T3 | `tool3:PA8` | `extruder3` | `part_fan_3` |

For example, `tool2:PA8` means PA8 on the T2 toolboard. It does not refer to a
pin on the Duet2 or another toolboard.

## Configured load and sensor pins

| Board connection | Circuit | STM32/TMC pin | Klipper setting | Function |
| --- | --- | --- | --- | --- |
| J4 motor pads | TMC2209 | `PD0` | `step_pin` | Advances the Orbiter motor by step pulses |
| J4 motor pads | TMC2209 | `PD1` | `dir_pin: !...PD1` | Selects motor direction; `!` inverts the signal |
| J4 motor pads | TMC2209 | `PD2` | `enable_pin: !...PD2` | Enables the driver; active-low, so `!` is required |
| TMC2209 UART | TMC2209 | `PA15` | `uart_pin` | Driver configuration, status, and diagnostics |
| J5 heater pads | Heater MOSFET | `PA8` | `heater_pin` | PWM control for the 24 V hotend heater output |
| J6 fan pads / Fan 0 | Fan MOSFET | `PA6` | `heater_fan hotend_fan_N` | Automatic 24 V hotend-cooling fan |
| J7 fan pads / Fan 1 | Fan MOSFET | `PA7` | first `multi_pin` member | First 24 V part-cooling fan |
| J8 fan pads / Fan 2 | Fan MOSFET | `PB0` | second `multi_pin` member | Second 24 V part-cooling fan |
| J9 sensor pads | Analog input | `PA0 / ADC_IN0` | `sensor_pin` | Reads the two-wire PT1000 hotend sensor |

J5-J8 are low-side switched 24 V outputs: the board supplies 24 V to the load
and switches its return through a MOSFET. Follow the PCB silkscreen and v3
schematic for physical pad polarity; do not infer pad order from MCU pin names.

The J9 temperature input has a 2.2 kOhm precision pull-up on the board. The
Klipper configuration therefore uses:

```ini
sensor_type: PT1000
sensor_pin: toolN:PA0
pullup_resistor: 2200
```

Replace `toolN` with the correct MCU name. A PT1000 has no polarity, but its
wires must go only to the J9 sensor pads.

## Fan behavior

Fan 0 on J6 is configured as a `heater_fan`. It starts automatically at full
speed when its hotend is at or above 40°C, or while that heater has a nonzero
target. It remains independent for each tool.

Fan 1 and Fan 2 on J7/J8 are combined into one Klipper `multi_pin`:

```ini
[multi_pin toolN_part_fans]
pins: toolN:PA7, toolN:PB0
```

KTCC controls the resulting `part_fan_N` object. Both physical part-cooling
fans therefore receive the same PWM duty cycle. They cannot be commanded at
different speeds with the current configuration.

## Communication, programming, and reserved pins

These pins are part of the board design but are not configured as printer
loads in `tool0.cfg` through `tool3.cfg`:

| Board connection/function | STM32 pin | Purpose |
| --- | --- | --- |
| J2 CAN input through transceiver | `PA11` | CAN receive |
| J2 CAN input through transceiver | `PA12` | CAN transmit |
| J3 SWD data | `PA13` | Initial firmware programming and recovery |
| J3 SWD clock / BOOT0 | `PA14` | Initial firmware programming and boot selection |
| J3 reset | `PF2-NRST` | Hardware reset during programming/recovery |
| Crystal | `PF0`, `PF1` | 16 MHz MCU clock; not available for I/O |
| Explicit no-connect | `PB8`, `PB9` | Unused alternate CAN pins; do not assign |

J2 carries 24 V, ground, CAN high, and CAN low through the XT30 2+2 connector.
The board firmware uses CAN at 1 Mbit/s. CAN termination is a hardware choice:
the optional on-board 120-ohm resistor should be fitted only when that board is
physically at an end of the CAN bus.

## Direction and safety checks

- Keep `enable_pin` inverted. Removing `!` changes the driver's enable logic.
- If an Orbiter turns backward, change only that tool's `dir_pin` between
  `toolN:PD1` and `!toolN:PD1` after an attended direction test.
- Confirm the PT1000 reports a sensible room temperature before enabling J5.
- Confirm J6 with the automatic hotend-fan test, then confirm J7 and J8 both
  track a low `part_fan_N` duty cycle before normal operation.
- Do not reuse SWD, crystal, CAN, or explicit no-connect pins for accessories.
- The checked-in heater PID values require calibration on each assembled tool.

For UUID assignment and first-start commands, see
[`../docs/can-toolboards.md`](../docs/can-toolboards.md).
