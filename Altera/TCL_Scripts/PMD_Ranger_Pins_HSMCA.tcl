# PMD RX
set_instance_assignment -name IO_STANDARD LVDS -to PMD_end_r
set_instance_assignment -name IO_STANDARD LVDS -to PMD_end_c
set_location_assignment PIN_AM2 -to PMD_end_r
set_location_assignment PIN_AM1 -to "PMD_end_r(n)"
set_location_assignment PIN_AJ4 -to PMD_end_c
set_location_assignment PIN_AJ3 -to "PMD_end_c(n)"


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
set_location_assignment PIN_V10 -to PMD_clk_r
set_location_assignment PIN_W9 -to "PMD_clk_r(n)"
set_location_assignment PIN_AD4 -to PMD_clear_r
set_location_assignment PIN_AD3 -to "PMD_clear_r(n)"
set_location_assignment PIN_AE8 -to PMD_clk_c
set_location_assignment PIN_AE7 -to "PMD_clk_c(n)"
set_location_assignment PIN_AF6 -to PMD_clear_c
set_location_assignment PIN_AF5 -to "PMD_clear_c(n)"
set_location_assignment PIN_Y10 -to PMD_hold
set_location_assignment PIN_Y9 -to "PMD_hold(n)"
set_location_assignment PIN_AE6 -to PMD_mod
set_location_assignment PIN_AE5 -to "PMD_mod(n)"
set_location_assignment PIN_AD7 -to PMD_reset_n
set_location_assignment PIN_AD6 -to "PMD_reset_n(n)"
set_location_assignment PIN_W12 -to PMD_start_r
set_location_assignment PIN_Y11 -to "PMD_start_r(n)"
set_location_assignment PIN_AH5 -to PMD_start_c
set_location_assignment PIN_AH4 -to "PMD_start_c(n)"

# ADC RX
set_instance_assignment -name IO_STANDARD LVDS -to ADC_d[7..0]
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sdata_read
set_location_assignment PIN_AF2 -to ADC_d[0]
set_location_assignment PIN_AF1 -to "ADC_d[0](n)"
set_location_assignment PIN_AE2 -to ADC_d[1]
set_location_assignment PIN_AE1 -to "ADC_d[1](n)"
set_location_assignment PIN_AE4 -to ADC_d[2]
set_location_assignment PIN_AE3 -to "ADC_d[2](n)"
set_location_assignment PIN_AC2 -to ADC_d[3]
set_location_assignment PIN_AD1 -to "ADC_d[3](n)"
set_location_assignment PIN_AA1 -to ADC_d[4]
set_location_assignment PIN_AB1 -to "ADC_d[4](n)"
set_location_assignment PIN_AC4 -to ADC_d[5]
set_location_assignment PIN_AB3 -to "ADC_d[5](n)"
set_location_assignment PIN_AB2 -to ADC_d[6]
set_location_assignment PIN_AC1 -to "ADC_d[6](n)"
set_location_assignment PIN_AB4 -to ADC_d[7]
set_location_assignment PIN_AA3 -to "ADC_d[7](n)"
set_location_assignment PIN_AL2 -to ADC_sdata_read
set_location_assignment PIN_AL1 -to "ADC_sdata_read(n)"

# ADC TX
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sload
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sdata_write
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sdata_we_n
set_instance_assignment -name IO_STANDARD LVDS -to ADC_sclk
set_instance_assignment -name IO_STANDARD LVDS -to ADC_cdsclk
set_instance_assignment -name IO_STANDARD LVDS -to ADC_adcclk
set_location_assignment PIN_AB6 -to ADC_adcclk
set_location_assignment PIN_AB5 -to "ADC_adcclk(n)"
set_location_assignment PIN_AC6 -to ADC_cdsclk
set_location_assignment PIN_AC5 -to "ADC_cdsclk(n)"
set_location_assignment PIN_Y6 -to ADC_sclk
set_location_assignment PIN_Y5 -to "ADC_sclk(n)"
set_location_assignment PIN_AB8 -to ADC_sload
set_location_assignment PIN_AC7 -to "ADC_sload(n)"
set_location_assignment PIN_AA7 -to ADC_sdata_write
set_location_assignment PIN_AA6 -to "ADC_sdata_write(n)"
set_location_assignment PIN_Y8 -to ADC_sdata_we_n
set_location_assignment PIN_Y7 -to "ADC_sdata_we_n(n)"

# Other RX
set_instance_assignment -name IO_STANDARD LVDS -to laser_rx
set_instance_assignment -name IO_STANDARD LVDS -to spare_rx
set_location_assignment PIN_AA4 -to spare_rx
set_location_assignment PIN_Y3 -to "spare_rx(n)"
set_location_assignment PIN_AG4 -to laser_rx
set_location_assignment PIN_AG3 -to "laser_rx(n)"

# Other TX
set_instance_assignment -name IO_STANDARD LVDS -to laser_tx
set_instance_assignment -name IO_STANDARD LVDS -to laser_mod_1
set_instance_assignment -name IO_STANDARD LVDS -to laser_mod_2
set_instance_assignment -name IO_STANDARD LVDS -to spare_tx
set_location_assignment PIN_AA12 -to laser_tx
set_location_assignment PIN_AB11 -to "laser_tx(n)"
set_location_assignment PIN_AC9 -to laser_mod_1
set_location_assignment PIN_AC8 -to "laser_mod_1(n)"
set_location_assignment PIN_AC11 -to laser_mod_2
set_location_assignment PIN_AB10 -to "laser_mod_2(n)"
set_location_assignment PIN_W8 -to spare_tx
set_location_assignment PIN_W7 -to "spare_tx(n)"








