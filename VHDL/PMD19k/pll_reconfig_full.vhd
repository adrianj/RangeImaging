-- megafunction wizard: %ALTPLL%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altpll 

-- ============================================================
-- File Name: pll_reconfig_full.vhd
-- Megafunction Name(s):
-- 			altpll
--
-- Simulation Library Files(s):
-- 			altera_mf
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 8.0 Build 215 05/29/2008 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2008 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY pll_reconfig_full IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		configupdate		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		phasecounterselect		: IN STD_LOGIC_VECTOR (3 DOWNTO 0) :=  (OTHERS => '0');
		phasestep		: IN STD_LOGIC  := '0';
		phaseupdown		: IN STD_LOGIC  := '0';
		scanclk		: IN STD_LOGIC  := '1';
		scanclkena		: IN STD_LOGIC  := '0';
		scandata		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC ;
		phasedone		: OUT STD_LOGIC ;
		scandataout		: OUT STD_LOGIC ;
		scandone		: OUT STD_LOGIC 
	);
END pll_reconfig_full;


ARCHITECTURE SYN OF pll_reconfig_full IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3	: STD_LOGIC ;
	SIGNAL sub_wire4	: STD_LOGIC ;
	SIGNAL sub_wire5	: STD_LOGIC ;
	SIGNAL sub_wire6	: STD_LOGIC ;
	SIGNAL sub_wire7	: STD_LOGIC ;
	SIGNAL sub_wire8	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire9_bv	: BIT_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire9	: STD_LOGIC_VECTOR (0 DOWNTO 0);



	COMPONENT altpll
	GENERIC (
		bandwidth_type		: STRING;
		clk0_divide_by		: NATURAL;
		clk0_duty_cycle		: NATURAL;
		clk0_multiply_by		: NATURAL;
		clk0_phase_shift		: STRING;
		clk1_divide_by		: NATURAL;
		clk1_duty_cycle		: NATURAL;
		clk1_multiply_by		: NATURAL;
		clk1_phase_shift		: STRING;
		compensate_clock		: STRING;
		inclk0_input_frequency		: NATURAL;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		operation_mode		: STRING;
		pll_type		: STRING;
		port_activeclock		: STRING;
		port_areset		: STRING;
		port_clkbad0		: STRING;
		port_clkbad1		: STRING;
		port_clkloss		: STRING;
		port_clkswitch		: STRING;
		port_configupdate		: STRING;
		port_fbin		: STRING;
		port_fbout		: STRING;
		port_inclk0		: STRING;
		port_inclk1		: STRING;
		port_locked		: STRING;
		port_pfdena		: STRING;
		port_phasecounterselect		: STRING;
		port_phasedone		: STRING;
		port_phasestep		: STRING;
		port_phaseupdown		: STRING;
		port_pllena		: STRING;
		port_scanaclr		: STRING;
		port_scanclk		: STRING;
		port_scanclkena		: STRING;
		port_scandata		: STRING;
		port_scandataout		: STRING;
		port_scandone		: STRING;
		port_scanread		: STRING;
		port_scanwrite		: STRING;
		port_clk0		: STRING;
		port_clk1		: STRING;
		port_clk2		: STRING;
		port_clk3		: STRING;
		port_clk4		: STRING;
		port_clk5		: STRING;
		port_clk6		: STRING;
		port_clk7		: STRING;
		port_clk8		: STRING;
		port_clk9		: STRING;
		port_clkena0		: STRING;
		port_clkena1		: STRING;
		port_clkena2		: STRING;
		port_clkena3		: STRING;
		port_clkena4		: STRING;
		port_clkena5		: STRING;
		self_reset_on_loss_lock		: STRING;
		using_fbmimicbidir_port		: STRING;
		vco_frequency_control		: STRING;
		vco_phase_shift_step		: NATURAL;
		width_clock		: NATURAL;
		scan_chain_mif_file		: STRING
	);
	PORT (
			scandone	: OUT STD_LOGIC ;
			scanclkena	: IN STD_LOGIC ;
			phasestep	: IN STD_LOGIC ;
			scandataout	: OUT STD_LOGIC ;
			phaseupdown	: IN STD_LOGIC ;
			inclk	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			phasecounterselect	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			locked	: OUT STD_LOGIC ;
			scandata	: IN STD_LOGIC ;
			phasedone	: OUT STD_LOGIC ;
			areset	: IN STD_LOGIC ;
			clk	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			scanclk	: IN STD_LOGIC ;
			configupdate	: IN STD_LOGIC 
	);
	END COMPONENT;

