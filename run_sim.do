vlib work
vlog -f sourcefile.txt +cover +define+asser 
vsim -voptargs=+acc work.SYSTEM_TOP_TB -cover -classdebug -sv_seed 50
run 0
add wave *

add wave -position insertpoint sim:/SYSTEM_TOP_TB/uut/UART/*
add wave -position insertpoint  \
sim:/SYSTEM_TOP_TB/uut/UART/UART__TX/U0_fsm/current_state
add wave -position insertpoint  \
sim:/SYSTEM_TOP_TB/uut/UART/uart_rx0/FSM/cur_state
add wave -position insertpoint  \
sim:/SYSTEM_TOP_TB/uut/DATA_SYNC0/bus_enable \
sim:/SYSTEM_TOP_TB/uut/DATA_SYNC0/sync_bus
add wave -position insertpoint sim:/SYSTEM_TOP_TB/uut/SYS_CNTRL0/*
add wave -position insertpoint sim:/SYSTEM_TOP_TB/uut/RegFile0/*
add wave -position insertpoint  \
sim:/SYSTEM_TOP_TB/uut/RegFile0/regArr
add wave -position insertpoint sim:/SYSTEM_TOP_TB/uut/ALU0/*
add wave -position insertpoint sim:/SYSTEM_TOP_TB/uut/ASYNC_FIFO0/*
add wave -position insertpoint  \
sim:/SYSTEM_TOP_TB/uut/ASYNC_FIFO0/FIFO_Memory/mem

run -all
