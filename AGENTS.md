# Repository Guidelines

## Project Structure & Module Organization

This repository contains Klipper configuration for an E3D toolchanger. `printer_base.cfg` defines the active include graph. Keep board-specific pins, steppers, heaters, fans, and MCU settings in `duet2/`; general behavior in `settings/`; reusable G-code in `macros/`; and toolchanger logic in `tools/`. `variables.cfg` stores runtime values, while `docs/` contains tuning notes. Update `README.md` when setup or operator-facing commands change.

## Installation, Validation, and Development Commands

There is no compilation step. Work is installed onto a configured MainsailOS/Klipper host:

```bash
bash -n install.sh              # validate installer shell syntax
bash install.sh                 # link configs into ~/printer_data/config
sudo systemctl restart klipper  # reload and parse the configuration
journalctl -u klipper -n 100    # inspect recent parser/runtime errors
```

Run the installer only on the target printer: it backs up and replaces `printer.cfg`. During development, review include paths with `rg '^\[include ' printer_base.cfg` and inspect `git diff` before restarting Klipper.

## Coding Style & Naming Conventions

Use four spaces in shell blocks and follow the surrounding Klipper CFG formatting. Keep section names and option names lowercase unless Klipper or G-code conventions require uppercase. Name user-facing macros in uppercase (`PRINT_BEGIN`, `ALIGN_TOOLS`) and helper macros with a leading underscore. Use descriptive snake_case variables, group related settings, and retain concise inline comments for wiring or hardware-specific choices. Avoid duplicating pin definitions or tuning values across files.

## Testing Guidelines

No automated test framework or coverage target is present. Validate changes by checking shell syntax where applicable, restarting Klipper, and confirming logs contain no configuration errors. Exercise changed macros from the console with heaters and motion disabled when possible. Hardware changes require low-speed or low-temperature verification before a normal print.

## Commit & Pull Request Guidelines

History favors short, imperative commit subjects, optionally scoped (`tool: tweak temperature compensation`, `fix: ...`). Keep each commit focused on one hardware, setting, or macro concern. Pull requests should explain the motivation, list affected hardware/config files, describe validation performed, and call out required calibration or wiring changes. Link relevant issues and include console output or screenshots when behavior is visible in Mainsail.

## Security & Configuration Tips

Do not commit secrets, host credentials, or transient logs. Treat MCU serial paths, thermistor types, pin assignments, travel limits, and heater limits as machine-specific safety settings; verify them against the target hardware before deployment.
