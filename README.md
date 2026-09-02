# Klipper Configuration for E3D toolchanger

This configuration depends on following repositories:

1. [Klipper](https://github.com/alexjx/klipper)
2. [Klipper Toolchanger Code](https://github.com/alexjx/Klipper_ToolChanger)

## Credit

- Thanks orignal [Klipper](https://github.com/Klipper3d/klipper)
- Thanks orignal [KTCC](https://github.com/TypQxQ/Klipper_ToolChanger)
- Thanks [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging) for the adaptive purge approach
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
2. Verify each installed toolboard CAN UUID in its `toolboards/toolN.cfg` file.
   See the [CAN toolboard configuration](docs/can-toolboards.md) for the
   Toolboard 01–04 mapping and first-start checks.
3. Edit the global macro switches in `~/klipper_config/printer_base.cfg` as
   needed. Host and main-MCU monitoring is kept in `settings/host_mcu.cfg`.
4. Update other configurations to meet your needs.
   1. I'm using PT1000 for extruder, you might have to change that.
   2. This machine uses only the AC-bed configuration in `duet2/bed-ac.cfg`.
5. Enable object processing for Klipper's native adaptive mesh and the adaptive
   purge macro. Both features use `[exclude_object]` geometry.

   - Edit `moonraker.conf` to include object processing

     ```
     [file_manager]
     enable_object_processing: True
     ```

   - Enable object labels in the slicer

### Native adaptive bed mesh

`BED_MESH_CALIBRATE` retains the toolchanger safety checks, then delegates mesh
bounds and probe-count calculation to upstream Klipper with `ADAPTIVE=1`.
`settings/bed_mesh.cfg` adds a 3mm margin around the slicer's defined objects.
If no object geometry is available, Klipper falls back to the configured full
mesh.

The two features have independent switches in `_SETTINGS`:

```ini
variable_adaptive_mesh: 1
variable_adaptive_purge: 1
```

The purge implementation remains local because upstream adaptive bed mesh does
not provide an adaptive purge command.

6. ~~Update `scripts/generate-belt-tension-graph.sh`, `scripts/generate-shaper-graph-x.sh`, `scripts/generate-shaper-graph-y.sh` to meet your paths.~~
   Prefer https://github.com/Frix-x/klippain-shaketune

7. Measure and update input shaper value for each tool.
8. Update `~/klipper_config/tools/tools.cfg`. The offsets are used for initial tool alignment. Configure them to meet your needs.

### USB accelerometer

The BTT ADXL345 and Klippain ShakeTune are disabled by default. Connect the
accelerometer by USB, uncomment `[include settings/resonance_tester.cfg]` in
`printer_base.cfg`, and restart Klipper. This single include enables both the
accelerometer and ShakeTune. Verify the accelerometer with
`ACCELEROMETER_QUERY CHIP=btt_adxl345` before measuring. Comment the include
again before disconnecting the board. See [`docs/README.md`](docs/README.md)
for the complete workflow.

## CAN Toolboard Configuration

The local connector and MCU-pin reference is
[`toolboards/pins.md`](toolboards/pins.md).

The active profile keeps the original Duet2 and DueX5. T0 and T1 use their
original Duet/DueX connections, T2 uses its Toolhead v3 CAN board, and T3 is
disabled. The old T2/T3 Duet/DueX wiring has been removed. The Duet2/DueX5
pair continues to control motion, the AC bed, the tool coupler, and endstops.
A CAN toolboard controls one complete tool:

- one Orbiter 2.0 extruder motor;
- one 24 V hotend heater and one PT1000 temperature sensor;
- one automatic 24 V hotend-cooling fan; and
- two synchronized 24 V part-cooling fans.

`printer_base.cfg` loads the staged hardware selection through one include:

```ini
[include toolboards/toolheads.cfg]
```

`toolboards/toolheads.cfg` is the source of truth for enabled tool connections.
T2 and the shared CAN bridge are active. T3 has no active include, so its
offline MCU is not loaded. To enable T3, enable its `tool3.cfg` hardware include
in `toolboards/toolheads.cfg`, then enable `tool3.cfg` at the end of
`tools/tools.cfg`. Shared macros detect enabled tools automatically.

### Current connection status

| Tool | Current state | Connection board | Motor/heater/sensor | Tool fans | Configuration |
| --- | --- | --- | --- | --- | --- |
| T0 | Connected, legacy | Duet2 | `E0 MOTOR`, `E0 HEAT`, `E0 TEMP` | `FAN1`, `FAN2` | `duet2/tool0.cfg` |
| T1 | Connected, legacy | Duet2 + DueX5 | Duet2 `E1 MOTOR`, `E1 HEAT`, `E1 TEMP` | DueX5 `FAN3`, `FAN4` | `duet2/tool1.cfg` |
| T2 | Connected, CAN | Toolboard 03 | `J4`, `J5`, `J9` | `J6`, `J7`, `J8` | `toolboards/tool2.cfg` |
| T3 | Disconnected | DueX5 wiring removed; Toolboard 04 planned | Former `E3 MOTOR`, `E3 HEAT`, `E3 TEMP` disconnected | Former `FAN7`, `FAN8` disconnected | configuration prepared but disabled |

The former T2 DueX5 connections (`E2 MOTOR`, `E2 HEAT`, `E2 TEMP`, `FAN5`,
and `FAN6`) are also unused. Keeping these outputs unconfigured avoids
accidentally driving disconnected wiring.

### CAN MCU names and UUIDs

The USB-CAN bridge UUID is in `toolboards/mcu.cfg`; each toolboard UUID is kept
beside that tool's pins in `toolboards/toolN.cfg`. Only enabled CAN boards need
to be online. T2/Toolboard 03 is enabled; T3/Toolboard 04 remains disabled.

| Configuration section | Toolboard ID | CAN UUID | Physical board | Tool config |
| --- | --- | --- | --- | --- |
| `mcu usb_bridge` | — | `28f4296c4844` | USB-CAN Bridge v2 | — |
| `mcu tool0` | 01 | `3fc4f7b9fe99` | T0 Toolhead v3 | `toolboards/tool0.cfg` |
| `mcu tool1` | 02 | `a9c8770a4f5f` | T1 Toolhead v3 | `toolboards/tool1.cfg` |
| `mcu tool2` | 03 | `89622ad13c37` | T2 Toolhead v3 | `toolboards/tool2.cfg` |
| `mcu tool3` | 04 | `fb7d25bf3989` | T3 Toolhead v3 | `toolboards/tool3.cfg` |

Enabled CAN MCUs use `canbus_interface: can0`. Discover and record one
unassigned toolboard at a time so its physical tool number cannot be confused
with another board. The host CAN interface must be configured for 1 Mbit/s.

### Per-tool Klipper names

KTCC and the existing macros depend on these names. Do not rename them when
verifying the installed UUIDs.

| Tool | MCU prefix | Extruder/heater | Driver | Hotend fan | Part-fan object |
| --- | --- | --- | --- | --- | --- |
| T0 | Duet2 | `extruder` | `tmc2660 extruder` | `hotend_fan_0` | `part_fan_0` |
| T1 | Duet2 | `extruder1` | `tmc2660 extruder1` | `hotend_fan_1` | `part_fan_1` |
| T2 | `tool2:` | `extruder2` | `tmc2209 extruder2` | `hotend_fan_2` | `part_fan_2` |
| T3 | planned `tool3:` | `extruder3` (disabled) | `tmc2209 extruder3` | `hotend_fan_3` | `part_fan_3` |

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
For each CAN tool, commands sent to its `part_fan_N` object drive both
toolboard part-fan outputs at the same speed.

### Shared Orbiter and hotend defaults

Each CAN tool configuration uses the following starting values:

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

所有当前加载的自定义命令、内部辅助 macro 和原始命令覆盖关系见
[`docs/macros.md`](docs/macros.md)。

### Filament macros during migration

T0/T1 retain their long filament paths, while the T2 and prepared T3 profiles
use direct-drive path lengths. TOOL 0-2 are currently available; TOOL 3 is
rejected until its CAN board and logical tool definition are enabled.

```gcode
LOAD_FILAMENT TOOL=0 TEMP=220
UNLOAD_FILAMENT TOOL=0 TEMP=220
COLD_PULL TOOL=0 INITIAL_TEMP=220
```

Defaults and safety limits are stored per tool in `_FILAMENT_SETTINGS`.
Override them with `LENGTH`, `SPEED`, `PURGE_LENGTH`, or `PURGE_SPEED` as
applicable. Calibrate pressure advance, retraction, and the filament path after
each physical tool migration.

### Change tools

```gcode
T0 ; change to tool 0
T1 ; change to tool 1
T2 ; change to tool 2
T3 ; rejected until the T3 CAN toolboard is connected and enabled
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
- `HEAT_SOAK` is the maximum chamber soak time in minutes. At the start of
  `PRINT_BEGIN`, Klipper estimates room temperature from the configured hotends:
  readings more than 5C from their median are ignored, then the remaining
  readings are averaged. At least two readings must agree. Soaking runs only
  when the bed target is above `_SETTINGS.heat_soak_threshold` and the estimated
  room temperature is below the fixed 25C cutoff.
  The actual time is scaled by `(bed target - estimated room temperature) / bed target`.
  Set `HEAT_SOAK=0` to disable it.


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

### Duet2 WiFi v1.03 + DueX5 connection map

| Function | Board | Physical connector | MCU pin map | Klipper object / notes |
| --- | --- | --- | --- | --- |
| CoreXY motor A | DueX5 | `E5 MOTOR` | step `PD3`, dir `!PD17`, CS `PD26` | `stepper_x`; original Duet2 X driver is faulty |
| CoreXY motor B | Duet2 | `Y MOTOR` | step `PD7`, dir `!PD12`, CS `PC9` | `stepper_y`; right motor when viewed from the front |
| Z motor | Duet2 | `Z MOTOR` | step `PD8`, dir `!PD13`, CS `PC10` | `stepper_z`; fit the ZB jumpers if only ZA is used |
| Tool coupler motor | DueX5 | `E4 MOTOR` | step `PD0`, dir `!PD16`, CS `PD25` | `manual_stepper stepper_c` |
| Shared motor enable | Duet2 MCU | Internal | `!PC6` | Active-low signal shared by the configured Duet2/DueX5 TMC2660 drivers |
| X endstop | Duet2 | `X_STOP` | `PC14` | Physical X homing switch |
| Y endstop | Duet2 | `Y_STOP` | `PA2` | Physical Y homing switch |
| Bed/Z probe | Duet2 | `Z_STOP` | `PD29` | Probe input used as `probe:z_virtual_endstop` for Z homing |
| Tool alignment switch | Duet2 | `E0_STOP` | `^!PD10` | Pull-up and inverted input used by `[alignment]` |
| Tool-mounted switch | Duet2 | `E1_STOP` | `PC16` | Coupler endstop used by `manual_stepper stepper_c` |
| AC-bed SSR control | Duet2 | `BED HEATER` | `!PA19` | `heater_bed`; the output polarity is inverted |
| Bed temperature sensor | Duet2 | `BED TEMP` | `PC13` | Bed thermistor input |
| Controller fan | DueX5 | `E5 HEAT` | `!PC11` | `controller_fan drivers_fan` |
| Case LED | DueX5 | `E6 HEAT` | `!PA15` | PWM `output_pin LED` |

The original controller is selected by this USB identity:

```ini
[mcu]
serial: /dev/serial/by-id/usb-Klipper_sam4e8e_00323153434834523133303033303339-if00
```

### Per-tool CAN connection map

The following row set applies when a prepared CAN toolboard is enabled.

| Function | Board | Physical connector | Local pin map | Klipper behavior |
| --- | --- | --- | --- | --- |
| 24 V power and CAN | Toolhead v3 | `J2` XT30 2+2 | 24 V, GND, CANH, CANL | One CAN connection per toolboard |
| Orbiter 2.0 motor | Toolhead v3 | `J4` | step `PD0`, dir `!PD1`, enable `!PD2`, UART `PA15` | Per-tool TMC2209 extruder driver |
| Hotend heater | Toolhead v3 | `J5` | `PA8` | 24 V low-side heater output |
| Hotend-cooling fan | Toolhead v3 | `J6` / Fan 0 | `PA6` | Starts automatically at 40°C or while heating |
| Part-cooling fan 1 | Toolhead v3 | `J7` / Fan 1 | `PA7` | First member of the per-tool synchronized fan pair |
| Part-cooling fan 2 | Toolhead v3 | `J8` / Fan 2 | `PB0` | Second member of the per-tool synchronized fan pair |
| PT1000 sensor | Toolhead v3 | `J9` | `PA0` | Two-wire input with a configured 2.2 kOhm pull-up |

See [`duet2/pins.md`](duet2/pins.md) and
[`toolboards/pins.md`](toolboards/pins.md) for the full hardware references.


## Notes:

1. This configuration is only work with toolchanger with physical XY endstop.
