--Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ddr2_deva_controller_phy is 
        port (
              -- inputs:
                 signal dqs_delay_ctrl_import : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal global_reset_n : IN STD_LOGIC;
                 signal local_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal local_autopch_req : IN STD_LOGIC;
                 signal local_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal local_burstbegin : IN STD_LOGIC;
                 signal local_powerdn_req : IN STD_LOGIC;
                 signal local_read_req : IN STD_LOGIC;
                 signal local_refresh_req : IN STD_LOGIC;
                 signal local_self_rfsh_req : IN STD_LOGIC;
                 signal local_size : IN STD_LOGIC;
                 signal local_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal local_write_req : IN STD_LOGIC;
                 signal oct_ctl_rs_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal oct_ctl_rt_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal pll_reconfig : IN STD_LOGIC;
                 signal pll_reconfig_counter_param : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal pll_reconfig_counter_type : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pll_reconfig_data_in : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal pll_reconfig_enable : IN STD_LOGIC;
                 signal pll_reconfig_read_param : IN STD_LOGIC;
                 signal pll_reconfig_soft_reset_en_n : IN STD_LOGIC;
                 signal pll_reconfig_write_param : IN STD_LOGIC;
                 signal pll_ref_clk : IN STD_LOGIC;
                 signal soft_reset_n : IN STD_LOGIC;

              -- outputs:
                 signal aux_full_rate_clk : OUT STD_LOGIC;
                 signal aux_half_rate_clk : OUT STD_LOGIC;
                 signal dll_reference_clk : OUT STD_LOGIC;
                 signal dqs_delay_ctrl_export : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal local_init_done : OUT STD_LOGIC;
                 signal local_powerdn_ack : OUT STD_LOGIC;
                 signal local_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal local_rdata_valid : OUT STD_LOGIC;
                 signal local_ready : OUT STD_LOGIC;
                 signal local_refresh_ack : OUT STD_LOGIC;
                 signal local_self_rfsh_ack : OUT STD_LOGIC;
                 signal local_wdata_req : OUT STD_LOGIC;
                 signal mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal mem_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal mem_cas_n : OUT STD_LOGIC;
                 signal mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_dm : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_dq : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal mem_dqs : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_dqsn : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
                 signal mem_ras_n : OUT STD_LOGIC;
                 signal mem_reset_n : OUT STD_LOGIC;
                 signal mem_we_n : OUT STD_LOGIC;
                 signal phy_clk : OUT STD_LOGIC;
                 signal pll_reconfig_busy : OUT STD_LOGIC;
                 signal pll_reconfig_clk : OUT STD_LOGIC;
                 signal pll_reconfig_data_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal pll_reconfig_reset : OUT STD_LOGIC;
                 signal reset_phy_clk_n : OUT STD_LOGIC;
                 signal reset_request_n : OUT STD_LOGIC
              );
end entity ddr2_deva_controller_phy;


architecture europa of ddr2_deva_controller_phy is
  component ddr2_deva_auk_ddr_hp_controller_wrapper is
PORT (
    signal ddr_cke_h : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal local_init_done : OUT STD_LOGIC;
        signal ddr_ras_n : OUT STD_LOGIC;
        signal control_be : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal control_dqs_burst : OUT STD_LOGIC;
        signal ddr_we_n : OUT STD_LOGIC;
        signal ddr_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal control_wdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal ddr_cas_n : OUT STD_LOGIC;
        signal local_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_rdata_valid : OUT STD_LOGIC;
        signal ddr_cke_l : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal control_wdata_valid : OUT STD_LOGIC;
        signal ddr_a : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal local_ready : OUT STD_LOGIC;
        signal control_doing_wr : OUT STD_LOGIC;
        signal control_doing_rd : OUT STD_LOGIC;
        signal local_powerdn_ack : OUT STD_LOGIC;
        signal local_self_rfsh_ack : OUT STD_LOGIC;
        signal local_wdata_req : OUT STD_LOGIC;
        signal local_refresh_ack : OUT STD_LOGIC;
        signal ddr_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal ddr_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal local_autopch_req : IN STD_LOGIC;
        signal local_size : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal local_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_col_addr : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal local_row_addr : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal local_refresh_req : IN STD_LOGIC;
        signal reset_n : IN STD_LOGIC;
        signal local_bank_addr : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal local_burstbegin : IN STD_LOGIC;
        signal local_write_req : IN STD_LOGIC;
        signal local_self_rfsh_req : IN STD_LOGIC;
        signal local_powerdn_req : IN STD_LOGIC;
        signal local_cs_addr : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal control_rdata_valid : IN STD_LOGIC;
        signal control_rdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_read_req : IN STD_LOGIC;
        signal local_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal clk : IN STD_LOGIC
      );
  end component ddr2_deva_auk_ddr_hp_controller_wrapper;
  component ddr2_deva_phy is
