force -freeze sim:/processor/in_port 16#00000030 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000050 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000100 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000300 0
run $CLOCK_PERIOD
run $RUN_TIME
force -freeze sim:/processor/in_port 16#00000060 0
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000070 0
run $RUN_TIME
run $CLOCK_PERIOD

force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/in_port 16#00000005 0
run $RUN_TIME
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/in_port 16#00000005 0
run $RUN_TIME
run $CLOCK_PERIOD
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000600 0
run $RUN_TIME
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/in_port 16#00000005 0
run $RUN_TIME
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD


force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME

wave zoom full