#
# Settings: DDR2 chips on the board
# device A
#
set_instance_assignment -name DQ_GROUP 9 -from ddr2_deva_dqs_p -to ddr2_deva_dq[0..7]
set_instance_assignment -name DQ_GROUP 9 -from ddr2_deva_dqs_p -to ddr2_deva_dm
set_instance_assignment -name DQSB_DQS_PAIR ON -from ddr2_deva_dqs_n -to ddr2_deva_dqs_p
#set_instance_assignment -name OUTPUT_ENABLE_GROUP 10 -to ddr2_deva*
#
# Pin assignments
#
set_location_assignment PIN_J26 -to vref_dev
set_location_assignment PIN_F34 -to ddr2_deva_a[0]
set_location_assignment PIN_G34 -to ddr2_deva_a[1]
set_location_assignment PIN_G31 -to ddr2_deva_a[2]
set_location_assignment PIN_N24 -to ddr2_deva_a[3]
set_location_assignment PIN_L29 -to ddr2_deva_a[4]
set_location_assignment PIN_M30 -to ddr2_deva_a[5]
set_location_assignment PIN_L31 -to ddr2_deva_a[6]
set_location_assignment PIN_P25 -to ddr2_deva_a[7]
set_location_assignment PIN_K33 -to ddr2_deva_a[8]
set_location_assignment PIN_M29 -to ddr2_deva_a[9]
set_location_assignment PIN_J34 -to ddr2_deva_a[10]
set_location_assignment PIN_L32 -to ddr2_deva_a[11]
set_location_assignment PIN_P23 -to ddr2_deva_a[12]
set_location_assignment PIN_M26 -to ddr2_deva_a[13]
set_location_assignment PIN_N26 -to ddr2_deva_a[14]
set_location_assignment PIN_H34 -to ddr2_deva_ba[0]
set_location_assignment PIN_K30 -to ddr2_deva_ba[1]
set_location_assignment PIN_J33 -to ddr2_deva_ba[2]
set_location_assignment PIN_G30 -to ddr2_deva_casn
set_location_assignment PIN_K32 -to ddr2_deva_ck_n
set_location_assignment PIN_K31 -to ddr2_deva_ck_p
set_location_assignment PIN_M27 -to ddr2_deva_cke
set_location_assignment PIN_E34 -to ddr2_deva_csn
set_location_assignment PIN_F31 -to ddr2_deva_dm
set_location_assignment PIN_K27 -to ddr2_deva_dq[0]
set_location_assignment PIN_J30 -to ddr2_deva_dq[1]
set_location_assignment PIN_K28 -to ddr2_deva_dq[2]
set_location_assignment PIN_J29 -to ddr2_deva_dq[3]
set_location_assignment PIN_H32 -to ddr2_deva_dq[4]
set_location_assignment PIN_M24 -to ddr2_deva_dq[5]
set_location_assignment PIN_H31 -to ddr2_deva_dq[6]
set_location_assignment PIN_N25 -to ddr2_deva_dq[7]
set_location_assignment PIN_C34 -to ddr2_deva_dqs_n
set_location_assignment PIN_C33 -to ddr2_deva_dqs_p
set_location_assignment PIN_M28 -to ddr2_deva_odt
set_location_assignment PIN_F32 -to ddr2_deva_rasn
set_location_assignment PIN_G33 -to ddr2_deva_wen

#
# IO Standards
#
#set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ddr2_deva_ck_p
#set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ddr2_deva_ck_n
#set_instance_assignment -name XSTL_INPUT_ALLOW_SE_BUFFER ON -to ddr2_deva_ck_p
#set_instance_assignment -name XSTL_INPUT_ALLOW_SE_BUFFER ON -to ddr2_deva_ck_n
#set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr2_deva_odt
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[7]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[8]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[9]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[10]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[11]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[12]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[13]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_a[14]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_ba
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_ba[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_ba[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_ba[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_casn
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_deva_ck_n
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_deva_ck_p
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_cke
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_csn
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dm
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_deva_dq[7]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_deva_dq[0]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_deva_dq[1]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_deva_dq[2]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_deva_dq[3]
#set_instance_assignment -name D5_DELAY 0 -to ddr2_deva_dq[4]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_deva_dq[5]
#set_instance_assignment -name D5_DELAY 0 -to ddr2_deva_dq[6]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_deva_dq[7]
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_deva_dqs_n
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_deva_dqs_p
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_odt
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_rasn
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_deva_wen

