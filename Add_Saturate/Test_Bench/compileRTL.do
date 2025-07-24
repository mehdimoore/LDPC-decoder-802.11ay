# Create design library
if [file exists work] {vdel -lib work -all}
vlib work

# Create and open project
project new . compile_project
project open compile_project

# Add source files to project
project addfile "RTL/Add_Saturate.sv"
project addfile "Test_Bench/Add_Saturate_TB.sv"

# Calculate compilation order
project calculateorder
set compcmd [project compileall -n]
quit

