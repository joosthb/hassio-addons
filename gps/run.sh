#!/bin/bash
# debug logging
# gpsd -D 5 -N -n /dev/ttyACM0

gpsd -N -n /dev/ttyACM0 &

# -x to disable setting system clock
chronyd -x -d