PORT (
    signal mem_cke : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
        signal ctl_autopch_req : OUT STD_LOGIC;
        signal mem_dqsn : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal tracking_adjustment_down : OUT STD_LOGIC;
        signal local_init_done : OUT STD_LOGIC;
        signal mem_ras_n : OUT STD_LOGIC;
        signal tracking_adjustment_up : OUT STD_LOGIC;
        signal mem_cs_n : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal mem_reset_n : OUT STD_LOGIC;
        signal ctl_powerdn_req : OUT STD_LOGIC;
        signal ctl_size : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_be : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal ctl_usr_mode_rdy : OUT STD_LOGIC;
        signal pll_reconfig_data_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal ctl_wdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal aux_half_rate_clk : OUT STD_LOGIC;
        signal local_rdata_valid : OUT STD_LOGIC;
        signal mem_we_n : OUT STD_LOGIC;
        signal ctl_mem_rdata_valid : OUT STD_LOGIC;
        signal local_ready : OUT STD_LOGIC;
        signal mem_cas_n : OUT STD_LOGIC;
        signal pll_reconfig_reset : OUT STD_LOGIC;
        signal dll_reference_clk : OUT STD_LOGIC;
        signal local_powerdn_ack : OUT STD_LOGIC;
        signal local_wdata_req : OUT STD_LOGIC;
        signal local_refresh_ack : OUT STD_LOGIC;
        signal ctl_read_req : OUT STD_LOGIC;
        signal reset_request_n : OUT STD_LOGIC;
        signal mem_clk_n : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal mem_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal mem_dm : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pll_reconfig_clk : OUT STD_LOGIC;
        signal ctl_write_req : OUT STD_LOGIC;
        signal aux_full_rate_clk : OUT STD_LOGIC;
        signal mem_dq : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal phy_clk : OUT STD_LOGIC;
        signal tracking_successful : OUT STD_LOGIC;
        signal mem_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal pll_reconfig_busy : OUT STD_LOGIC;
        signal ctl_burstbegin : OUT STD_LOGIC;
        signal postamble_successful : OUT STD_LOGIC;
        signal dqs_delay_ctrl_export : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        signal local_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal ctl_refresh_req : OUT STD_LOGIC;
        signal reset_phy_clk_n : OUT STD_LOGIC;
        signal mem_odt : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal local_self_rfsh_ack : OUT STD_LOGIC;
        signal mem_clk : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_mem_rdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal ctl_self_rfsh_req : OUT STD_LOGIC;
        signal mem_dqs : INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal resynchronisation_successful : OUT STD_LOGIC;
        signal ctl_doing_rd : IN STD_LOGIC;
        signal pll_reconfig_data_in : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal local_autopch_req : IN STD_LOGIC;
        signal oct_ctl_rt_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
        signal ctl_mem_wdata_valid : IN STD_LOGIC;
        signal ctl_mem_cke_l : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_add_1t_ac_lat : IN STD_LOGIC;
        signal soft_reset_n : IN STD_LOGIC;
        signal pll_reconfig_counter_param : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal global_reset_n : IN STD_LOGIC;
        signal ctl_mem_cs_n_l : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_mem_cke_h : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_refresh_ack : IN STD_LOGIC;
        signal ctl_mem_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal oct_ctl_rs_value : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
        signal pll_reconfig_enable : IN STD_LOGIC;
        signal ctl_rdata_valid : IN STD_LOGIC;
        signal local_self_rfsh_req : IN STD_LOGIC;
        signal ctl_powerdn_ack : IN STD_LOGIC;
        signal ctl_mem_cs_n_h : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pll_reconfig_write_param : IN STD_LOGIC;
        signal ctl_init_done : IN STD_LOGIC;
        signal pll_ref_clk : IN STD_LOGIC;
        signal ctl_add_1t_odt_lat : IN STD_LOGIC;
        signal ctl_mem_we_n_l : IN STD_LOGIC;
        signal local_read_req : IN STD_LOGIC;
        signal local_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal ctl_mem_cas_n_h : IN STD_LOGIC;
        signal ctl_mem_odt_h : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_add_intermediate_regs : IN STD_LOGIC;
        signal local_size : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_mem_cas_n_l : IN STD_LOGIC;
        signal local_wdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_refresh_req : IN STD_LOGIC;
        signal ctl_mem_ras_n_l : IN STD_LOGIC;
        signal pll_reconfig_counter_type : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal dqs_delay_ctrl_import : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        signal ctl_mem_addr_l : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal ctl_negedge_en : IN STD_LOGIC;
        signal ctl_rdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal local_burstbegin : IN STD_LOGIC;
        signal pll_reconfig_read_param : IN STD_LOGIC;
        signal local_write_req : IN STD_LOGIC;
        signal ctl_mem_dqs_burst : IN STD_LOGIC;
        signal local_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
        signal local_powerdn_req : IN STD_LOGIC;
        signal ctl_mem_ras_n_h : IN STD_LOGIC;
        signal ctl_mem_be : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal ctl_ready : IN STD_LOGIC;
        signal ctl_mem_ba_l : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal ctl_self_rfsh_ack : IN STD_LOGIC;
        signal pll_reconfig : IN STD_LOGIC;
        signal ctl_mem_odt_l : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal ctl_mem_ba_h : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal ctl_wdata_req : IN STD_LOGIC;
        signal ctl_mem_addr_h : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal ctl_mem_we_n_h : IN STD_LOGIC
      );
  end component ddr2_deva_phy;
                signal bank_addr :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal col_addr :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal control_be :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal control_doing_rd :  STD_LOGIC;
                signal control_wdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal control_wdata_valid :  STD_LOGIC;
                signal cs_addr :  STD_LOGIC;
                signal ctl_address :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ctl_autopch_req :  STD_LOGIC;
                signal ctl_be :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ctl_burstbegin_sig :  STD_LOGIC;
                signal ctl_init_done :  STD_LOGIC;
                signal ctl_mem_a :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal ctl_mem_ba :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ctl_mem_cas_n :  STD_LOGIC;
                signal ctl_mem_cke_h :  STD_LOGIC;
                signal ctl_mem_cke_l :  STD_LOGIC;
                signal ctl_mem_cs_n :  STD_LOGIC;
                signal ctl_mem_odt :  STD_LOGIC;
                signal ctl_mem_ras_n :  STD_LOGIC;
                signal ctl_mem_rdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ctl_mem_rdata_valid :  STD_LOGIC;
                signal ctl_mem_we_n :  STD_LOGIC;
                signal ctl_powerdn_ack :  STD_LOGIC;
                signal ctl_powerdn_req :  STD_LOGIC;
                signal ctl_rdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ctl_rdata_valid :  STD_LOGIC;
                signal ctl_read_req :  STD_LOGIC;
                signal ctl_ready :  STD_LOGIC;
                signal ctl_refresh_ack :  STD_LOGIC;
                signal ctl_refresh_req_sig :  STD_LOGIC;
                signal ctl_self_rfsh_ack :  STD_LOGIC;
                signal ctl_self_rfsh_req :  STD_LOGIC;
                signal ctl_size :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal ctl_usr_mode_rdy_sig :  STD_LOGIC;
                signal ctl_wdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ctl_wdata_req :  STD_LOGIC;
                signal ctl_write_req :  STD_LOGIC;
                signal internal_aux_full_rate_clk :  STD_LOGIC;
                signal internal_aux_half_rate_clk :  STD_LOGIC;
                signal internal_dll_reference_clk :  STD_LOGIC;
                signal internal_dqs_delay_ctrl_export :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal internal_local_init_done :  STD_LOGIC;
                signal internal_local_powerdn_ack :  STD_LOGIC;
                signal internal_local_rdata_valid :  STD_LOGIC;
                signal internal_local_ready :  STD_LOGIC;
                signal internal_local_refresh_ack :  STD_LOGIC;
                signal internal_local_self_rfsh_ack :  STD_LOGIC;
                signal internal_local_wdata_req :  STD_LOGIC;
                signal internal_mem_addr :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_mem_ba :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_mem_cas_n :  STD_LOGIC;
                signal internal_mem_cke :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_mem_cs_n :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_mem_dm :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_mem_odt :  STD_LOGIC_VECTOR (0 DOWNTO 0);
                signal internal_mem_ras_n :  STD_LOGIC;
                signal internal_mem_reset_n :  STD_LOGIC;
                signal internal_mem_we_n :  STD_LOGIC;
                signal internal_phy_clk :  STD_LOGIC;
                signal internal_pll_reconfig_busy :  STD_LOGIC;
                signal internal_pll_reconfig_clk :  STD_LOGIC;
                signal internal_pll_reconfig_data_out :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal internal_pll_reconfig_reset :  STD_LOGIC;
                signal internal_reset_phy_clk_n :  STD_LOGIC;
                signal internal_reset_request_n :  STD_LOGIC;
                signal local_be_sig :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal local_rdata_sig :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal local_wdata_sig :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal no_connect2 :  STD_LOGIC;
                signal no_connect4 :  STD_LOGIC;
                signal postamble_successful :  STD_LOGIC;
                signal resynchronisation_successful :  STD_LOGIC;
                signal row_addr :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal tie_high :  STD_LOGIC;
                signal tie_low :  STD_LOGIC;
                signal tracking_adjustment_down :  STD_LOGIC;
                signal tracking_adjustment_up :  STD_LOGIC;
                signal tracking_successful :  STD_LOGIC;

