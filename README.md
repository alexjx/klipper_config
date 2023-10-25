# Klipper Configuration for E3D toolchanger

This configuration depends on following repositories:

1. [Klipper](https://github.com/alexjx/klipper)
2. [Klipper Toolchanger Code](https://github.com/alexjx/Klipper_ToolChanger)

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

1. Setup Klipper with this repo

    ```bash
    cd ~
    git clone https://github.com/alexjx/klipper_config.git
    cd klipper_config
    bash install.sh
    ```

1. Restart klipper

    ```bash
    sudo systemctl restart klipper
    ```

## Configuration

1. Follow klipper document, edit `~/klipper_config/duet2/mcu.cfg`, ensure mcu serial device path is correct.
2. Update extruder and bed sensor type. Mines are `PT1000`
3. Edit `~/klipper_config/printer_base.cfg`, change `bed`. I'm currently using AC mains bed.
4. 

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

Use following command to align tools. `PROBE_POINT` is configured with a default point, but should be changed to a point that is within the probe top. Every parameter is optional, it's given default value if not specified.
However, if the default values are not correct, please edit `tools/alignment.cfg` to change the default values.

```gcode
ALIGN_TOOLS [TOOLS=0,1,2,3] [PROBE_POINT=146,101]
```

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