BEGIN
	sub_wire9_bv(0 DOWNTO 0) <= "0";
	sub_wire9    <= To_stdlogicvector(sub_wire9_bv);
	sub_wire2    <= sub_wire0(1);
	sub_wire1    <= sub_wire0(0);
	c0    <= sub_wire1;
	c1    <= sub_wire2;
	scandone    <= sub_wire3;
	scandataout    <= sub_wire4;
	locked    <= sub_wire5;
	phasedone    <= sub_wire6;
	sub_wire7    <= inclk0;
	sub_wire8    <= sub_wire9(0 DOWNTO 0) & sub_wire7;

	altpll_component : altpll
	GENERIC MAP (
		bandwidth_type => "AUTO",
		clk0_divide_by => 5,
		clk0_duty_cycle => 50,
		clk0_multiply_by => 4,
		clk0_phase_shift => "0",
		clk1_divide_by => 5,
		clk1_duty_cycle => 50,
		clk1_multiply_by => 4,
		clk1_phase_shift => "0",
		compensate_clock => "CLK0",
		inclk0_input_frequency => 20000,
		intended_device_family => "Stratix III",
		lpm_hint => "CBX_MODULE_PREFIX=pll_reconfig_full",
		lpm_type => "altpll",
		operation_mode => "NORMAL",
		pll_type => "Left_Right",
		port_activeclock => "PORT_UNUSED",
		port_areset => "PORT_USED",
		port_clkbad0 => "PORT_UNUSED",
		port_clkbad1 => "PORT_UNUSED",
		port_clkloss => "PORT_UNUSED",
		port_clkswitch => "PORT_UNUSED",
		port_configupdate => "PORT_USED",
		port_fbin => "PORT_UNUSED",
		port_fbout => "PORT_UNUSED",
		port_inclk0 => "PORT_USED",
		port_inclk1 => "PORT_UNUSED",
		port_locked => "PORT_USED",
		port_pfdena => "PORT_UNUSED",
		port_phasecounterselect => "PORT_USED",
		port_phasedone => "PORT_USED",
		port_phasestep => "PORT_USED",
		port_phaseupdown => "PORT_USED",
		port_pllena => "PORT_UNUSED",
		port_scanaclr => "PORT_UNUSED",
		port_scanclk => "PORT_USED",
		port_scanclkena => "PORT_USED",
		port_scandata => "PORT_USED",
		port_scandataout => "PORT_USED",
		port_scandone => "PORT_USED",
		port_scanread => "PORT_UNUSED",
		port_scanwrite => "PORT_UNUSED",
		port_clk0 => "PORT_USED",
		port_clk1 => "PORT_USED",
		port_clk2 => "PORT_UNUSED",
		port_clk3 => "PORT_UNUSED",
		port_clk4 => "PORT_UNUSED",
		port_clk5 => "PORT_UNUSED",
		port_clk6 => "PORT_UNUSED",
		port_clk7 => "PORT_UNUSED",
		port_clk8 => "PORT_UNUSED",
		port_clk9 => "PORT_UNUSED",
		port_clkena0 => "PORT_UNUSED",
		port_clkena1 => "PORT_UNUSED",
		port_clkena2 => "PORT_UNUSED",
		port_clkena3 => "PORT_UNUSED",
		port_clkena4 => "PORT_UNUSED",
		port_clkena5 => "PORT_UNUSED",
		self_reset_on_loss_lock => "OFF",
		using_fbmimicbidir_port => "OFF",
		vco_frequency_control => "MANUAL_PHASE",
		vco_phase_shift_step => 1,
		width_clock => 10,
		scan_chain_mif_file => "pll_reconfig_full.mif"
	)
	PORT MAP (
		scanclkena => scanclkena,
		phasestep => phasestep,
		phaseupdown => phaseupdown,
		inclk => sub_wire8,
		phasecounterselect => phasecounterselect,
		scandata => scandata,
		areset => areset,
		scanclk => scanclk,
		configupdate => configupdate,
		clk => sub_wire0,
		scandone => sub_wire3,
		scandataout => sub_wire4,
		locked => sub_wire5,
		phasedone => sub_wire6
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: ACTIVECLK_CHECK STRING "0"
-- Retrieval info: PRIVATE: BANDWIDTH STRING "1.000"
-- Retrieval info: PRIVATE: BANDWIDTH_FEATURE_ENABLED STRING "1"
-- Retrieval info: PRIVATE: BANDWIDTH_FREQ_UNIT STRING "MHz"
-- Retrieval info: PRIVATE: BANDWIDTH_PRESET STRING "Low"
-- Retrieval info: PRIVATE: BANDWIDTH_USE_AUTO STRING "1"
-- Retrieval info: PRIVATE: BANDWIDTH_USE_PRESET STRING "0"
-- Retrieval info: PRIVATE: CLKBAD_SWITCHOVER_CHECK STRING "0"
-- Retrieval info: PRIVATE: CLKLOSS_CHECK STRING "0"
-- Retrieval info: PRIVATE: CLKSWITCH_CHECK STRING "0"
-- Retrieval info: PRIVATE: CNX_NO_COMPENSATE_RADIO STRING "0"
-- Retrieval info: PRIVATE: CREATE_CLKBAD_CHECK STRING "0"
-- Retrieval info: PRIVATE: CREATE_INCLK1_CHECK STRING "0"
-- Retrieval info: PRIVATE: CUR_DEDICATED_CLK STRING "c0"
-- Retrieval info: PRIVATE: CUR_FBIN_CLK STRING "c0"
-- Retrieval info: PRIVATE: DEVICE_SPEED_GRADE STRING "2"
-- Retrieval info: PRIVATE: DIV_FACTOR0 NUMERIC "5"
-- Retrieval info: PRIVATE: DIV_FACTOR1 NUMERIC "5"
-- Retrieval info: PRIVATE: DUTY_CYCLE0 STRING "50.00000000"
-- Retrieval info: PRIVATE: DUTY_CYCLE1 STRING "50.00000000"
-- Retrieval info: PRIVATE: EXPLICIT_SWITCHOVER_COUNTER STRING "0"
-- Retrieval info: PRIVATE: EXT_FEEDBACK_RADIO STRING "0"
-- Retrieval info: PRIVATE: GLOCKED_COUNTER_EDIT_CHANGED STRING "1"
-- Retrieval info: PRIVATE: GLOCKED_FEATURE_ENABLED STRING "0"
-- Retrieval info: PRIVATE: GLOCKED_MODE_CHECK STRING "0"
-- Retrieval info: PRIVATE: GLOCK_COUNTER_EDIT NUMERIC "1048575"
-- Retrieval info: PRIVATE: HAS_MANUAL_SWITCHOVER STRING "1"
-- Retrieval info: PRIVATE: INCLK0_FREQ_EDIT STRING "50.000"
-- Retrieval info: PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
-- Retrieval info: PRIVATE: INCLK1_FREQ_EDIT STRING "100.000"
-- Retrieval info: PRIVATE: INCLK1_FREQ_EDIT_CHANGED STRING "1"
-- Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_CHANGED STRING "1"
-- Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_COMBO STRING "MHz"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix III"
-- Retrieval info: PRIVATE: INT_FEEDBACK__MODE_RADIO STRING "1"
-- Retrieval info: PRIVATE: LOCKED_OUTPUT_CHECK STRING "1"
-- Retrieval info: PRIVATE: LONG_SCAN_RADIO STRING "1"
-- Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE STRING "Not Available"
-- Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE_DIRTY NUMERIC "0"
-- Retrieval info: PRIVATE: LVDS_PHASE_SHIFT_UNIT0 STRING "deg"
-- Retrieval info: PRIVATE: LVDS_PHASE_SHIFT_UNIT1 STRING "deg"
-- Retrieval info: PRIVATE: MANUAL_PHASE_SHIFT_STEP_EDIT STRING "1.00000000"
-- Retrieval info: PRIVATE: MANUAL_PHASE_SHIFT_STEP_UNIT STRING "ps"
-- Retrieval info: PRIVATE: MIG_DEVICE_SPEED_GRADE STRING "Any"
-- Retrieval info: PRIVATE: MULT_FACTOR0 NUMERIC "4"
-- Retrieval info: PRIVATE: MULT_FACTOR1 NUMERIC "4"
-- Retrieval info: PRIVATE: NORMAL_MODE_RADIO STRING "1"
-- Retrieval info: PRIVATE: OUTPUT_FREQ0 STRING "100.00000000"
-- Retrieval info: PRIVATE: OUTPUT_FREQ1 STRING "100.00000000"
-- Retrieval info: PRIVATE: OUTPUT_FREQ_MODE0 STRING "0"
-- Retrieval info: PRIVATE: OUTPUT_FREQ_MODE1 STRING "0"
-- Retrieval info: PRIVATE: OUTPUT_FREQ_UNIT0 STRING "MHz"
-- Retrieval info: PRIVATE: OUTPUT_FREQ_UNIT1 STRING "MHz"
-- Retrieval info: PRIVATE: PHASE_RECONFIG_FEATURE_ENABLED STRING "1"
-- Retrieval info: PRIVATE: PHASE_RECONFIG_INPUTS_CHECK STRING "1"
-- Retrieval info: PRIVATE: PHASE_SHIFT0 STRING "0.00000000"
-- Retrieval info: PRIVATE: PHASE_SHIFT1 STRING "0.00000000"
-- Retrieval info: PRIVATE: PHASE_SHIFT_STEP_ENABLED_CHECK STRING "1"
-- Retrieval info: PRIVATE: PHASE_SHIFT_UNIT0 STRING "deg"
-- Retrieval info: PRIVATE: PHASE_SHIFT_UNIT1 STRING "deg"
-- Retrieval info: PRIVATE: PLL_ADVANCED_PARAM_CHECK STRING "0"
-- Retrieval info: PRIVATE: PLL_ARESET_CHECK STRING "1"
-- Retrieval info: PRIVATE: PLL_AUTOPLL_CHECK NUMERIC "0"
-- Retrieval info: PRIVATE: PLL_ENHPLL_CHECK NUMERIC "0"
-- Retrieval info: PRIVATE: PLL_FASTPLL_CHECK NUMERIC "1"
-- Retrieval info: PRIVATE: PLL_FBMIMIC_CHECK STRING "0"
-- Retrieval info: PRIVATE: PLL_LVDS_PLL_CHECK NUMERIC "0"
-- Retrieval info: PRIVATE: PLL_PFDENA_CHECK STRING "0"
-- Retrieval info: PRIVATE: PLL_TARGET_HARCOPY_CHECK NUMERIC "0"
-- Retrieval info: PRIVATE: PRIMARY_CLK_COMBO STRING "inclk0"
-- Retrieval info: PRIVATE: RECONFIG_FILE STRING "pll_reconfig_full.mif"
-- Retrieval info: PRIVATE: SACN_INPUTS_CHECK STRING "1"
-- Retrieval info: PRIVATE: SCAN_FEATURE_ENABLED STRING "1"
-- Retrieval info: PRIVATE: SELF_RESET_LOCK_LOSS STRING "0"
-- Retrieval info: PRIVATE: SHORT_SCAN_RADIO STRING "0"
-- Retrieval info: PRIVATE: SPREAD_FEATURE_ENABLED STRING "0"
-- Retrieval info: PRIVATE: SPREAD_FREQ STRING "50.000"
-- Retrieval info: PRIVATE: SPREAD_FREQ_UNIT STRING "KHz"
-- Retrieval info: PRIVATE: SPREAD_PERCENT STRING "0.500"
-- Retrieval info: PRIVATE: SPREAD_USE STRING "0"
-- Retrieval info: PRIVATE: SRC_SYNCH_COMP_RADIO STRING "0"
-- Retrieval info: PRIVATE: STICKY_CLK0 STRING "1"
-- Retrieval info: PRIVATE: STICKY_CLK1 STRING "1"
-- Retrieval info: PRIVATE: SWITCHOVER_COUNT_EDIT NUMERIC "1"
-- Retrieval info: PRIVATE: SWITCHOVER_FEATURE_ENABLED STRING "1"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: PRIVATE: USE_CLK0 STRING "1"
-- Retrieval info: PRIVATE: USE_CLK1 STRING "1"
-- Retrieval info: PRIVATE: USE_MIL_SPEED_GRADE NUMERIC "0"
-- Retrieval info: PRIVATE: ZERO_DELAY_RADIO STRING "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: BANDWIDTH_TYPE STRING "AUTO"
-- Retrieval info: CONSTANT: CLK0_DIVIDE_BY NUMERIC "5"
-- Retrieval info: CONSTANT: CLK0_DUTY_CYCLE NUMERIC "50"
-- Retrieval info: CONSTANT: CLK0_MULTIPLY_BY NUMERIC "4"
-- Retrieval info: CONSTANT: CLK0_PHASE_SHIFT STRING "0"
-- Retrieval info: CONSTANT: CLK1_DIVIDE_BY NUMERIC "5"
-- Retrieval info: CONSTANT: CLK1_DUTY_CYCLE NUMERIC "50"
-- Retrieval info: CONSTANT: CLK1_MULTIPLY_BY NUMERIC "4"
-- Retrieval info: CONSTANT: CLK1_PHASE_SHIFT STRING "0"
-- Retrieval info: CONSTANT: COMPENSATE_CLOCK STRING "CLK0"
-- Retrieval info: CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC "20000"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix III"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altpll"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "NORMAL"
-- Retrieval info: CONSTANT: PLL_TYPE STRING "Left_Right"
-- Retrieval info: CONSTANT: PORT_ACTIVECLOCK STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_ARESET STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_CLKBAD0 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_CLKBAD1 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_CLKLOSS STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_CLKSWITCH STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_CONFIGUPDATE STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_FBIN STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_FBOUT STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_INCLK0 STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_INCLK1 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_LOCKED STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_PFDENA STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_PHASECOUNTERSELECT STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_PHASEDONE STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_PHASESTEP STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_PHASEUPDOWN STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_PLLENA STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_SCANACLR STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_SCANCLK STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_SCANCLKENA STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_SCANDATA STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_SCANDATAOUT STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_SCANDONE STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_SCANREAD STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_SCANWRITE STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk0 STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_clk1 STRING "PORT_USED"
-- Retrieval info: CONSTANT: PORT_clk2 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk3 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk4 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk5 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk6 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk7 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk8 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clk9 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clkena0 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clkena1 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clkena2 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clkena3 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clkena4 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: PORT_clkena5 STRING "PORT_UNUSED"
-- Retrieval info: CONSTANT: SELF_RESET_ON_LOSS_LOCK STRING "OFF"
-- Retrieval info: CONSTANT: USING_FBMIMICBIDIR_PORT STRING "OFF"
-- Retrieval info: CONSTANT: VCO_FREQUENCY_CONTROL STRING "MANUAL_PHASE"
-- Retrieval info: CONSTANT: VCO_PHASE_SHIFT_STEP NUMERIC "1"
-- Retrieval info: CONSTANT: WIDTH_CLOCK NUMERIC "10"
-- Retrieval info: CONSTANT: scan_chain_mif_file STRING "pll_reconfig_full.mif"
-- Retrieval info: USED_PORT: @clk 0 0 10 0 OUTPUT_CLK_EXT VCC "@clk[9..0]"
-- Retrieval info: USED_PORT: @inclk 0 0 2 0 INPUT_CLK_EXT VCC "@inclk[1..0]"
-- Retrieval info: USED_PORT: areset 0 0 0 0 INPUT GND "areset"
-- Retrieval info: USED_PORT: c0 0 0 0 0 OUTPUT_CLK_EXT VCC "c0"
-- Retrieval info: USED_PORT: c1 0 0 0 0 OUTPUT_CLK_EXT VCC "c1"
-- Retrieval info: USED_PORT: configupdate 0 0 0 0 INPUT GND "configupdate"
-- Retrieval info: USED_PORT: inclk0 0 0 0 0 INPUT_CLK_EXT GND "inclk0"
-- Retrieval info: USED_PORT: locked 0 0 0 0 OUTPUT GND "locked"
-- Retrieval info: USED_PORT: phasecounterselect 0 0 4 0 INPUT GND "phasecounterselect[3..0]"
-- Retrieval info: USED_PORT: phasedone 0 0 0 0 OUTPUT GND "phasedone"
-- Retrieval info: USED_PORT: phasestep 0 0 0 0 INPUT GND "phasestep"
-- Retrieval info: USED_PORT: phaseupdown 0 0 0 0 INPUT GND "phaseupdown"
-- Retrieval info: USED_PORT: scanclk 0 0 0 0 INPUT_CLK_EXT VCC "scanclk"
-- Retrieval info: USED_PORT: scanclkena 0 0 0 0 INPUT GND "scanclkena"
-- Retrieval info: USED_PORT: scandata 0 0 0 0 INPUT GND "scandata"
-- Retrieval info: USED_PORT: scandataout 0 0 0 0 OUTPUT VCC "scandataout"
-- Retrieval info: USED_PORT: scandone 0 0 0 0 OUTPUT VCC "scandone"
-- Retrieval info: CONNECT: phasedone 0 0 0 0 @phasedone 0 0 0 0
-- Retrieval info: CONNECT: locked 0 0 0 0 @locked 0 0 0 0
-- Retrieval info: CONNECT: scandone 0 0 0 0 @scandone 0 0 0 0
-- Retrieval info: CONNECT: @inclk 0 0 1 0 inclk0 0 0 0 0
-- Retrieval info: CONNECT: c0 0 0 0 0 @clk 0 0 1 0
-- Retrieval info: CONNECT: @phaseupdown 0 0 0 0 phaseupdown 0 0 0 0
-- Retrieval info: CONNECT: @phasecounterselect 0 0 4 0 phasecounterselect 0 0 4 0
-- Retrieval info: CONNECT: @scandata 0 0 0 0 scandata 0 0 0 0
-- Retrieval info: CONNECT: c1 0 0 0 0 @clk 0 0 1 1
-- Retrieval info: CONNECT: @scanclkena 0 0 0 0 scanclkena 0 0 0 0
-- Retrieval info: CONNECT: @configupdate 0 0 0 0 configupdate 0 0 0 0
-- Retrieval info: CONNECT: scandataout 0 0 0 0 @scandataout 0 0 0 0
-- Retrieval info: CONNECT: @inclk 0 0 1 1 GND 0 0 0 0
-- Retrieval info: CONNECT: @phasestep 0 0 0 0 phasestep 0 0 0 0
-- Retrieval info: CONNECT: @scanclk 0 0 0 0 scanclk 0 0 0 0
-- Retrieval info: CONNECT: @areset 0 0 0 0 areset 0 0 0 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full.vhd TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full.ppf TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full.inc TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full.cmp TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full.bsf TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full_inst.vhd FALSE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL pll_reconfig_full.mif TRUE FALSE
-- Retrieval info: LIB_FILE: altera_mf
-- Retrieval info: CBX_MODULE_PREFIX: ON
