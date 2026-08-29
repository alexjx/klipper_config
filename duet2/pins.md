# Duet2/DueX5 pin reference

This is a hardware reference, not an active toolhead configuration. The board
column distinguishes Duet2 onboard connectors from DueX5 expansion connectors.
The active printer uses Duet2 for Y, Z, T0/T1, the AC bed, and endstops; it uses
DueX5 E5 for X, E4 for the coupler, FAN3/FAN4 for T1, and E5/E6 heater outputs
for the controller fan and case LED. T2 uses its CAN toolboard and T3 is
disabled; their former DueX5 wiring is disconnected.

# Drivers

Here are the pins for the five Duet2 onboard drivers and five DueX5 expansion
drivers:

| Drive | Board | DIR pin | STEP pin | ENDSTOP pin | SPI CS pin |
| --- | --- | --- | --- | --- | --- |
| X | Duet2 | `PD11` | `PD6` | `PC14` | `PD14` |
| Y | Duet2 | `PD12` | `PD7` | `PA2` | `PC9` |
| Z | Duet2 | `PD13` | `PD8` | `PD29` | `PC10` |
| E0 | Duet2 | `PA1` | `PD5` | `PD10` | `PC17` |
| E1 | Duet2 | `PD9` | `PD4` | `PC16` | `PC25` |
| E2 | DueX5 | `PD28` | `PD2` | `PE0`* | `PD23` |
| E3 | DueX5 | `PD22` | `PD1` | `PE1`* | `PD24` |
| E4 | DueX5 | `PD16` | `PD0` | `PE2`* | `PD25` |
| E5 | DueX5 | `PD17` | `PD3` | `PE3`* | `PD26` |
| E6 | DueX5 | `PC0` | `PD27` | `PA17`* | `PB14` |
Pins marked with asterisks (*) are only assigned to these functions if no
DueX5 is connected. With DueX5 installed, these endstops are remapped to its
SX1509 and cannot be used as Klipper endstops, though they may be used as
digital or PWM outputs. The SPI CS pins are required for the TMC2660 drivers
(use them as `cs_pin` in the respective config block). The shared enable signal
is `PC6`; this configuration aliases it as `DRIVERS_EN` and uses
`enable_pin: !DRIVERS_EN`.

# Fans

| Fan | Board | Pin |
| --- | --- | --- |
| FAN0 | Duet2 | `PC23` |
| FAN1 | Duet2 | `PC26` |
| FAN2 | Duet2 | `PA0` |
| FAN3 | DueX5 | `sx1509_duex:PIN_12`* |
| FAN4 | DueX5 | `sx1509_duex:PIN_7`* |
| FAN5 | DueX5 | `sx1509_duex:PIN_6`* |
| FAN6 | DueX5 | `sx1509_duex:PIN_5`* |
| FAN7 | DueX5 | `sx1509_duex:PIN_4`* |
| FAN8 | DueX5 | `sx1509_duex:PIN_15`* |
Pins marked with (*) assume the following SX1509 config section:

```ini
[sx1509 duex]
i2c_address: 62
```

# Heaters and Thermistors

| Connector | Board | HEAT pin | TEMP pin |
| --- | --- | --- | --- |
| BED | Duet2 | `PA19` | `PC13` |
| E0 | Duet2 | `PA20` | `PC15` |
| E1 | Duet2 | `PA16` | `PC12` |
| E2 | DueX5 | `PC3` | `PC29` |
| E3 | DueX5 | `PC5` | `PC30` |
| E4 | DueX5 | `PC8` | `PC31` |
| E5 | DueX5 | `PC11` | `PC27` |
| E6 | DueX5 | `PA15` | `PA18` |

# Misc pins

| Name | Board | Pin |
| --- | --- | --- |
| ZProbe_IN | Duet2 | `PC1` |
| PS_ON | Duet2 | `PD15` |
| LED_ONBOARD | Duet2 | `PC2` |
| SPI0_CS0 | Duet2 | `PC24` |
| SPI0_CS1 | Duet2 | `PB2` |
| SPI0_CS2 | Duet2 | `PC18` |
| SPI0_CS3 | Duet2 | `PC19` |
| SPI0_CS4 | Duet2 | `PC20` |
| SPI0_CS5 | Duet2 | `PA24` |
| SPI0_CS6 | Duet2 | `PE1`* |
| SPI0_CS7 | Duet2 | `PE2`* |
| SPI0_CS8 | Duet2 | `PE3`* |
| SX1509_IRQ | Duet2 | `PA17`* |
| SG_TST | Duet2 | `PE0`* |
| ENC_SW | Duet2 | `PA7` |
| ENC_A | Duet2 | `PA8` |
| ENC_B | Duet2 | `PC7` |
| LCD_DB7 | Duet2 | `PD18` |
| LCD_DB6 | Duet2 | `PD19` |
| LCD_DB5 | Duet2 | `PD20` |
| LCD_DB4 | Duet2 | `PD21` |
| LCD_RS | Duet2 | `PC28` |
| LCD_E | Duet2 | `PA25` |
Pins marked with one asterisk (*) replace E2_STOP-E6_STOP if a DueX5 is present.
For the remaining pins check the schematics provided here: https://github.com/T3P3/Duet
