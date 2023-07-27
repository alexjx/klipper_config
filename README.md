#

# Resonance Testing

TEST_RESONANCES AXIS=X NAME=t0
TEST_RESONANCES AXIS=Y NAME=t0
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t0.csv -o /tmp/shaper_calibrate_t0_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t0.csv -o /tmp/shaper_calibrate_t0_y.png

TEST_RESONANCES AXIS=X NAME=t1
TEST_RESONANCES AXIS=Y NAME=t1
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t1.csv -o /tmp/shaper_calibrate_t1_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t1.csv -o /tmp/shaper_calibrate_t1_y.png

TEST_RESONANCES AXIS=X NAME=t2
TEST_RESONANCES AXIS=Y NAME=t2
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t2.csv -o /tmp/shaper_calibrate_t2_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t2.csv -o /tmp/shaper_calibrate_t2_y.png

TEST_RESONANCES AXIS=X NAME=t3
TEST_RESONANCES AXIS=Y NAME=t3
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_x_t3.csv -o /tmp/shaper_calibrate_t3_x.png
~/klipper/scripts/calibrate_shaper.py /tmp/resonances_y_t3.csv -o /tmp/shaper_calibrate_t3_y.png
