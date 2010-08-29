# DM9000A Ethernet Pins for DE2 board
#set_location_assignment PIN_B24 -to ENET_CLK
#set_location_assignment PIN_A21 -to ENET_CMD
#set_location_assignment PIN_A23 -to ENET_CS_N
#set_location_assignment PIN_B21 -to ENET_INT
#set_location_assignment PIN_A22 -to ENET_RD_N
#set_location_assignment PIN_B22 -to ENET_WR_N
#set_location_assignment PIN_B23 -to ENET_RST_N
#set_location_assignment PIN_D17 -to ENET_DATA[0]
#set_location_assignment PIN_C17 -to ENET_DATA[1]
#set_location_assignment PIN_B18 -to ENET_DATA[2]
#set_location_assignment PIN_A18 -to ENET_DATA[3]
#set_location_assignment PIN_B17 -to ENET_DATA[4]
#set_location_assignment PIN_A17 -to ENET_DATA[5]
#set_location_assignment PIN_B16 -to ENET_DATA[6]
#set_location_assignment PIN_B15 -to ENET_DATA[7]
#set_location_assignment PIN_B20 -to ENET_DATA[8]
#set_location_assignment PIN_A20 -to ENET_DATA[9]
#set_location_assignment PIN_C19 -to ENET_DATA[10]
#set_location_assignment PIN_D19 -to ENET_DATA[11]
#set_location_assignment PIN_B19 -to ENET_DATA[12]
#set_location_assignment PIN_A19 -to ENET_DATA[13]
#set_location_assignment PIN_E18 -to ENET_DATA[14]
#set_location_assignment PIN_D18 -to ENET_DATA[15]

# DM9000A Ethernet Pins for DE2 board - Using Tony's board in JP2
set_location_assignment PIN_K26 -to ENET_CLK
set_location_assignment PIN_M21 -to ENET_CMD
# CS_N Attached to 'spare1'
set_location_assignment PIN_M23 -to ENET_CS_N 
set_location_assignment PIN_N20 -to ENET_INT
set_location_assignment PIN_M20 -to ENET_RD_N
set_location_assignment PIN_M19 -to ENET_WR_N
# RST_N Attached to 'spare2'
set_location_assignment PIN_M22 -to ENET_RST_N
set_location_assignment PIN_T23 -to ENET_DATA[0]
set_location_assignment PIN_T24 -to ENET_DATA[1]
set_location_assignment PIN_T25 -to ENET_DATA[2]
set_location_assignment PIN_T18 -to ENET_DATA[3]
set_location_assignment PIN_T21 -to ENET_DATA[4]
set_location_assignment PIN_T20 -to ENET_DATA[5]
set_location_assignment PIN_U26 -to ENET_DATA[6]
set_location_assignment PIN_U25 -to ENET_DATA[7]
set_location_assignment PIN_M24 -to ENET_DATA[8]
set_location_assignment PIN_M25 -to ENET_DATA[9]
set_location_assignment PIN_N24 -to ENET_DATA[10]
set_location_assignment PIN_P24 -to ENET_DATA[11]
set_location_assignment PIN_R25 -to ENET_DATA[12]
set_location_assignment PIN_R24 -to ENET_DATA[13]
set_location_assignment PIN_R20 -to ENET_DATA[14]
set_location_assignment PIN_T22 -to ENET_DATA[15]

# LCD Display is also useful
set_location_assignment PIN_J1 -to lcd_data[0]
set_location_assignment PIN_J2 -to lcd_data[1]
set_location_assignment PIN_H1 -to lcd_data[2]
set_location_assignment PIN_H2 -to lcd_data[3]
set_location_assignment PIN_J4 -to lcd_data[4]
set_location_assignment PIN_J3 -to lcd_data[5]
set_location_assignment PIN_H4 -to lcd_data[6]
set_location_assignment PIN_H3 -to lcd_data[7]
set_location_assignment PIN_K3 -to lcd_E
set_location_assignment PIN_K1 -to lcd_RS
set_location_assignment PIN_K4 -to lcd_RW

# And the HEX display
set_location_assignment PIN_AF10 -to HEX0[0]
set_location_assignment PIN_AB12 -to HEX0[1]
set_location_assignment PIN_AC12 -to HEX0[2]
set_location_assignment PIN_AD11 -to HEX0[3]
set_location_assignment PIN_AE11 -to HEX0[4]
set_location_assignment PIN_V14 -to HEX0[5]
set_location_assignment PIN_V13 -to HEX0[6]
set_location_assignment PIN_V20 -to HEX1[0]
set_location_assignment PIN_V21 -to HEX1[1]
set_location_assignment PIN_W21 -to HEX1[2]
set_location_assignment PIN_Y22 -to HEX1[3]
set_location_assignment PIN_AA24 -to HEX1[4]
set_location_assignment PIN_AA23 -to HEX1[5]
set_location_assignment PIN_AB24 -to HEX1[6]
set_location_assignment PIN_AB23 -to HEX2[0]
set_location_assignment PIN_V22 -to HEX2[1]
set_location_assignment PIN_AC25 -to HEX2[2]
set_location_assignment PIN_AC26 -to HEX2[3]
set_location_assignment PIN_AB26 -to HEX2[4]
set_location_assignment PIN_AB25 -to HEX2[5]
set_location_assignment PIN_Y24 -to HEX2[6]
set_location_assignment PIN_Y23 -to HEX3[0]
set_location_assignment PIN_AA25 -to HEX3[1]
set_location_assignment PIN_AA26 -to HEX3[2]
set_location_assignment PIN_Y26 -to HEX3[3]
set_location_assignment PIN_Y25 -to HEX3[4]
set_location_assignment PIN_U22 -to HEX3[5]
set_location_assignment PIN_W24 -to HEX3[6]


