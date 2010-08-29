# Clocks and Reset
set_instance_assignment -name IO_STANDARD "1.8 V" -to clk50
set_instance_assignment -name IO_STANDARD "1.8 V" -to clk125
set_location_assignment PIN_T33 -to clk50
set_location_assignment PIN_B16 -to clk125
set_instance_assignment -name IO_STANDARD "2.5 V" -to reset_n
set_location_assignment PIN_AP5 -to reset_n
set_instance_assignment -name TOGGLE_RATE "0 MHz" -to reset_n

# Push buttons
set_instance_assignment -name IO_STANDARD "1.8 V" -to buttons
set_location_assignment PIN_B17 -to buttons[0]
set_location_assignment PIN_A17 -to buttons[1]
set_location_assignment PIN_A16 -to buttons[2]
set_location_assignment PIN_K17 -to buttons[3]
set_instance_assignment -name TOGGLE_RATE "0 MHz" -to buttons

# LEDs
set_instance_assignment -name IO_STANDARD "1.8 V" -to leds
set_location_assignment PIN_F21 -to leds[0]
set_location_assignment PIN_C23 -to leds[1]
set_location_assignment PIN_B23 -to leds[2]
set_location_assignment PIN_A23 -to leds[3]
set_location_assignment PIN_D19 -to leds[4]
set_location_assignment PIN_C19 -to leds[5]
set_location_assignment PIN_F19 -to leds[6]
set_location_assignment PIN_E19 -to leds[7]

# Dip Switches
set_instance_assignment -name IO_STANDARD "1.8 V" -to switches
set_location_assignment PIN_B19 -to switches[0]
set_location_assignment PIN_A19 -to switches[1]
set_location_assignment PIN_C18 -to switches[2]
set_location_assignment PIN_A20 -to switches[3]
set_location_assignment PIN_K19 -to switches[4]
set_location_assignment PIN_J19 -to switches[5]
set_location_assignment PIN_L19 -to switches[6]
set_location_assignment PIN_L20 -to switches[7]
set_instance_assignment -name TOGGLE_RATE "0 MHz" -to switches

# Seven Segment Displays
# In order of (MSB downto LSB), cathodes are: minus & dp & g & f & e & d & c & b & a
# Anodes have MSB to the left
set_instance_assignment -name IO_STANDARD "2.5 V" -to ssd_c
set_instance_assignment -name IO_STANDARD "2.5 V" -to ssd_a
set_location_assignment PIN_AE10 -to ssd_c[0]
set_location_assignment PIN_AL5 -to ssd_c[1]
set_location_assignment PIN_AC12 -to ssd_c[2]
set_location_assignment PIN_AM5 -to ssd_c[3]
set_location_assignment PIN_AF11 -to ssd_c[4]
set_location_assignment PIN_AM6 -to ssd_c[5]
set_location_assignment PIN_AP3 -to ssd_c[6]
set_location_assignment PIN_AK6 -to ssd_c[7]
set_location_assignment PIN_AH11 -to ssd_c[8]
set_location_assignment PIN_AM4 -to ssd_a[3]
set_location_assignment PIN_AE12 -to ssd_a[2]
set_location_assignment PIN_AL4 -to ssd_a[1]
set_location_assignment PIN_AH8 -to ssd_a[0]

# LCD display interface
set_instance_assignment -name IO_STANDARD "2.5 V" -to lcd_RW
set_instance_assignment -name IO_STANDARD "2.5 V" -to lcd_RS
set_instance_assignment -name IO_STANDARD "2.5 V" -to lcd_E
set_instance_assignment -name IO_STANDARD "2.5 V" -to lcd_data
set_location_assignment PIN_AD12 -to lcd_E
set_location_assignment PIN_AP2 -to lcd_RS
set_location_assignment PIN_AJ8 -to lcd_data[0]
set_location_assignment PIN_AJ6 -to lcd_data[1]
set_location_assignment PIN_AD13 -to lcd_data[2]
set_location_assignment PIN_AJ7 -to lcd_data[3]
set_location_assignment PIN_AF10 -to lcd_data[4]
set_location_assignment PIN_AN6 -to lcd_data[5]
set_location_assignment PIN_AN3 -to lcd_data[6]
set_location_assignment PIN_AK7 -to lcd_data[7]
set_location_assignment PIN_AL8 -to lcd_RW