## Test 2
# FETCH
run $CLOCK_PERIOD 
# DECODE
run $CLOCK_PERIOD 
force -freeze sim:/processor/in_port 16#00000050 0
# EXECUTE-1
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000030 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000300 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000100 0
run $CLOCK_PERIOD

run $RUN_TIME
