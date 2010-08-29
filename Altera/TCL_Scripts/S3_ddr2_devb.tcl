#
# Settings: DDR2 chips on the board
# device B
#
set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[0..7]
set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dm
set_instance_assignment -name DQSB_DQS_PAIR ON -from ddr2_devb_dqs_n -to ddr2_devb_dqs_p
#
# Pin assignments
#
set_location_assignment PIN_J26 -to vref_dev
set_location_assignment PIN_R27 -to ddr2_devb_a[0]
set_location_assignment PIN_R29 -to ddr2_devb_a[1]
set_location_assignment PIN_J31 -to ddr2_devb_a[2]
set_location_assignment PIN_U32 -to ddr2_devb_a[3]
set_location_assignment PIN_K34 -to ddr2_devb_a[4]
set_location_assignment PIN_T23 -to ddr2_devb_a[5]
set_location_assignment PIN_M34 -to ddr2_devb_a[6]
set_location_assignment PIN_U31 -to ddr2_devb_a[7]
set_location_assignment PIN_R24 -to ddr2_devb_a[8]
set_location_assignment PIN_V31 -to ddr2_devb_a[9]
set_location_assignment PIN_P34 -to ddr2_devb_a[10]
set_location_assignment PIN_T29 -to ddr2_devb_a[11]
set_location_assignment PIN_V32 -to ddr2_devb_a[12]
set_location_assignment PIN_R28 -to ddr2_devb_a[13]
set_location_assignment PIN_T30 -to ddr2_devb_a[14]
set_location_assignment PIN_N32 -to ddr2_devb_ba[0]
set_location_assignment PIN_N33 -to ddr2_devb_ba[1]
set_location_assignment PIN_R30 -to ddr2_devb_ba[2]
set_location_assignment PIN_U25 -to ddr2_devb_casn
set_location_assignment PIN_R32 -to ddr2_devb_ck_n
set_location_assignment PIN_P31 -to ddr2_devb_ck_p
set_location_assignment PIN_N34 -to ddr2_devb_cke
set_location_assignment PIN_J32 -to ddr2_devb_csn
set_location_assignment PIN_M31 -to ddr2_devb_dm
set_location_assignment PIN_P29 -to ddr2_devb_dq[0]
set_location_assignment PIN_P32 -to ddr2_devb_dq[1]
set_location_assignment PIN_N30 -to ddr2_devb_dq[2]
set_location_assignment PIN_N31 -to ddr2_devb_dq[3]
set_location_assignment PIN_R26 -to ddr2_devb_dq[4]
set_location_assignment PIN_P28 -to ddr2_devb_dq[5]
set_location_assignment PIN_R25 -to ddr2_devb_dq[6]
set_location_assignment PIN_N29 -to ddr2_devb_dq[7]
set_location_assignment PIN_L34 -to ddr2_devb_dqs_n
set_location_assignment PIN_M33 -to ddr2_devb_dqs_p
set_location_assignment PIN_D34 -to ddr2_devb_odt
set_location_assignment PIN_D33 -to ddr2_devb_rasn
set_location_assignment PIN_T26 -to ddr2_devb_wen

#
# IO Standards
#
#set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ddr2_devb_ck_p
#set_instance_assignment -name OUTPUT_TERMINATION "SERIES 50 OHM WITHOUT CALIBRATION" -to ddr2_devb_ck_n
#set_instance_assignment -name XSTL_INPUT_ALLOW_SE_BUFFER ON -to ddr2_devb_ck_p
#set_instance_assignment -name XSTL_INPUT_ALLOW_SE_BUFFER ON -to ddr2_devb_ck_n
#set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ddr2_devb_odt
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[7]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[8]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[9]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[10]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[11]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[12]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[13]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_a[14]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_ba
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_ba[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_ba[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_ba[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_casn
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_devb_ck_n
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_devb_ck_p
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_cke
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_csn
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dm
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[0]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[1]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[2]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[3]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[4]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[5]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[6]
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS II" -to ddr2_devb_dq[7]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_devb_dq[0]
#set_instance_assignment -name D5_DELAY 0 -to ddr2_devb_dq[1]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_devb_dq[2]
#set_instance_assignment -name D5_DELAY 0 -to ddr2_devb_dq[3]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_devb_dq[4]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_devb_dq[5]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_devb_dq[6]
#set_instance_assignment -name D5_DELAY 1 -to ddr2_devb_dq[7]
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_devb_dqs_n
set_instance_assignment -name IO_STANDARD "Differential 1.8-V SSTL CLASS I" -to ddr2_devb_dqs_p
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_odt
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_rasn
set_instance_assignment -name IO_STANDARD "SSTL-18 CLASS I" -to ddr2_devb_wen

#
# Group settings
#
#set_instance_assignment -name OUTPUT_ENABLE_GROUP 2 -to ddr2_devb*
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[0]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[1]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[2]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[3]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[4]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[5]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[6]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dq[7]
#set_instance_assignment -name DQ_GROUP 9 -from ddr2_devb_dqs_p -to ddr2_devb_dm[0]