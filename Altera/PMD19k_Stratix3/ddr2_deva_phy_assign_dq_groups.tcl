#Please Run This Script Before Compiling
if {![info exists ::ppl_instance_name]} {set ::ppl_instance_name {}} 
set dq_pin_name ${::ppl_instance_name}mem_dq
set dqs_pin_name ${::ppl_instance_name}mem_dqs
set dm_pin_name ${::ppl_instance_name}mem_dm
set mem_clk_pin_name ${::ppl_instance_name}mem_clk
set mem_clk_n_pin_name ${::ppl_instance_name}mem_clk_n
set dqsn_pin_name ${::ppl_instance_name}mem_dqsn
set_instance_assignment -name DQ_GROUP 9 -to ${dq_pin_name}\[0..7\] -from ${dqs_pin_name}\[0\]
set_instance_assignment -name DQ_GROUP 9 -to ${dm_pin_name}\[0\] -from ${dqs_pin_name}\[0\]
set_instance_assignment -name DQSB_DQS_PAIR ON -from ${dqsn_pin_name}\[0\] -to ${dqs_pin_name}\[0\]
