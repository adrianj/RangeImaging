# TCL File Generated by Component Editor 8.0
# Mon Aug 30 15:36:58 NZST 2010
# DO NOT MODIFY


# +-----------------------------------
# | 
# | nios_slave_16 "nios_slave_16" v10.11.2008
# | null 2010.08.30.15:36:58
# | 
# | 
# | D:/sync/PhD/RangeImaging/Altera/TCL_Scripts/nios_slave_16.vhd
# | 
# |    ./nios_slave_16.vhd syn, sim
# | 
# +-----------------------------------


# +-----------------------------------
# | module nios_slave_16
# | 
set_module_property DESCRIPTION ""
set_module_property NAME nios_slave_16
set_module_property VERSION 10.11.2008
set_module_property GROUP ""
set_module_property DISPLAY_NAME nios_slave_16
set_module_property LIBRARIES {ieee.std_logic_1164.all std.standard.all}
set_module_property TOP_LEVEL_HDL_FILE nios_slave_16.vhd
set_module_property TOP_LEVEL_HDL_MODULE nios_slave_16
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VERILOG false
set_module_property SIMULATION_MODEL_IN_VHDL false
set_module_property SIMULATION_MODEL_HAS_TULIPS false
set_module_property SIMULATION_MODEL_IS_OBFUSCATED false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file nios_slave_16.vhd {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave
# | 
add_interface avalon_slave avalon end
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave minimumUninterruptedRunLength 1
set_interface_property avalon_slave bridgesToMaster ""
set_interface_property avalon_slave isMemoryDevice false
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave addressSpan 262144
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave isNonVolatileStorage false
set_interface_property avalon_slave addressAlignment DYNAMIC
set_interface_property avalon_slave readWaitStates 0
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave readWaitTime 0
set_interface_property avalon_slave readLatency 1
set_interface_property avalon_slave printableDevice false

set_interface_property avalon_slave ASSOCIATED_CLOCK clock_reset

add_interface_port avalon_slave nios_addr address Input 16
add_interface_port avalon_slave nios_din writedata Input 32
add_interface_port avalon_slave nios_dout readdata Output 32
add_interface_port avalon_slave nios_we_n write_n Input 1
add_interface_port avalon_slave nios_re_n read_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point export
# | 
add_interface export conduit end

set_interface_property export ASSOCIATED_CLOCK clock_reset

add_interface_port export ex_reset_n export Output 1
add_interface_port export ex_clk export Output 1
add_interface_port export ex_re_n export Output 1
add_interface_port export ex_we_n export Output 1
add_interface_port export ex_addr export Output 16
add_interface_port export ex_dout export Input 32
add_interface_port export ex_din export Output 32
# | 
# +-----------------------------------