## Test 2
# FETCH
run $CLOCK_PERIOD 
# DECODE
run $CLOCK_PERIOD 
force -freeze sim:/processor/in_port 16#00000010 0
# EXECUTE-1
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000020 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000005 0
run $CLOCK_PERIOD

run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
force -freeze sim:/processor/intr_in 1 0
force -freeze sim:/processor/in_port 16#00001111 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD

run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD

force -freeze sim:/processor/intr_in 1 0
force -freeze sim:/processor/in_port 16#00001111 0
run $CLOCK_PERIOD

force -freeze sim:/processor/intr_in 0 0
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD


run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD


force -freeze sim:/processor/intr_in 1 0
force -freeze sim:/processor/in_port 16#00001111 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD

run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD


force -freeze sim:/processor/intr_in 1 0
force -freeze sim:/processor/in_port 16#00001111 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $CLOCK_PERIOD
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
force -freeze sim:/processor/in_port 16#0000BEEF 0
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
force -freeze sim:/processor/in_port 16#00007777 0
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
force -freeze sim:/processor/intr_in 1 0
force -freeze sim:/processor/in_port 16#00001111 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $CLOCK_PERIOD
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
force -freeze sim:/processor/intr_in 1 0
force -freeze sim:/processor/in_port 16#00003333 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
force -freeze sim:/processor/reset 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/reset 0 0
run $RUN_TIME
run $RUN_TIME







wave zoom range {2500 ns} {4000 ns}
#wave zoom full


