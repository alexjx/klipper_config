# Drivers

Here are the pins for the 10 stepper drivers supported by a Duet2 board
| Drive |  DIR pin |  STEP pin |  ENDSTOP pin |  SPI EN pin |
|-------|----------|-----------|--------------|-------------|
| X     |  PD11    |  PD6      |  PC14        |  PD14       |
| Y     |  PD12    |  PD7      |  PA2         |  PC9        |
| Z     |  PD13    |  PD8      |  PD29        |  PC10       |
| E0    |  PA1     |  PD5      |  PD10        |  PC17       |
| E1    |  PD9     |  PD4      |  PC16        |  PC25       |
| E2    |  PD28    |  PD2      |  PE0*        |  PD23       |
| E3    |  PD22    |  PD1      |  PE1*        |  PD24       |
| E4    |  PD16    |  PD0      |  PE2*        |  PD25       |
| E5    |  PD17    |  PD3      |  PE3*        |  PD26       |
| E6    |  PC0     |  PD27     |  PA17*       |  PB14       |
Pins marked with asterisks (*) are only assigned to these functions
if no duex is connected. If a duex is connected, these endstops are
remapped to the SX1509 on the Duex (unfortunately they can't be used
as endstops in klipper, however one may use them as digital outs or
PWM outs). The SPI EN pins are required for the TMC2660 drivers (use
the SPI EN pin as 'cs_pin' in the respective config block). The
**enable pin for all steppers** is TMC_EN = !PC6.

# Fans

| FAN  |          PIN          |
|------|-----------------------|
| FAN0 |  PC23                 |
| FAN1 |  PC26                 |
| FAN2 |  PA0                  |
| FAN3 |  sx1509_duex:PIN_12*  |
| FAN4 |  sx1509_duex:PIN_7*   |
| FAN5 |  sx1509_duex:PIN_6*   |
| FAN6 |  sx1509_duex:PIN_5*   |
| FAN7 |  sx1509_duex:PIN_4*   |
| FAN8 |  sx1509_duex:PIN_15*  |
Pins marked with (*) assume the following sx1509 config section:
[sx1509 duex]
i2c_address: 62

# Heaters and Thermistors

| Extruder Drive |  HEAT pin |  TEMP pin |
|----------------|-----------|-----------|
| BED            |  PA19     |  PC13     |
| E0             |  PA20     |  PC15     |
| E1             |  PA16     |  PC12     |
| E2             |  PC3      |  PC29     |
| E3             |  PC5      |  PC30     |
| E4             |  PC8      |  PC31     |
| E5             |  PC11     |  PC27     |
| E6             |  PA15     |  PA18     |

# Misc pins

|    Name     |   Pin   |
|-------------|---------|
| ZProbe_IN   |  PC1    |
| PS_ON       |  PD15   |
| LED_ONBOARD |  PC2    |
| SPI0_CS0    |  PC24   |
| SPI0_CS1    |  PB2    |
| SPI0_CS2    |  PC18   |
| SPI0_CS3    |  PC19   |
| SPI0_CS4    |  PC20   |
| SPI0_CS5    |  PA24   |
| SPI0_CS6    |  PE1*   |
| SPI0_CS7    |  PE2*   |
| SPI0_CS8    |  PE3*   |
| SX1509_IRQ  |  PA17*  |
| SG_TST      |  PE0*   |
| ENC_SW      |  PA7    |
| ENC_A       |  PA8    |
| ENC_B       |  PC7    |
| LCD_DB7     |  PD18   |
| LCD_DB6     |  PD19   |
| LCD_DB5     |  PD20   |
| LCD_DB4     |  PD21   |
| LCD_RS      |  PC28   |
| LCD_E       |  PA25   |
Pins marked with one asterisk (*) replace E2_STOP-E6_STOP if a duex is present
For the remaining pins check the schematics provided here: https://github.com/T3P3/Duet