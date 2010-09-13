# PMD RX
set_instance_assignment -name IO_STANDARD LVDS -to PMD_end_r
set_instance_assignment -name IO_STANDARD LVDS -to PMD_end_c
set_location_assignment PIN_P2 -to PMD_end_r
set_location_assignment PIN_R1 -to "PMD_end_r(n)"
set_location_assignment PIN_R4 -to PMD_end_c
set_location_assignment PIN_R3 -to "PMD_end_c(n)"


# PMD TX
set_instance_assignment -name IO_STANDARD LVDS -to PMD_clk_r
set_instance_assignment -name IO_STANDARD LVDS -to PMD_clear_r
set_instance_assignment -name IO_STANDARD LVDS -to PMD_clk_c
set_instance_assignment -name IO_STANDARD LVDS -to PMD_clear_c
set_instance_assignment -name IO_STANDARD LVDS -to PMD_start_r
set_instance_assignment -name IO_STANDARD LVDS -to PMD_start_c
set_instance_assignment -name IO_STANDARD LVDS -to PMD_reset_n
set_instance_assignment -name IO_STANDARD LVDS -to PMD_mod
set_instance_assignment -name IO_STANDARD LVDS -to PMD_hold
set_location_assignment PIN_P6 -to PMD_clk_r
set_location_assignment PIN_P5 -to "PMD_clk_r(n)"
set_location_assignment PIN_M7 -to PMD_clear_r
set_location_assignment PIN_M6 -to "PMD_clear_r(n)"
set_location_assignment PIN_T5 -to PMD_clk_c
set_location_assignment PIN_T4 -to "PMD_clk_c(n)"
set_location_assignment PIN_R10 -to PMD_clear_c
set_location_assignment PIN_R9 -to "PMD_clear_c(n)"
set_location_assignment PIN_L9 -to PMD_hold
set_location_assignment PIN_L8 -to "PMD_hold(n)"
set_location_assignment PIN_N9 -to PMD_mod
set_location_assignment PIN_N8 -to "PMD_mod(n)"
set_location_assignment PIN_R7 -to PMD_reset_n
set_location_assignment PIN_R6 -to "PMD_reset_n(n)"
set_location_assignment PIN_M10 -to PMD_start_r
set_location_assignment PIN_M9 -to "PMD_start_r(n)"
set_location_assignment PIN_T7 -to PMD_start_c
set_location_assignment PIN_U6 -to "PMD_start_c(n)"

# ADC RX
set_instance_assignment -name IO_STANDARD LVDS -to ADC_d[7..0]
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sdata_read
set_location_assignment PIN_H2 -to ADC_d[0]
set_location_assignment PIN_J1 -to "ADC_d[0](n)"
set_location_assignment PIN_G2 -to ADC_d[1]
set_location_assignment PIN_H1 -to "ADC_d[1](n)"
set_location_assignment PIN_F1 -to ADC_d[2]
set_location_assignment PIN_G1 -to "ADC_d[2](n)"
set_location_assignment PIN_H4 -to ADC_d[3]
set_location_assignment PIN_H3 -to "ADC_d[3](n)"
set_location_assignment PIN_C1 -to ADC_d[4]
set_location_assignment PIN_D1 -to "ADC_d[4](n)"
set_location_assignment PIN_D3 -to ADC_d[5]
set_location_assignment PIN_D2 -to "ADC_d[5](n)"
set_location_assignment PIN_E2 -to ADC_d[6]
set_location_assignment PIN_E1 -to "ADC_d[6](n)"
set_location_assignment PIN_G5 -to ADC_d[7]
set_location_assignment PIN_G4 -to "ADC_d[7](n)"
set_location_assignment PIN_N2 -to ADC_sdata_read
set_location_assignment PIN_P1 -to "ADC_sdata_read(n)"

# ADC TX
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sload
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sdata_write
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sdata_we_n
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sclk
set_instance_assignment -name IO_STANDARD LVDS -to ADC_cdsclk
set_instance_assignment -name IO_STANDARD LVDS -to ADC_adcclk
set_location_assignment PIN_L5 -to ADC_adcclk
set_location_assignment PIN_L4 -to "ADC_adcclk(n)"
set_location_assignment PIN_L7 -to ADC_cdsclk
set_location_assignment PIN_L6 -to "ADC_cdsclk(n)"
set_location_assignment PIN_J7 -to ADC_sclk
set_location_assignment PIN_J6 -to "ADC_sclk(n)"
set_location_assignment PIN_K6 -to ADC_sload
set_location_assignment PIN_K5 -to "ADC_sload(n)"
set_location_assignment PIN_H6 -to ADC_sdata_write
set_location_assignment PIN_H5 -to "ADC_sdata_write(n)"
set_location_assignment PIN_K8 -to ADC_sdata_we_n
set_location_assignment PIN_K7 -to "ADC_sdata_we_n(n)"

# Other RX
set_instance_assignment -name IO_STANDARD LVDS -to laser_rx
set_instance_assignment -name IO_STANDARD LVDS -to spare_rx
set_location_assignment PIN_F4 -to spare_rx
set_location_assignment PIN_F3 -to "spare_rx(n)"
set_location_assignment PIN_P4 -to laser_rx
set_location_assignment PIN_P3 -to "laser_rx(n)"

# Other TX
set_instance_assignment -name IO_STANDARD LVDS -to laser_tx
set_instance_assignment -name IO_STANDARD LVDS -to laser_mod_1
set_instance_assignment -name IO_STANDARD LVDS -to laser_mod_2
set_instance_assignment -name IO_STANDARD LVDS -to spare_tx
set_location_assignment PIN_N11 -to laser_tx
set_location_assignment PIN_N10 -to "laser_tx(n)"
set_location_assignment PIN_T9 -to laser_mod_1
set_location_assignment PIN_T8 -to "laser_mod_1(n)"
set_location_assignment PIN_P11 -to laser_mod_2
set_location_assignment PIN_P10 -to "laser_mod_2(n)"
set_location_assignment PIN_R12 -to spare_tx
set_location_assignment PIN_T11 -to "spare_tx(n)"

set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to ADC_d[7..0]
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to ADC_sdata_read
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to PMD_end_r
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to PMD_end_c
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to laser_rx






