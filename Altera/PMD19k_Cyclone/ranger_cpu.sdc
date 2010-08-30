# Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	ranger_cpu 	ranger_cpu:the_ranger_cpu
set 	ranger_cpu_oci 	ranger_cpu_nios2_oci:the_ranger_cpu_nios2_oci
set 	ranger_cpu_oci_break 	ranger_cpu_nios2_oci_break:the_ranger_cpu_nios2_oci_break
set 	ranger_cpu_ocimem 	ranger_cpu_nios2_ocimem:the_ranger_cpu_nios2_ocimem
set 	ranger_cpu_oci_debug 	ranger_cpu_nios2_oci_debug:the_ranger_cpu_nios2_oci_debug
set 	ranger_cpu_wrapper 	ranger_cpu_jtag_debug_module_wrapper:the_ranger_cpu_jtag_debug_module_wrapper
set 	ranger_cpu_jtag_tck 	ranger_cpu_jtag_debug_module_tck:the_ranger_cpu_jtag_debug_module_tck
set 	ranger_cpu_jtag_sysclk 	ranger_cpu_jtag_debug_module_sysclk:the_ranger_cpu_jtag_debug_module_sysclk
set 	ranger_cpu_oci_path 	 [format "%s|%s" $ranger_cpu $ranger_cpu_oci]
set 	ranger_cpu_oci_break_path 	 [format "%s|%s" $ranger_cpu_oci_path $ranger_cpu_oci_break]
set 	ranger_cpu_ocimem_path 	 [format "%s|%s" $ranger_cpu_oci_path $ranger_cpu_ocimem]
set 	ranger_cpu_oci_debug_path 	 [format "%s|%s" $ranger_cpu_oci_path $ranger_cpu_oci_debug]
set 	ranger_cpu_jtag_tck_path 	 [format "%s|%s|%s" $ranger_cpu_oci_path $ranger_cpu_wrapper $ranger_cpu_jtag_tck]
set 	ranger_cpu_jtag_sysclk_path 	 [format "%s|%s|%s" $ranger_cpu_oci_path $ranger_cpu_wrapper $ranger_cpu_jtag_sysclk]
set 	ranger_cpu_jtag_sr 	 [format "%s|*sr" $ranger_cpu_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$ranger_cpu_oci_break_path|break_readreg*] -to [get_keepers *$ranger_cpu_jtag_sr*]
set_false_path -from [get_keepers *$ranger_cpu_oci_debug_path|*resetlatch]     -to [get_keepers *$ranger_cpu_jtag_sr[33]]
set_false_path -from [get_keepers *$ranger_cpu_oci_debug_path|monitor_ready]  -to [get_keepers *$ranger_cpu_jtag_sr[0]]
set_false_path -from [get_keepers *$ranger_cpu_oci_debug_path|monitor_ready]  -to [get_keepers *$ranger_cpu_jtag_tck_path|monitor_ready_sync1]
set_false_path -from [get_keepers *$ranger_cpu_oci_debug_path|monitor_error]  -to [get_keepers *$ranger_cpu_jtag_sr[34]]
set_false_path -from [get_keepers *$ranger_cpu_ocimem_path|*MonDReg*] -to [get_keepers *$ranger_cpu_jtag_sr*]
set_false_path -from [get_keepers *$ranger_cpu|hbreak_enabled] -to [get_keepers *$ranger_cpu_jtag_tck_path|debugack_sync1]
set_false_path -from *$ranger_cpu_jtag_sr*    -to *$ranger_cpu_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:sld_hub_inst* -to *$ranger_cpu_jtag_sysclk_path|uir_sync1
set_false_path -from sld_hub:sld_hub_inst* -to *$ranger_cpu_jtag_sysclk_path|udr_sync1
set_false_path -from sld_hub:sld_hub_inst|sld_dffex*|Q* -to *$ranger_cpu_jtag_sysclk_path|ir*
set_false_path -from sld_hub:sld_hub_inst|sld_jtag_state_machine:jtag_state_machine|state[1] -to *$ranger_cpu_oci_debug_path|monitor_go
