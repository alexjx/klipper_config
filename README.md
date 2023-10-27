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

1. Setup Klipper with MainsailOS
1. Setup Klipper with modified repo

    ```bash
    cd ~/klipper
    git remote add alexjx https://github.com/alexjx/klipper.git
    git fetch alexjx
    git checkout -f alexjx/master
    ```

1. Install Klipper ToolChanger Extension

   ```bash
   cd ~
   git clone https://github.com/alexjx/Klipper_ToolChanger.git
   cd ~/Klipper_ToolChanger
   bash install.sh
   ```

1. Install `gcode_shell_command`

   ```bash
   curl -o ~/klipper/klippy/extras/gcode_shell_command.py https://github.com/dw-0/kiauh/blob/master/resources/gcode_shell_command.py
   ```

2. Setup Klipper with this repo

    ```bash
    cd ~
    git clone https://github.com/alexjx/klipper_config.git
    cd klipper_config
    bash install.sh
    ```

3. Restart klipper

    ```bash
    sudo systemctl restart klipper
    ```

## Configuration

1. Follow klipper document, edit `~/klipper_config/duet2/mcu.cfg`, ensure mcu serial device path is correct.
2. Edit `~/klipper_config/printer_base.cfg`. Update the settings for your needs.
3. Update other configurations to meet your needs.
4. Follow guide from [KAMP](https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging) to setup `[exclude_object]` for KAMP.
5. Measure and update input shaper value for each tool

## Usage

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

Use following command to align tools. Every parameter is optional, it's given default value if not specified.
However, if the default values are not correct, please edit `tools/alignment.cfg` to change the default values.

```gcode
ALIGN_TOOLS [TOOLS=0,1,2,3]
```

Where

- `TOOLS` is a list of tools to be aligned. It's a comma separated list. Default is all tools.

### Begin gcode

Begin is defined in `macros/startstop.cfg`. Its usage is following (with prusa slicer):

```gcode
PRINT_BEGIN INITIAL_TOOL={initial_tool} BED_TEMPS={first_layer_bed_temperature[0]},{first_layer_bed_temperature[1]},{first_layer_bed_temperature[2]},{first_layer_bed_temperature[3]} TOOL_TEMPS={first_layer_temperature[0]},{first_layer_temperature[1]},{first_layer_temperature[2]},{first_layer_temperature[3]} USED_TOOLS={is_extruder_used[0]},{is_extruder_used[1]},{is_extruder_used[2]},{is_extruder_used[3]} HEAT_SOAK=15
```

Where

- `INITIAL_TOOL` is the first tool to be used in the print
- `BED_TEMPS` is the bed temperature for each tool, it's a comma separated list.
- `TOOL_TEMPS` is the tool temperature for each tool, it's a comma separated list.
- `USED_TOOLS` is a list of boolean values, indicating if the tool is used in the print. Boolean value is either `true` or `false`.
- `HEAT_SOAK` is the time to soak the chamber for high temperature print. It's activated only if bed temperature is above 110C.


### End gcode

```gcode
PRINT_END
```

## Hardware Setup

### Motors

| Item     | Connector | Description            |
| -------- | --------- | ---------------------- |
| Motor A  | Driver X  | left motor from front  |
| Motor B  | Driver Y  | right motor from front |
| Motor Z  | Driver Z  |                        |
| Motor E0 | Driver E0 |                        |
| Motor E1 | Driver E1 |                        |
| Motor E2 | Driver E2 |                        |
| Motor E3 | Driver E3 |                        |
| Coupler  | Driver E4 |                        |

### Heated Bed and Extruders

| Item              | Connector          | Description |
| ----------------- | ------------------ | ----------- |
| Bed               | Bed Heater         |             |
| Bed Sensor        | Bed Sensor         |             |
| Extruder 0 Heater | E0 Heater          |             |
| Extruder 0 Sendor | E0 Sensor          |             |
| Extruder 1 Heater | E1 Heater          |             |
| Extruder 1 Senor  | E1 Sensor          |             |
| Extruder 2 Heater | E2 Heater          |             |
| Extruder 2 Sensor | E2 Sensor          |             |
| Extruder 3 Heater | E3 Heater          |             |
| Extruder 3 Sensor | E3 Sensor          |             |
| Hotend 0 Fan      | FAN_1              |             |
| Hotend 1 Fan      | sx1509_duex:PIN_12 | Duex FAN3   |
| Hotend 2 Fan      | sx1509_duex:PIN_6  | Duex FAN5   |
| Hotend 3 Fan      | sx1509_duex:PIN_4  | Duex FAN7   |
| Part Cooling 0    | FAN_2              |             |
| Part Cooling 1    | sx1509_duex:PIN_7  | Duex FAN4   |
| Part Cooling 2    | sx1509_duex:PIN_5  | Duex FAN6   |
| Part Cooling 0    | sx1509_duex:PIN_15 | Duex FAN8   |

### Endstops

| Item       | Connector  | Description   |
| ---------- | ---------- | ------------- |
| X          | X Endstop  |               |
| Y          | Y Endstop  |               |
| Z          | Z Endstop  |               |
| Bed        |            | Use Z Endstop |
| Alignment  | E0 Endstop |               |
| Tool Mount | E1 Endstop |               |


## Notes:

1. This configuration is only work with toolchanger with physical XY endstop.
