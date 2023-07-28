# Klipper Configuration for E3D toolchanger

This configuration depends on following repositories:

1. [Klipper](https://github.com/alexjx/klipper)
2. [Klipper Toolchanger Code](https://github.com/alexjx/Klipper_ToolChanger)

And KTCC is configured as a submodule of Klipper repo.

## Hardware Setup

Connection are the same as original toolchanger, except for tool alignment probe. Alignment probe need to connect to `e1stop`.

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
