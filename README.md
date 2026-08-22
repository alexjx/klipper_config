# Klipper Configuration for E3D toolchanger

This configuration depends on following repositories:

1. [Klipper](https://github.com/alexjx/klipper)
2. [Klipper Toolchanger Code](https://github.com/alexjx/Klipper_ToolChanger)

## Credit

- Thanks orignal [Klipper](https://github.com/Klipper3d/klipper)
- Thanks orignal [KTCC](https://github.com/TypQxQ/Klipper_ToolChanger)
- Thanks [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging) for adaptive mesh and purging
- Thanks [KIAUH](https://github.com/dw-0/kiauh) for gcode shell command ([Arksine](https://github.com/Arksine))

## Installation

1. Setup Raspberry PI with MainsailOS
1. Install Klipper with modified repo (this only required for Duet2 WIFI), it may work with original Klipper, but not tested.

    ```bash
    cd ~/klipper
    git remote add alexjx https://github.com/alexjx/klipper.git
    git fetch alexjx
    git checkout -f alexjx/master
    ```

1. Install Klipper ToolChanger Extension

   ```bash
   cd ~
   git clone https://github.com/alexjx/Klipper_ToolChanger.git ktcc
   cd ~/ktcc
   bash install.sh
   ```

1. Install `gcode_shell_command`

   ```bash
   curl -o ~/klipper/klippy/extras/gcode_shell_command.py https://raw.githubusercontent.com/dw-0/kiauh/master/resources/gcode_shell_command.py
   ```

2. Setup Klipper with this repo

    ```bash
    cd ~
    git clone https://github.com/alexjx/klipper_config.git
    cd klipper_config
    bash install.sh
    ```

3. Restart klipper service

    ```bash
    sudo systemctl restart klipper
    ```

## Configuration

1. Follow klipper document, edit `~/klipper_config/duet2/mcu.cfg`, ensure mcu serial device path is correct.
2. Verify the installed toolboard CAN UUIDs in `toolboards/mcu.cfg`.
   See the [CAN toolboard configuration](docs/can-toolboards.md) for the
   Toolboard 01–04 mapping and first-start checks.
3. Edit `~/klipper_config/printer_base.cfg`. Update the settings for your needs.
4. Update other configurations to meet your needs.
   1. I'm using PT1000 for extruder, you might have to change that.
   2. The bed is AC powered, so include a different bed configuration in `printer_base.cfg` if needed.
5. ~~Follow guide from [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging) to setup `[exclude_object]` for KAMP.~~
   Enable file processing for exclude object for adaptive probing and purging.

   - Edit `moonraker.conf` to include object processing

     ```
     [file_manager]
     enable_object_processing: True
     ```

   - Enable object lable in the slicer

6. ~~Update `scripts/generate-belt-tension-graph.sh`, `scripts/generate-shaper-graph-x.sh`, `scripts/generate-shaper-graph-y.sh` to meet your paths.~~
   Prefer https://github.com/Frix-x/klippain-shaketune

7. Measure and update input shaper value for each tool.
8. Update `~/klipper_config/tools/tools.cfg`. The offsets are used for initial tool alignment. Configure them to meet your needs.

## CAN Toolboard Configuration

The local connector and MCU-pin reference is
[`toolboards/pins.md`](toolboards/pins.md).

The active profile uses one USB-CAN bridge and four identical Toolhead v3 CAN
boards. The Duet2 controls the printer axes, bed, tool coupler, and endstops;
the DueX E5/E6 outputs drive the controller fan and case LED. Each toolboard
controls one complete tool:

- one Orbiter 2.0 extruder motor;
- one 24 V hotend heater and one PT1000 temperature sensor;
- one automatic 24 V hotend-cooling fan; and
- two synchronized 24 V part-cooling fans.

`printer_base.cfg` loads the complete CAN configuration through one include:

```ini
[include toolboards/toolboards.cfg]
```

That file loads `mcu.cfg` followed by `tool0.cfg` through `tool3.cfg`. The
legacy Duet toolhead configuration files have been removed, so these four
toolboard files are the only definitions for the extruders, hotend heaters,
temperature sensors, and tool fans.

### CAN MCU names and UUIDs

The USB-CAN bridge and toolboard UUIDs are recorded below. The toolboards are
installed in physical ID order: Toolboard 01 maps to T0, continuing through
Toolboard 04 on T3.

| Configuration section | Toolboard ID | CAN UUID | Physical board | Tool config |
| --- | --- | --- | --- | --- |
| `mcu usb_bridge` | — | `28f4296c4844` | USB-CAN Bridge v2 | — |
| `mcu tool0` | 01 | `3fc4f7b9fe99` | T0 Toolhead v3 | `toolboards/tool0.cfg` |
| `mcu tool1` | 02 | `a9c8770a4f5f` | T1 Toolhead v3 | `toolboards/tool1.cfg` |
| `mcu tool2` | 03 | `89622ad13c37` | T2 Toolhead v3 | `toolboards/tool2.cfg` |
| `mcu tool3` | 04 | `fb7d25bf3989` | T3 Toolhead v3 | `toolboards/tool3.cfg` |

All five MCUs use `canbus_interface: can0`. Discover and record one unassigned
toolboard at a time so its physical tool number cannot be confused with another
board. The host CAN interface must be configured for 1 Mbit/s.

### Per-tool Klipper names

KTCC and the existing macros depend on these names. Do not rename them when
verifying the installed UUIDs.

| Tool | MCU prefix | Extruder/heater | Driver | Hotend fan | Part-fan object |
| --- | --- | --- | --- | --- | --- |
| T0 | `tool0:` | `extruder` | `tmc2209 extruder` | `hotend_fan_0` | `part_fan_0` |
| T1 | `tool1:` | `extruder1` | `tmc2209 extruder1` | `hotend_fan_1` | `part_fan_1` |
| T2 | `tool2:` | `extruder2` | `tmc2209 extruder2` | `hotend_fan_2` | `part_fan_2` |
| T3 | `tool3:` | `extruder3` | `tmc2209 extruder3` | `hotend_fan_3` | `part_fan_3` |

### Shared Toolhead v3 pin map

Each file uses the same local pin names with its own MCU prefix. For example,
T2 uses `tool2:PA8` for its heater.

| Function | Toolboard pin | Klipper behavior |
| --- | --- | --- |
| Extruder step | `PD0` | TMC2209 step input |
| Extruder direction | `!PD1` | Direction signal is inverted |
| Extruder enable | `!PD2` | Enable signal is active-low |
| TMC2209 UART | `PA15` | Driver communication and diagnostics |
| Hotend heater | `PA8` | PWM heater output, `max_power: 1.0` |
| PT1000 sensor | `PA0` | Uses `pullup_resistor: 2200` |
| Hotend fan | `PA6` | Automatic at 40°C, full speed |
| Part-cooling fan A | `PA7` | Combined into one logical fan |
| Part-cooling fan B | `PB0` | Combined into the same logical fan |

The two physical part-cooling outputs are joined with a Klipper `multi_pin`.
Commands sent to `part_fan_0` through `part_fan_3` therefore drive both fans on
the selected tool at the same speed.

### Shared Orbiter and hotend defaults

All four tool configurations currently use the following starting values:

| Setting | Value |
| --- | --- |
| Microsteps | `16` |
| Full steps per rotation | `200` |
| Orbiter rotation distance | `4.637` |
| TMC2209 run current | `0.72 A` |
| TMC2209 sense resistor | `0.110 ohm` |
| Nozzle / filament diameter | `0.4 mm` / `1.75 mm` |
| Maximum single extrusion-only move | `250 mm` |
| Maximum extrusion-only velocity | `100 mm/s` |
| Minimum extrusion temperature | `170°C` |
| Temperature range | `-10°C` to `320°C` |
| Temperature sensor | `PT1000`, 2.2 kOhm pull-up |

The checked-in PID values are only starting values copied from the previous
heater configuration. PID, rotation distance, motor direction, pressure
advance, and retraction must be checked or calibrated for each physical tool.
Use the attended first-start procedure in
[docs/can-toolboards.md](docs/can-toolboards.md) before normal printing.

## Usage

### Direct-drive filament macros

All four tools use the same Orbiter 2.0 direct-drive defaults. `TOOL` is a
number from 0 through 3; when omitted, the currently mounted tool is used.

```gcode
LOAD_FILAMENT TOOL=0 TEMP=220
UNLOAD_FILAMENT TOOL=0 TEMP=220
COLD_PULL TOOL=0 INITIAL_TEMP=220
```

`LOAD_FILAMENT` defaults to an 80 mm feed at a conservative 5 mm/s followed by
a 50 mm slow purge. `UNLOAD_FILAMENT` defaults to a 200 mm withdrawal at
20 mm/s; `COLD_PULL` uses 10 mm/s. Override these for a different spool path
with `LENGTH`, `SPEED`, `PURGE_LENGTH`, or `PURGE_SPEED` as applicable. A
single move is limited to 250 mm to match the extruder safety limit. The
printer must be attended while establishing safe lengths for its final routing.

T0 and T1 pressure advance were reset because changing their extruder hardware
invalidates the previous values. Calibrate pressure advance and retraction for
each tool before production printing; the existing T2 and T3 values are kept as
starting points because those tools already used Orbiter direct drive.

### Change tools

```gcode
T0 ; change to tool 0
T1 ; change to tool 1
T2 ; change to tool 2
T3 ; change to tool 3
```

### Drop tool

```gcode
DROP_TOOL
```

### Reset coupling

```gcode
COUPLER_RESET
```

### Aliangment

**Note: This is an extension to the original ToolChanger. We created an alignemnt tool to use 'switch' for probing offsets of each tool. It doesn't work with the original heated bed. Since there is no place to attach the alignment rod.**

Use following command to align tools. Every parameter is optional, it's given default value if not specified.
However, if the default values are not correct, please edit `tools/alignment.cfg` to change the default values.

```gcode
ALIGN_TOOLS [TOOLS=0,1,2,3]
```

Where

- `TOOLS` is a list of tools to be aligned. It's a comma separated list. Default is all tools.

### Manual bed calibration

The original `MANUAL_BED_CALIBRATE` command remains available. If a tool is
mounted, it drops the tool first, verifies the mount is empty, then performs its
existing homing sequence and creates a 3x3 bed mesh over the configured mesh
bounds:

```gcode
MANUAL_BED_CALIBRATE
```

The touchscreen's guided corner adjustment is a separate workflow. It automatically
scans all four fixed bed adjustment points; the operator does not select a point
or replace the original public calibration macro.

The screen uses the internal `_MANUAL_BED_PROBE_POINT` helper once per point:

```gcode
_MANUAL_BED_PROBE_POINT POINT=FL
_MANUAL_BED_PROBE_POINT POINT=FR
_MANUAL_BED_PROBE_POINT POINT=BR
_MANUAL_BED_PROBE_POINT POINT=BL
```

These commands are documented for diagnostics only. Normal operation is a
single `Scan Bed Corners` action on the touchscreen.

The point names are front-left, front-right, back-right, and back-left. Each
helper call drops a mounted tool, verifies that the tool mount is empty, homes the
printer if necessary, clears active bed mesh compensation, moves to the configured
point, probes it, and lifts Z before returning.

The default XY values in `macros/G29.cfg` are the existing safe bed-mesh corner
coordinates. Measure the actual bed screw locations and update `point_fl`,
`point_fr`, `point_br`, and `point_bl` so the probe is directly above each screw,
or at the closest safe point that represents it. Do not use a coordinate the
probe cannot safely reach.

After each helper call, the touchscreen queries the Klipper `probe` object for
`last_probe_position` and `last_z_result`. The four relative deviations and
their range are calculated by the client; this helper does not create a mesh.

### Begin gcode

Begin is defined in `macros/startstop.cfg`. Its usage is following (with prusa slicer):

```gcode
PRINT_BEGIN INITIAL_TOOL={initial_tool} BED_TEMPS={first_layer_bed_temperature[0]},{first_layer_bed_temperature[1]},{first_layer_bed_temperature[2]},{first_layer_bed_temperature[3]} TOOL_TEMPS={first_layer_temperature[0]},{first_layer_temperature[1]},{first_layer_temperature[2]},{first_layer_temperature[3]} TOOL_STANDBY_TEMPS={first_layer_temperature[0]-30},{first_layer_temperature[1]-30},{first_layer_temperature[2]-30},{first_layer_temperature[3]-30} USED_TOOLS={is_extruder_used[0]},{is_extruder_used[1]},{is_extruder_used[2]},{is_extruder_used[3]} HEAT_SOAK=20
```

Where

- `INITIAL_TOOL` is the first tool to be used in the print
- `BED_TEMPS` is the bed temperature for each tool, it's a comma separated list.
- `TOOL_TEMPS` is the tool temperature for each tool, it's a comma separated list.
- `TOOL_STANDBY_TEMPS` is the tool standby temperature for each tool, it's a comma separated list.
- `USED_TOOLS` is a list of boolean values, indicating if the tool is used in the print. Boolean value is either `true` or `false`.
- `HEAT_SOAK` is the time to soak the chamber for high temperature print. It's activated only if bed temperature is above 110C.


### End gcode

```gcode
PRINT_END
```

### Heated-bed filament dryer

Start a timed dryer cycle with the bed temperature and duration in hours. The
timer starts after the bed is within 2C of the target temperature. Defaults are
110C and 12 hours; accepted limits are 40-120C and 1-12 hours.

```gcode
DRY_FILAMENT TEMP=110 HOURS=12
```

Cancel the cycle and turn off the bed with:

```gcode
CANCEL_FILAMENT_DRYER
```

Starting a print cancels an active dryer cycle. Before heating, the dryer requires
that no tool is mounted, turns off all heaters, homes every axis, moves the bed to
absolute Z=200mm (about 20cm below its home position), waits for motion to finish,
and releases all motors. It then enables only the bed. A changed bed target,
including an external `TURN_OFF_HEATERS`, stops the dryer timer instead of later
overwriting that target. The configured idle timeout is not changed; like
`HEAT_SOAK`, the dryer issues a 1ms dwell every 30 seconds to register activity.

> [!WARNING]
> Only use this mode if the bed, heater wiring, SSR, build surface, spool, and
> drying container are rated for continuous operation at the selected
> temperature. Keep the container vented, provide a path for moist air to escape,
> and do not treat bed temperature as proof of filament temperature. Verify the
> first cycle while attended with independent temperature and fire protection.
> Release the Z motor only if the bed cannot fall under gravity at Z=200mm.

## Hardware Setup

The connector name is the label on the board. MCU pins are included for
configuration review and troubleshooting; connect loads to the named connector,
not directly to an MCU pin. A leading `!` means Klipper inverts that signal.

### Duet 2 WiFi v1.03 connection map

| Function | Physical connector | MCU pin map | Klipper object / notes |
| --- | --- | --- | --- |
| CoreXY motor A | `X MOTOR` | step `PD6`, dir `!PD11`, CS `PD14` | `stepper_x`; left motor when viewed from the front |
| CoreXY motor B | `Y MOTOR` | step `PD7`, dir `!PD12`, CS `PC9` | `stepper_y`; right motor when viewed from the front |
| Z motor | `Z MOTOR` | step `PD8`, dir `!PD13`, CS `PC10` | `stepper_z`; fit the ZB jumpers if only ZA is used |
| Tool coupler motor | `E0 MOTOR` | step `PD5`, dir `!PA1`, CS `PC17` | `manual_stepper stepper_c` |
| Shared motor enable | Internal | `!PC6` | Active-low enable for the four onboard TMC2660 drivers above |
| X endstop | `X_STOP` | `PC14` | Physical X homing switch |
| Y endstop | `Y_STOP` | `PA2` | Physical Y homing switch |
| Bed/Z probe | `Z_STOP` | `PD29` | Probe input used as `probe:z_virtual_endstop` for Z homing |
| Tool alignment switch | `E0_STOP` | `^!PD10` | Pull-up and inverted input used by `[alignment]` |
| Tool-mounted switch | `E1_STOP` | `PC16` | Coupler endstop used by `manual_stepper stepper_c` |
| AC-bed SSR control | `BED HEATER` | `!PA19` | `heater_bed`; the output polarity is inverted |
| Bed temperature sensor | `BED TEMP` | `PC13` | Bed thermistor input |
| Controller fan | DueX `E5 HEAT` output | `!PC11` | `controller_fan drivers_fan` |
| Case LED | DueX `E6 HEAT` output | `!PA15` | PWM `output_pin LED` |

The replacement controller is selected by this USB identity:

```ini
[mcu]
serial: /dev/serial/by-id/usb-Klipper_sam4e8e_00313753364B37373032303531303233-if00
```

### Per-tool CAN connection map

The following row set applies independently to T0, T1, T2, and T3.

| Function | Toolhead v3 connector | Local pin map | Klipper behavior |
| --- | --- | --- | --- |
| 24 V power and CAN | `J2` XT30 2+2 | 24 V, GND, CANH, CANL | One CAN connection per toolboard |
| Orbiter 2.0 motor | `J4` | step `PD0`, dir `!PD1`, enable `!PD2`, UART `PA15` | Per-tool TMC2209 extruder driver |
| Hotend heater | `J5` | `PA8` | 24 V low-side heater output |
| Hotend-cooling fan | `J6` / Fan 0 | `PA6` | Starts automatically at 40°C or while heating |
| Part-cooling fan 1 | `J7` / Fan 1 | `PA7` | First member of the per-tool synchronized fan pair |
| Part-cooling fan 2 | `J8` / Fan 2 | `PB0` | Second member of the per-tool synchronized fan pair |
| PT1000 sensor | `J9` | `PA0` | Two-wire input with a configured 2.2 kOhm pull-up |

See [`duet2/pins.md`](duet2/pins.md) and
[`toolboards/pins.md`](toolboards/pins.md) for the full hardware references.


## Notes:

1. This configuration is only work with toolchanger with physical XY endstop.
