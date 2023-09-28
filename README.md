# Klipper Configuration for E3D toolchanger

This configuration depends on following repositories:

1. [Klipper](https://github.com/alexjx/klipper)
2. [Klipper Toolchanger Code](https://github.com/alexjx/Klipper_ToolChanger)

And KTCC is configured as a submodule of Klipper repo.

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

| Item           | Connector          | Description |
| -------------- | ------------------ | ----------- |
| Bed            | Bed Heater         |             |
| Bed Sensor     | Bed Sensor         |             |
| Extruder 0     | E0 Heater          |             |
| Extruder 0     | E0 Sensor          |             |
| Extruder 1     | E1 Heater          |             |
| Extruder 1     | E1 Sensor          |             |
| Extruder 2     | E2 Heater          |             |
| Extruder 2     | E2 Sensor          |             |
| Extruder 3     | E3 Heater          |             |
| Extruder 3     | E3 Sensor          |             |
| Hotend 0 Fan   | FAN_1              |             |
| Hotend 1 Fan   | sx1509_duex:PIN_12 |             |
| Hotend 2 Fan   | sx1509_duex:PIN_6  |             |
| Hotend 3 Fan   | FAN_0              |             |
| Part Cooling 0 | FAN_2              |             |
| Part Cooling 1 | sx1509_duex:PIN_7  |             |
| Part Cooling 2 | sx1509_duex:PIN_5  |             |
| Part Cooling 0 | sx1509_duex:PIN_15 |             |

### Endstops

| Item       | Connector  | Description   |
| ---------- | ---------- | ------------- |
| X          | X Endstop  |               |
| Y          | Y Endstop  |               |
| Z          | Z Endstop  |               |
| Bed        |            | Use Z Endstop |
| Alignment  | E0 Endstop |               |
| Tool Mount | E1 Endstop |               |


## Installation

1. Setup Klipper with MainsailOS
1. Setup Klipper with modified repo

    ```bash
    cd ~
    git remote add alexjx https://github.com/alexjx/klipper.git
    git fetch alexjx
    git checkout alexjx/master
    git submodule update --init
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

1. Use following command to align tools. `PROBE_POINT` is configured with a default point, but should be changed to a point that is within the probe top.

    ```
    ALIGN_TOOLS [TOOLS=0,1,2,3] [PROBE_POINT=146,101]
    ```

## Notes:

1. This configuration is only work with toolchanger with physical XY endstop.
