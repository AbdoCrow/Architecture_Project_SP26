force -freeze sim:/processor/in_port 16#00000019 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#FFFFFFFF 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#FFFFF320 0
run $CLOCK_PERIOD
run $RUN_TIME
force -freeze sim:/processor/in_port 16#00000010 0
run $CLOCK_PERIOD
run $RUN_TIME
force -freeze sim:/processor/in_port 16#00000019 0
run $CLOCK_PERIOD
run $RUN_TIME
run $RUN_TIME


wave zoom full