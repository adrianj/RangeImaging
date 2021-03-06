#Please Run This Script Before Compiling
if {![info exists ::ppl_instance_name]} {set ::ppl_instance_name {}}
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_odt[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_odt[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ${::ppl_instance_name}mem_clk[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ${::ppl_instance_name}mem_clk[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ${::ppl_instance_name}mem_clk_n[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ${::ppl_instance_name}mem_clk_n[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_cs_n[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_cs_n[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_cke[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_cke[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[2]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[4]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[5]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[6]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[7]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[8]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[9]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[10]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[11]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_addr[12]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[7]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[8]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[9]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[10]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[11]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_addr[12]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_ba[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_ba[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_ba[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_ba[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_ras_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_ras_n
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_cas_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_cas_n
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ${::ppl_instance_name}mem_we_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_we_n
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dq[7]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[1]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[2]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[3]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[4]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[5]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[6]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dq[7]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[1]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[2]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[3]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[4]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[5]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[6]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dq[7]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ${::ppl_instance_name}mem_dqs[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dqs[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dqs[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.8-V SSTL CLASS I" -to ${::ppl_instance_name}mem_dqsn[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dqsn[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dqsn[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ${::ppl_instance_name}mem_dm[0]
set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITH CALIBRATION" -to ${::ppl_instance_name}mem_dm[0]
set_instance_assignment -name OUTPUT_ENABLE_GROUP "1743998283" -to ${::ppl_instance_name}mem_dm[0]

if { [file exists ddr2_deva_phy_assign_dq_groups.tcl] } {
source ddr2_deva_phy_assign_dq_groups.tcl }
