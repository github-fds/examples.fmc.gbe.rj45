@ECHO OFF
SET PLIOBJS=""

vlib work
vlog -lint -work work -f modelsim.args
vsim -novopt -l transcript -c -do "run -all; quit" work.top work.glbl