begin

  local_wdata_sig(31 DOWNTO 0) <= local_wdata(31 DOWNTO 0);
  local_be_sig(3 DOWNTO 0) <= local_be(3 DOWNTO 0);
  local_rdata <= local_rdata_sig(31 DOWNTO 0);
  tie_low <= std_logic'('0');
  tie_high <= std_logic'('1');
  cs_addr <= std_logic'('0');
  bank_addr <= ctl_address(22 DOWNTO 21);
  row_addr <= ctl_address(20 DOWNTO 8);
  col_addr(8 DOWNTO 1) <= ctl_address(7 DOWNTO 0);
  col_addr(0) <= std_logic'('0');
  --Read data comes out of PHY (ctl_mem_rdata) and straight back into the PHY (ctl_rdata) from
  --where it goes to the user interface output (local_rdata). If your controller needs to delay
  --the read data for any reason, you will need to insert your controller between these two ports.
  --This also applies to the rdata_valid signal. 

  ddr_hp_ctrl_inst : ddr2_deva_auk_ddr_hp_controller_wrapper
    port map(
            clk => internal_phy_clk,
            control_be => control_be,
            control_doing_rd => control_doing_rd,
            control_doing_wr => no_connect2,
            control_dqs_burst => no_connect4,
            control_rdata => ctl_mem_rdata,
            control_rdata_valid => ctl_mem_rdata_valid,
            control_wdata => control_wdata,
            control_wdata_valid => control_wdata_valid,
            ddr_a => ctl_mem_a,
            ddr_ba => ctl_mem_ba,
            ddr_cas_n => ctl_mem_cas_n,
            ddr_cke_h(0) => ctl_mem_cke_h,
            ddr_cke_l(0) => ctl_mem_cke_l,
            ddr_cs_n(0) => ctl_mem_cs_n,
            ddr_odt(0) => ctl_mem_odt,
            ddr_ras_n => ctl_mem_ras_n,
            ddr_we_n => ctl_mem_we_n,
            local_autopch_req => ctl_autopch_req,
            local_bank_addr => bank_addr,
            local_be => ctl_be,
            local_burstbegin => ctl_burstbegin_sig,
            local_col_addr => col_addr,
            local_cs_addr => A_TOSTDLOGICVECTOR(cs_addr),
            local_init_done => ctl_init_done,
            local_powerdn_ack => ctl_powerdn_ack,
            local_powerdn_req => ctl_powerdn_req,
            local_rdata => ctl_rdata,
            local_rdata_valid => ctl_rdata_valid,
            local_read_req => ctl_read_req,
            local_ready => ctl_ready,
            local_refresh_ack => ctl_refresh_ack,
            local_refresh_req => ctl_refresh_req_sig,
            local_row_addr => row_addr,
            local_self_rfsh_ack => ctl_self_rfsh_ack,
            local_self_rfsh_req => ctl_self_rfsh_req,
            local_size => A_TOSTDLOGICVECTOR(ctl_size),
            local_wdata => ctl_wdata,
            local_wdata_req => ctl_wdata_req,
            local_write_req => ctl_write_req,
            reset_n => internal_reset_phy_clk_n
    );

  alt_mem_phy_inst : ddr2_deva_phy
    port map(
            aux_full_rate_clk => internal_aux_full_rate_clk,
            aux_half_rate_clk => internal_aux_half_rate_clk,
            ctl_add_1t_ac_lat => tie_low,
            ctl_add_1t_odt_lat => tie_low,
            ctl_add_intermediate_regs => tie_low,
            ctl_address => ctl_address,
            ctl_autopch_req => ctl_autopch_req,
            ctl_be => ctl_be,
            ctl_burstbegin => ctl_burstbegin_sig,
            ctl_doing_rd => control_doing_rd,
            ctl_init_done => ctl_init_done,
            ctl_mem_addr_h => ctl_mem_a,
            ctl_mem_addr_l => ctl_mem_a,
            ctl_mem_ba_h => ctl_mem_ba,
            ctl_mem_ba_l => ctl_mem_ba,
            ctl_mem_be => control_be,
            ctl_mem_cas_n_h => ctl_mem_cas_n,
            ctl_mem_cas_n_l => ctl_mem_cas_n,
            ctl_mem_cke_h => A_TOSTDLOGICVECTOR(ctl_mem_cke_h),
            ctl_mem_cke_l => A_TOSTDLOGICVECTOR(ctl_mem_cke_l),
            ctl_mem_cs_n_h => A_TOSTDLOGICVECTOR(tie_high),
            ctl_mem_cs_n_l => A_TOSTDLOGICVECTOR(ctl_mem_cs_n),
            ctl_mem_dqs_burst => control_wdata_valid,
            ctl_mem_odt_h => A_TOSTDLOGICVECTOR(ctl_mem_odt),
            ctl_mem_odt_l => A_TOSTDLOGICVECTOR(ctl_mem_odt),
            ctl_mem_ras_n_h => ctl_mem_ras_n,
            ctl_mem_ras_n_l => ctl_mem_ras_n,
            ctl_mem_rdata => ctl_mem_rdata,
            ctl_mem_rdata_valid => ctl_mem_rdata_valid,
            ctl_mem_wdata => control_wdata,
            ctl_mem_wdata_valid => control_wdata_valid,
            ctl_mem_we_n_h => ctl_mem_we_n,
            ctl_mem_we_n_l => ctl_mem_we_n,
            ctl_negedge_en => tie_low,
            ctl_powerdn_ack => ctl_powerdn_ack,
            ctl_powerdn_req => ctl_powerdn_req,
            ctl_rdata => ctl_rdata,
            ctl_rdata_valid => ctl_rdata_valid,
            ctl_read_req => ctl_read_req,
            ctl_ready => ctl_ready,
            ctl_refresh_ack => ctl_refresh_ack,
            ctl_refresh_req => ctl_refresh_req_sig,
            ctl_self_rfsh_ack => ctl_self_rfsh_ack,
            ctl_self_rfsh_req => ctl_self_rfsh_req,
            ctl_size(0) => ctl_size(0),
            ctl_usr_mode_rdy => ctl_usr_mode_rdy_sig,
            ctl_wdata => ctl_wdata,
            ctl_wdata_req => ctl_wdata_req,
            ctl_write_req => ctl_write_req,
            dll_reference_clk => internal_dll_reference_clk,
            dqs_delay_ctrl_export => internal_dqs_delay_ctrl_export,
            dqs_delay_ctrl_import => dqs_delay_ctrl_import,
            global_reset_n => global_reset_n,
            local_address => local_address,
            local_autopch_req => local_autopch_req,
            local_be => local_be_sig,
            local_burstbegin => local_burstbegin,
            local_init_done => internal_local_init_done,
            local_powerdn_ack => internal_local_powerdn_ack,
            local_powerdn_req => local_powerdn_req,
            local_rdata => local_rdata_sig,
            local_rdata_valid => internal_local_rdata_valid,
            local_read_req => local_read_req,
            local_ready => internal_local_ready,
            local_refresh_ack => internal_local_refresh_ack,
            local_refresh_req => local_refresh_req,
            local_self_rfsh_ack => internal_local_self_rfsh_ack,
            local_self_rfsh_req => local_self_rfsh_req,
            local_size => A_TOSTDLOGICVECTOR(local_size),
            local_wdata => local_wdata_sig,
            local_wdata_req => internal_local_wdata_req,
            local_write_req => local_write_req,
            mem_addr => internal_mem_addr,
            mem_ba => internal_mem_ba,
            mem_cas_n => internal_mem_cas_n,
            mem_cke(0) => internal_mem_cke(0),
            mem_clk(0) => mem_clk(0),
            mem_clk_n(0) => mem_clk_n(0),
            mem_cs_n(0) => internal_mem_cs_n(0),
            mem_dm(0) => internal_mem_dm(0),
            mem_dq => mem_dq,
            mem_dqs(0) => mem_dqs(0),
            mem_dqsn(0) => mem_dqsn(0),
            mem_odt(0) => internal_mem_odt(0),
            mem_ras_n => internal_mem_ras_n,
            mem_reset_n => internal_mem_reset_n,
            mem_we_n => internal_mem_we_n,
            oct_ctl_rs_value => oct_ctl_rs_value,
            oct_ctl_rt_value => oct_ctl_rt_value,
            phy_clk => internal_phy_clk,
            pll_reconfig => pll_reconfig,
            pll_reconfig_busy => internal_pll_reconfig_busy,
            pll_reconfig_clk => internal_pll_reconfig_clk,
            pll_reconfig_counter_param => pll_reconfig_counter_param,
            pll_reconfig_counter_type => pll_reconfig_counter_type,
            pll_reconfig_data_in => pll_reconfig_data_in,
            pll_reconfig_data_out => internal_pll_reconfig_data_out,
            pll_reconfig_enable => pll_reconfig_enable,
            pll_reconfig_read_param => pll_reconfig_read_param,
            pll_reconfig_reset => internal_pll_reconfig_reset,
            pll_reconfig_write_param => pll_reconfig_write_param,
            pll_ref_clk => pll_ref_clk,
            postamble_successful => postamble_successful,
            reset_phy_clk_n => internal_reset_phy_clk_n,
            reset_request_n => internal_reset_request_n,
            resynchronisation_successful => resynchronisation_successful,
            soft_reset_n => soft_reset_n,
            tracking_adjustment_down => tracking_adjustment_down,
            tracking_adjustment_up => tracking_adjustment_up,
            tracking_successful => tracking_successful
    );

  --vhdl renameroo for output signals
  aux_full_rate_clk <= internal_aux_full_rate_clk;
  --vhdl renameroo for output signals
  aux_half_rate_clk <= internal_aux_half_rate_clk;
  --vhdl renameroo for output signals
  dll_reference_clk <= internal_dll_reference_clk;
  --vhdl renameroo for output signals
  dqs_delay_ctrl_export <= internal_dqs_delay_ctrl_export;
  --vhdl renameroo for output signals
  local_init_done <= internal_local_init_done;
  --vhdl renameroo for output signals
  local_powerdn_ack <= internal_local_powerdn_ack;
  --vhdl renameroo for output signals
  local_rdata_valid <= internal_local_rdata_valid;
  --vhdl renameroo for output signals
  local_ready <= internal_local_ready;
  --vhdl renameroo for output signals
  local_refresh_ack <= internal_local_refresh_ack;
  --vhdl renameroo for output signals
  local_self_rfsh_ack <= internal_local_self_rfsh_ack;
  --vhdl renameroo for output signals
  local_wdata_req <= internal_local_wdata_req;
  --vhdl renameroo for output signals
  mem_addr <= internal_mem_addr;
  --vhdl renameroo for output signals
  mem_ba <= internal_mem_ba;
  --vhdl renameroo for output signals
  mem_cas_n <= internal_mem_cas_n;
  --vhdl renameroo for output signals
  mem_cke <= internal_mem_cke;
  --vhdl renameroo for output signals
  mem_cs_n <= internal_mem_cs_n;
  --vhdl renameroo for output signals
  mem_dm <= internal_mem_dm;
  --vhdl renameroo for output signals
  mem_odt <= internal_mem_odt;
  --vhdl renameroo for output signals
  mem_ras_n <= internal_mem_ras_n;
  --vhdl renameroo for output signals
  mem_reset_n <= internal_mem_reset_n;
  --vhdl renameroo for output signals
  mem_we_n <= internal_mem_we_n;
  --vhdl renameroo for output signals
  phy_clk <= internal_phy_clk;
  --vhdl renameroo for output signals
  pll_reconfig_busy <= internal_pll_reconfig_busy;
  --vhdl renameroo for output signals
  pll_reconfig_clk <= internal_pll_reconfig_clk;
  --vhdl renameroo for output signals
  pll_reconfig_data_out <= internal_pll_reconfig_data_out;
  --vhdl renameroo for output signals
  pll_reconfig_reset <= internal_pll_reconfig_reset;
  --vhdl renameroo for output signals
  reset_phy_clk_n <= internal_reset_phy_clk_n;
  --vhdl renameroo for output signals
  reset_request_n <= internal_reset_request_n;

end europa;

